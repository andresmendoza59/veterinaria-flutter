import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias pequeñas de la interfaz guardadas con SharedPreferences.
/// Solo datos sencillos clave-valor: nunca contraseñas, tokens ni listas de
/// actividades (eso va en Drift).
/// Las claves incluyen el uid para que, al cambiar de cuenta, cada usuario
/// conserve sus propias preferencias.
class UiPreferences {
  static String _balanceCategoryKey(String uid) => 'balance_category_$uid';
  static String _lastTabKey(String uid) => 'last_tab_$uid';

  /// Último filtro de categoría usado en el balance. null = "Todas".
  Future<String?> getBalanceCategory(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_balanceCategoryKey(uid));
  }

  Future<void> saveBalanceCategory(String uid, String? category) async {
    final prefs = await SharedPreferences.getInstance();
    if (category == null) {
      await prefs.remove(_balanceCategoryKey(uid));
      return;
    }
    await prefs.setString(_balanceCategoryKey(uid), category);
  }

  /// Última pestaña abierta en la pantalla principal. 0 si no hay ninguna.
  Future<int> getLastTab(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastTabKey(uid)) ?? 0;
  }

  Future<void> saveLastTab(String uid, int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastTabKey(uid), index);
  }
}
