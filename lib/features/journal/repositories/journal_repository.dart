import 'package:isar/isar.dart';
import '../models/journal_entry.dart';

class JournalRepository {
  final Isar isar;

  JournalRepository(this.isar);

  // 1. Create or Update Entry
  Future<void> saveEntry(JournalEntry entry) async {
    await isar.writeTxn(() async {
      await isar.journalEntrys
          .put(entry); // Isar auto-generates 'journalEntrys'
    });
  }

  // 2. Read All Entries (Sorted by newest first)
  Future<List<JournalEntry>> getAllEntries() async {
    return await isar.journalEntrys.where().sortByDateDesc().findAll();
  }

  // 3. Delete Entry
  Future<void> deleteEntry(int id) async {
    await isar.writeTxn(() async {
      await isar.journalEntrys.delete(id);
    });
  }
}
