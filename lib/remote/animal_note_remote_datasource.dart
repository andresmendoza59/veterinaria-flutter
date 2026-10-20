import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/model/animal_note.dart';

class AnimalNoteRemoteDatasource {
    final FirebaseFirestore firestore;

    AnimalNoteRemoteDatasource(this.firestore);

    Future<void> upsertNote(AnimalNote note) async {
        await firestore
            .collection('animal_notes')
            .doc(note.animalId.toString())
            .set(note.toJson());
    }
}
