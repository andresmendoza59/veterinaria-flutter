import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:flutter_app/local/animal_note_local_datasource.dart';
import 'package:flutter_app/local/app_database.dart';
import 'package:flutter_app/remote/animal_note_remote_datasource.dart';
import 'package:flutter_app/repository/animal_note_repository.dart';
import 'animal_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform );

  final database = AppDatabase();
  final local = AnimalNoteLocalDataSource(database);
  final remote = AnimalNoteRemoteDatasource(FirebaseFirestore.instance);
  final noteRepo = AnimalNoteRepository(local: local, remote: remote);

  runApp(MyApp(noteRepo: noteRepo));
}

class MyApp extends StatelessWidget {
  final AnimalNoteRepository noteRepo;

  const MyApp({ super.key, required this.noteRepo });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimalScreen(noteRepo: noteRepo),
    );
  }
}
