import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../Models/mood.dart';
import '../Services/storage_service.dart';

class MoodsNotifier extends StateNotifier<List<Mood>> {
  MoodsNotifier() : super([]) {
    _load();
  }

  static const _uuid = Uuid();

  void _load() {
    state = StorageService.moodsBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<Mood> add({
    required int rating,
    List<String> tags = const [],
    String? note,
  }) async {
    final mood = Mood(
      id: _uuid.v4(),
      date: DateTime.now(),
      rating: rating,
      tags: tags,
      note: note,
    );
    await StorageService.moodsBox.put(mood.id, mood);
    _load();
    return mood;
  }

  Future<void> delete(Mood mood) async {
    await StorageService.moodsBox.delete(mood.id);
    _load();
  }

  Mood? todayMood() {
    final now = DateTime.now();
    for (final m in state) {
      if (m.date.year == now.year &&
          m.date.month == now.month &&
          m.date.day == now.day) {
        return m;
      }
    }
    return null;
  }

  double averageLast7Days() {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final recent = state.where((m) => m.date.isAfter(cutoff)).toList();
    if (recent.isEmpty) return 0;
    return recent.map((e) => e.rating).reduce((a, b) => a + b) / recent.length;
  }
}

final moodsProvider =
    StateNotifierProvider<MoodsNotifier, List<Mood>>((ref) => MoodsNotifier());
