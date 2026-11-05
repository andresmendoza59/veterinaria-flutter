import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/firebase_options.dart';
import 'package:flutter_app/data/datasources/local/animal_note_local_datasource.dart';
import 'package:flutter_app/data/datasources/local/app_database.dart';
import 'package:flutter_app/data/datasources/remote/animal_note_remote_datasource.dart';
import 'package:flutter_app/data/repositories/animal_note_repository.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'features/animals/presentation/screens/animal_screen.dart';
import 'features/animals/presentation/screens/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final database = AppDatabase();
  final local = AnimalNoteLocalDataSource(database);
  final remote = AnimalNoteRemoteDatasource(FirebaseFirestore.instance);
  final noteRepo = AnimalNoteRepository(local: local, remote: remote);
  final authService = FirebaseAuthService();

  runApp(MyApp(noteRepo: noteRepo, authService: authService));
}

class MyApp extends StatelessWidget {
  final AnimalNoteRepository noteRepo;
  final AuthService authService;

  const MyApp({super.key, required this.noteRepo, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(noteRepo: noteRepo, authService: authService),
    );
  }
}

class AuthGate extends StatelessWidget {
  final AnimalNoteRepository noteRepo;
  final AuthService authService;

  const AuthGate({super.key, required this.noteRepo, required this.authService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return AnimalScreen(noteRepo: noteRepo);
        }

        return LoginPage(authService: authService);
      },
    );
  }
}
