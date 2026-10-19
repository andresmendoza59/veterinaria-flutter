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
}
