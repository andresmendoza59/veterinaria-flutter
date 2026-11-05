import 'package:drift/drift.dart';

import 'animal_notes_table.dart';
import 'connection/connection.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [AnimalNotes])
class AppDatabase extends _$AppDatabase {
    AppDatabase(): super(openConnection());

    @override
    int get schemaVersion => 1;
}
