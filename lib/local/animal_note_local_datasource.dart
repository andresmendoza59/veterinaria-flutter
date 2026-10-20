import 'package:drift/drift.dart';
import 'package:flutter_app/model/animal_note.dart';

import 'app_database.dart';

class AnimalNoteLocalDataSource {
    final AppDatabase db;

    AnimalNoteLocalDataSource(this.db);

    AnimalNote _toDomain(AnimalNoteRow row) {
        return AnimalNote(animalId: row.animalId,
            note: row.note,
            updatedAt: row.updatedAt
        );
    }

    Future<AnimalNote?> getNoteForAnimal(String animalId) async {
        final query = db.select(db.animalNotes)
            ..where((t) => t.animalId.equals(animalId));

        final row = await query.getSingleOrNull();

        return row == null ? null : _toDomain(row);
    }

    Future<void> saveNote(AnimalNote note) async {
        await db.into(db.animalNotes).insertOnConflictUpdate(
            AnimalNotesCompanion.insert(
                animalId: note.animalId,
                note: note.note,
                updatedAt: note.updatedAt,
                pendingSync: const Value(true)
            )
        );
    }

    Future<List<AnimalNote>> getPendingNotes() async {
        final rows = await (db.select(db.animalNotes)
            ..where((t) => t.pendingSync.equals(true)))
            .get();

        return rows.map(_toDomain).toList();
    }

    Future<void> markSynced(String animalId) async {
        await (db.update(db.animalNotes)
            ..where((t) => t.animalId.equals(animalId)))
            .write(const AnimalNotesCompanion(pendingSync: Value(false)));
    }
}
