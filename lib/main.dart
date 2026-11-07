import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:flutter_app/data/datasources/local/animal_note_local_datasource.dart';
import 'package:flutter_app/data/datasources/local/app_database.dart';
import 'package:flutter_app/data/datasources/remote/animal_note_remote_datasource.dart';
import 'package:flutter_app/data/repositories/animal_note_repository.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/data/services/catalog_source.dart';
import 'package:flutter_app/data/services/crash/crash_service.dart';
import 'package:flutter_app/features/itinerary/presentation/screens/itinerary_home_screen.dart';
import 'package:flutter_app/shared/models/user_role.dart';
import 'features/animals/presentation/screens/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final crashService = const CrashService();
  await crashService.configure();

  final database = AppDatabase();
  final local = AnimalNoteLocalDataSource(database);
  final remote = AnimalNoteRemoteDatasource(FirebaseFirestore.instance);
  final noteRepo = AnimalNoteRepository(local: local, remote: remote);
  final catalogSource = HttpCatalogSource();
  final authService = FirebaseAuthService();

  runApp(MyApp(
    noteRepo: noteRepo,
    authService: authService,
    crashService: crashService,
    catalogSource: catalogSource,
  ));
}

class MyApp extends StatelessWidget {
  final AnimalNoteRepository noteRepo;
  final AuthService authService;
  final CrashService crashService;
  final CatalogSource catalogSource;

  const MyApp({
    super.key,
    required this.noteRepo,
    required this.authService,
    required this.crashService,
    required this.catalogSource,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(
        noteRepo: noteRepo,
        authService: authService,
        crashService: crashService,
        catalogSource: catalogSource,
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  final AnimalNoteRepository noteRepo;
  final AuthService authService;
  final CrashService crashService;
  final CatalogSource catalogSource;

  const AuthGate({
    super.key,
    required this.noteRepo,
    required this.authService,
    required this.crashService,
    required this.catalogSource,
  });

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

        final user = snapshot.data;
        if (user != null) {
          // Solo el uid (identificador técnico): nunca correo ni contraseña.
          unawaited(crashService.setUserIdentifier(user.uid));
          return ItineraryHomeScreen(
            uid: user.uid,
            role: UserRole.member,
            authService: authService,
            crashService: crashService,
            catalogSource: catalogSource,
          );
        }

        return LoginPage(authService: authService);
      },
    );
  }
}
