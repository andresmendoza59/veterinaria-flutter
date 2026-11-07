import 'package:drift/drift.dart';

import 'animal_notes_table.dart';
import 'connection/connection.dart';
import 'itinerary_activities_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [AnimalNotes, ItineraryActivities])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(itineraryActivities);
          }
        },
      );
}
