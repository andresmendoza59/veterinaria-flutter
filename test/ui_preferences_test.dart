import 'package:flutter_app/data/services/ui_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // SharedPreferences en memoria: cada prueba empieza vacía.
    SharedPreferences.setMockInitialValues({});
  });

  test('sin datos guardados: categoría "Todas" y primera pestaña', () async {
    final prefs = UiPreferences();

    expect(await prefs.getBalanceCategory('u1'), isNull);
    expect(await prefs.getLastTab('u1'), 0);
  });

  test('guarda y recupera el filtro de categoría del balance', () async {
    final prefs = UiPreferences();

    await prefs.saveBalanceCategory('u1', 'Cultura');
    expect(await prefs.getBalanceCategory('u1'), 'Cultura');

    await prefs.saveBalanceCategory('u1', null);
    expect(await prefs.getBalanceCategory('u1'), isNull);
  });

  test('cada cuenta tiene sus propias preferencias', () async {
    final prefs = UiPreferences();

    await prefs.saveBalanceCategory('u1', 'Aventura');
    await prefs.saveLastTab('u1', 3);

    expect(await prefs.getBalanceCategory('u2'), isNull);
    expect(await prefs.getLastTab('u2'), 0);
    expect(await prefs.getLastTab('u1'), 3);
  });
}
