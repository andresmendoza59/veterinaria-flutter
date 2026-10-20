import 'package:flutter_app/local/animal_note_local_datasource.dart';
import 'package:flutter_app/model/animal_note.dart';
import 'package:flutter_app/remote/animal_note_remote_datasource.dart';

class AnimalNoteRepository {
    final AnimalNoteLocalDataSource local;
    final AnimalNoteRemoteDatasource? remote;

    AnimalNoteRepository({ required this.local, this.remote });

    Future<AnimalNote?> getNoteForAnimal(String animalId) =>
        local.getNoteForAnimal(animalId);

    Future<void> saveNote(AnimalNote note) async {
        await local.saveNote(note);

        final remoteSource = remote;

        if (remoteSource == null) return;

        try {
            await remoteSource.upsertNote(note);
            await local.markSynced(note.animalId);
        } catch (_) {
            // To Do
        }
    }

    Future<void> syncPending() async {
        final remoteSource = remote;

        if (remoteSource == null) return;

        final pending = await local.getPendingNotes();

        for (final note in pending) {
            try {
                await remoteSource.upsertNote(note);
                await local.markSynced(note.animalId);
            } catch (_) {
                // To Do
            }
        }
    }
}
