import 'package:flutter_app/shared/models/member_preference.dart';

/// Cuántos miembros eligieron una categoría como favorita.
class CategoryCount {
  final String category;
  final int members;

  const CategoryCount({required this.category, required this.members});
}

/// Reglas puras de las preferencias de los miembros.
class PreferenceRules {
  PreferenceRules._();

  static const int maxNoteLength = 200;
  static const int maxCategories = 3;

  static String? validateCategories(List<String> categories) {
    if (categories.isEmpty) {
      return 'Elige al menos una categoría';
    }
    if (categories.length > maxCategories) {
      return 'Elige máximo $maxCategories categorías';
    }
    return null;
  }

  /// La nota es opcional, pero no puede ser muy larga.
  static String? validateNote(String? value) {
    final text = value?.trim() ?? '';
    if (text.length > maxNoteLength) {
      return 'La nota no puede superar los $maxNoteLength caracteres';
    }
    return null;
  }

  /// Cuenta cuántos miembros eligieron cada categoría y ordena de la más
  /// votada a la menos votada (si empatan, por orden alfabético).
  static List<CategoryCount> countByCategory(List<MemberPreference> prefs) {
    final counts = <String, int>{};
    for (final pref in prefs) {
      for (final category in pref.favoriteCategories) {
        final current = counts[category] ?? 0;
        counts[category] = current + 1;
      }
    }

    final result = <CategoryCount>[];
    for (final category in counts.keys) {
      result.add(CategoryCount(category: category, members: counts[category]!));
    }
    result.sort(_compareCounts);
    return result;
  }

  static int _compareCounts(CategoryCount a, CategoryCount b) {
    if (a.members != b.members) {
      return b.members.compareTo(a.members);
    }
    return a.category.compareTo(b.category);
  }
}
