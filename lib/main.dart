import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:flutter_app/data/datasources/local/app_database.dart';
import 'package:flutter_app/data/datasources/local/itinerary_local_datasource.dart';
import 'package:flutter_app/data/datasources/remote/itinerary_remote_datasource.dart';
import 'package:flutter_app/data/datasources/remote/user_profile_remote_datasource.dart';
import 'package:flutter_app/data/repositories/itinerary_repository.dart';
import 'package:flutter_app/data/repositories/user_profile_repository.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/data/repositories/catalog_repository.dart';
import 'package:flutter_app/data/services/catalog_source.dart';
import 'package:flutter_app/data/services/crash/crash_service.dart';
import 'package:flutter_app/features/itinerary/presentation/screens/itinerary_home_screen.dart';
import 'package:flutter_app/features/itinerary/presentation/screens/profile_gate.dart';
import 'package:flutter_app/features/auth/presentation/screens/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final crashService = const CrashService();
  await crashService.configure();

  final database = AppDatabase();
  final firestore = FirebaseFirestore.instance;
  final itineraryRepo = ItineraryRepository(
    local: ItineraryLocalDataSource(database),
    remote: ItineraryRemoteDataSource(firestore),
  );
  final profileRepo = UserProfileRepository(
    remote: UserProfileRemoteDataSource(firestore),
  );
  final catalogRepo = CatalogRepository(source: HttpCatalogSource());
  final authService = FirebaseAuthService();

  runApp(MyApp(
    profileRepo: profileRepo,
    itineraryRepo: itineraryRepo,
    authService: authService,
    crashService: crashService,
    catalogRepo: catalogRepo,
  ));
}

class MyApp extends StatelessWidget {
  final UserProfileRepository profileRepo;
  final ItineraryRepository itineraryRepo;
  final AuthService authService;
  final CrashService crashService;
  final CatalogRepository catalogRepo;

  const MyApp({
    super.key,
    required this.profileRepo,
    required this.itineraryRepo,
    required this.authService,
    required this.crashService,
    required this.catalogRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(
        profileRepo: profileRepo,
        itineraryRepo: itineraryRepo,
        authService: authService,
        crashService: crashService,
        catalogRepo: catalogRepo,
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  final UserProfileRepository profileRepo;
  final ItineraryRepository itineraryRepo;
  final AuthService authService;
  final CrashService crashService;
  final CatalogRepository catalogRepo;

  const AuthGate({
    super.key,
    required this.profileRepo,
    required this.itineraryRepo,
    required this.authService,
    required this.crashService,
    required this.catalogRepo,
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
          return ProfileGate(
            key: ValueKey(user.uid),
            uid: user.uid,
            profileRepo: profileRepo,
            authService: authService,
            builder: (context, role) => ItineraryHomeScreen(
              uid: user.uid,
              role: role,
              authService: authService,
              crashService: crashService,
              catalogRepo: catalogRepo,
              itineraryRepo: itineraryRepo,
            ),
          );
        }

        return LoginPage(authService: authService);
      },
    );
  }
}
