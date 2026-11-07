// Puerta de entrada: en web se usa el stub (Crashlytics no está soportado);
// en plataformas con dart:io se usa la implementación real.
export 'stub_crash_service.dart'
    if (dart.library.io) 'firebase_crash_service.dart';
