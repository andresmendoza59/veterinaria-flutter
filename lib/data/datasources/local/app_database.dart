import 'package:drift/drift.dart';

import 'animal_notes_table.dart';
import 'catalog_options_table.dart';
import 'connection/connection.dart';
import 'itinerary_activities_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [AnimalNotes, ItineraryActivities, CatalogOptions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// Solo para pruebas: recibe una base de datos en memoria.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(itineraryActivities);
          }
          // v3: copia local del catálogo HTTP para trabajar sin conexión.
          if (from < 3) {
            await m.createTable(catalogOptions);
          }
        },
      );
}
