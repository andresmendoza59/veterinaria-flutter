import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashService {
  const CrashService();

  // Crashlytics solo funciona en Android e iOS. En Windows/macOS/Linux el
  // servicio se limita a escribir en consola para no romper la app.
  bool get _supported =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> configure() async {
    if (!_supported) {
      debugPrint('[CrashService] Plataforma sin Crashlytics');
      return;
    }

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  Future<void> setUserIdentifier(String id) async {
    if (!_supported) return;
    return FirebaseCrashlytics.instance.setUserIdentifier(id);
  }

  Future<void> recordNonFatal(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) async {
    if (!_supported) {
      debugPrint('[CrashService] $reason: $error');
      return;
    }
    return FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: false,
    );
  }

  Future<void> simulateNonFatalError() async {
    try {
      throw StateError('Error no fatal de prueba');
    } catch (error, stackTrace) {
      await recordNonFatal(error, stackTrace, reason: 'Prueba QA');
    }
  }

  void simulateFatalCrash() {
    if (!_supported) {
      throw StateError('Crash fatal de prueba (plataforma sin Crashlytics)');
    }
    FirebaseCrashlytics.instance.crash();
  }
}
