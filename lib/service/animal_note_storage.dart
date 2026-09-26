import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/model/animal_note.dart';
import 'package:path_provider/path_provider.dart';

class AnimalNoteStorage {
    static const _filename = 'animal_notes.json';

    Future<File> _getFile() async {
        final directory = await getApplicationDocumentsDirectory();
        return File('${directory.path}/$_filename');
    }

    Future<List<AnimalNote>> _readAllNotes() async {
        final file = await _getFile();
        if (!await file.exists()) {
            return [];
        }

        final content = await file.readAsString();
        if (content.isEmpty) {
            return [];
        }

        final List<dynamic> data = jsonDecode(content);

        return data.map((item) => AnimalNote.fromJson(item)).toList();
    }

    Future<void> _writeAll(List<AnimalNote> notes) async {
        final file = await _getFile();
        final jsonString = jsonEncode(notes.map((note) => note.toJson()).toList());

        await file.writeAsString(jsonString);
    }

    Future<AnimalNote?> getNoteFromAnimal(String animalId) async {
        final notes = await _readAllNotes();
        return notes.map((note) => note.animalId == animalId).firstOrNull;
    } 
}
