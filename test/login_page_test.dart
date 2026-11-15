import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/features/auth/presentation/screens/login_page.dart';
import 'package:flutter_test/flutter_test.dart';

/// AuthService falso: no usa Firebase. Sirve para probar la pantalla sola.
class FakeAuthService implements AuthService {
  int loginCalls = 0;
  String? errorCode;

  @override
  Stream<User?> authStateChanges() => const Stream<User?>.empty();

  @override
  Future<void> login({required String email, required String password}) async {
    loginCalls++;
    final code = errorCode;
    if (code != null) {
      throw FirebaseAuthException(code: code);
    }
  }

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> sendPasswordReset({required String email}) async {}
}

Future<void> _openLogin(WidgetTester tester, FakeAuthService auth) async {
  await tester.pumpWidget(MaterialApp(home: LoginPage(authService: auth)));
}

Future<void> _fillAndSubmit(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.enterText(find.byType(TextFormField).at(0), email);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.text('Ingresar'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('con campos inválidos no se llama a Firebase', (tester) async {
    final auth = FakeAuthService();
    await _openLogin(tester, auth);

    await _fillAndSubmit(tester, email: 'correo-malo', password: '123');

    expect(find.text('Ingrese un correo válido'), findsOneWidget);
    expect(
      find.text('La contraseña debe tener mínimo 6 caracteres'),
      findsOneWidget,
    );
    expect(auth.loginCalls, 0);
  });

  testWidgets('credenciales incorrectas muestran un mensaje en español', (
    tester,
  ) async {
    final auth = FakeAuthService();
    auth.errorCode = 'invalid-credential';
    await _openLogin(tester, auth);

    await _fillAndSubmit(
      tester,
      email: 'miembro@viaje.test',
      password: 'clave-equivocada',
    );

    expect(auth.loginCalls, 1);
    expect(find.text('Las credenciales no coinciden'), findsOneWidget);
  });

  testWidgets('sin conexión se informa sin mostrar la excepción técnica', (
    tester,
  ) async {
    final auth = FakeAuthService();
    auth.errorCode = 'network-request-failed';
    await _openLogin(tester, auth);

    await _fillAndSubmit(
      tester,
      email: 'miembro@viaje.test',
      password: 'secreta123',
    );

    expect(find.text('Revisa tu conexión a internet'), findsOneWidget);
    expect(find.textContaining('FirebaseAuthException'), findsNothing);
  });
}
