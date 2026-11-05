import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/shared/models/animal_note.dart';
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

    return data
        .map((item) => AnimalNote.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeAll(List<AnimalNote> notes) async {
    final file = await _getFile();
    final jsonString = jsonEncode(notes.map((note) => note.toJson()).toList());

    await file.writeAsString(jsonString);
  }

  Future<AnimalNote?> getNoteFromAnimal(String animalId) async {
    final notes = await _readAllNotes();
    try {
      return notes.firstWhere((note) => note.animalId == animalId);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveNote(AnimalNote note) async {
    final notes = await _readAllNotes();
    notes.removeWhere((n) => n.animalId == note.animalId);
    notes.add(note);

    await _writeAll(notes);
  }

  Future<List<AnimalNote>> getAllNotes() async {
    return _readAllNotes();
  }

  Future<void> deleteNote(String animalId) async {
    final notes = await _readAllNotes();
    notes.removeWhere((n) => n.animalId == animalId);
    await _writeAll(notes);
  }

  Future<void> clear() async {
    final file = await _getFile();
    if (await file.exists()) {
      await file.delete();
    }
  }
}
