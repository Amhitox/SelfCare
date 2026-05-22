import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdUnitIds {
  AdUnitIds._();

  static const String _androidTestBanner =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _androidTestNative =
      'ca-app-pub-3940256099942544/2247696110';
  static const String _androidTestRewarded =
      'ca-app-pub-3940256099942544/5224354917';

  // Replace with real Android Ad Unit IDs before publishing.
  static const String _androidProdBanner = 'REPLACE_WITH_PROD_BANNER_ID';
  static const String _androidProdInterstitial =
      'REPLACE_WITH_PROD_INTERSTITIAL_ID';
  static const String _androidProdNative = 'REPLACE_WITH_PROD_NATIVE_ID';
  static const String _androidProdRewarded =
      'REPLACE_WITH_PROD_REWARDED_ID';

  static String get banner =>
      kReleaseMode ? _androidProdBanner : _androidTestBanner;
  static String get interstitial =>
      kReleaseMode ? _androidProdInterstitial : _androidTestInterstitial;
  static String get nativeAd =>
      kReleaseMode ? _androidProdNative : _androidTestNative;
  static String get rewarded =>
      kReleaseMode ? _androidProdRewarded : _androidTestRewarded;
}

class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  bool _initialized = false;
  bool get initialized => _initialized;
  bool get supported => !kIsWeb && Platform.isAndroid;

  InterstitialAd? _interstitialAd;
  bool _loadingInterstitial = false;
  DateTime _lastInterstitialShown =
      DateTime.fromMillisecondsSinceEpoch(0);
  final Duration _interstitialCooldown = const Duration(minutes: 3);

  RewardedAd? _rewardedAd;
  bool _loadingRewarded = false;

  Future<void> init() async {
    if (!supported || _initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      _preloadInterstitial();
      _preloadRewarded();
    } catch (e) {
      debugPrint('AdsService init failed: $e');
    }
  }

  void _preloadInterstitial() {
    if (!supported || _loadingInterstitial || _interstitialAd != null) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: AdUnitIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _loadingInterstitial = false;
        },
      ),
    );
  }

  void _preloadRewarded() {
    if (!supported || _loadingRewarded || _rewardedAd != null) return;
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: AdUnitIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _loadingRewarded = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _loadingRewarded = false;
        },
      ),
    );
  }

  Future<bool> maybeShowInterstitial() async {
    if (!supported || !_initialized) return false;
    final now = DateTime.now();
    if (now.difference(_lastInterstitialShown) < _interstitialCooldown) {
      return false;
    }
    final ad = _interstitialAd;
    if (ad == null) {
      _preloadInterstitial();
      return false;
    }
    final completer = <bool>[];
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _lastInterstitialShown = DateTime.now();
        _preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _preloadInterstitial();
      },
    );
    try {
      await ad.show();
      _lastInterstitialShown = DateTime.now();
      return true;
    } catch (_) {
      return false;
    } finally {
      completer.add(true);
    }
  }

  Future<bool> showRewarded(VoidCallback onReward) async {
    if (!supported || !_initialized) return false;
    final ad = _rewardedAd;
    if (ad == null) {
      _preloadRewarded();
      return false;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _preloadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _preloadRewarded();
      },
    );
    try {
      await ad.show(onUserEarnedReward: (_, __) => onReward());
      return true;
    } catch (_) {
      return false;
    }
  }

  BannerAd? createBanner({VoidCallback? onLoaded}) {
    if (!supported || !_initialized) return null;
    final banner = BannerAd(
      adUnitId: AdUnitIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded?.call(),
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    );
    banner.load();
    return banner;
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
