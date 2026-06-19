import 'package:isar/isar.dart';

part 'journal_entry.g.dart';

enum Mood { happy, sad, neutral, excited, angry, calm } // Isar supports enums!

@collection
class JournalEntry {
  Id id = Isar.autoIncrement;

  late String title;
  late String content;
  late DateTime date;

  List<String> mediaPaths = [];

  @enumerated
  Mood mood = Mood.neutral;

  double? latitude;
  double? longitude;
}
