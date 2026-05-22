import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../Models/journal_entry.dart';
import '../Services/storage_service.dart';

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  JournalNotifier() : super([]) {
    _load();
  }

  static const _uuid = Uuid();

  void _load() {
    state = StorageService.journalBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<JournalEntry> add({
    required String title,
    required String content,
    String mood = '',
  }) async {
    final entry = JournalEntry(
      id: _uuid.v4(),
      date: DateTime.now(),
      title: title,
      content: content,
      mood: mood,
    );
    await StorageService.journalBox.put(entry.id, entry);
    _load();
    return entry;
  }

  Future<void> update(JournalEntry entry) async {
    await StorageService.journalBox.put(entry.id, entry);
    _load();
  }

  Future<void> delete(JournalEntry entry) async {
    await StorageService.journalBox.delete(entry.id);
    _load();
  }
}

final journalProvider =
    StateNotifierProvider<JournalNotifier, List<JournalEntry>>(
        (ref) => JournalNotifier());
