# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Google Mobile Ads (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.**

# AndroidX WorkManager + Alarm Manager
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# timezone (uses java.beans on some platforms)
-dontwarn java.beans.**

# Kotlin coroutines
-dontwarn kotlinx.coroutines.**
