import 'package:flutter_app/shared/models/member_preference.dart';
import 'package:flutter_app/validators/preference_rules.dart';
import 'package:flutter_test/flutter_test.dart';

MemberPreference _pref(String uid, List<String> categories) {
  return MemberPreference(
    uid: uid,
    favoriteCategories: categories,
    note: '',
    updatedAt: DateTime(2027, 1, 10),
  );
}

void main() {
  test('categorías: al menos una y máximo tres', () {
    expect(
      PreferenceRules.validateCategories([]),
      'Elige al menos una categoría',
    );
    expect(PreferenceRules.validateCategories(['Cultura']), isNull);
    expect(
      PreferenceRules.validateCategories(['A', 'B', 'C', 'D']),
      'Elige máximo 3 categorías',
    );
  });

  test('la nota es opcional y tiene un límite de 200 caracteres', () {
    expect(PreferenceRules.validateNote(null), isNull);
    expect(PreferenceRules.validateNote(''), isNull);
    expect(PreferenceRules.validateNote('a' * 200), isNull);
    expect(PreferenceRules.validateNote('a' * 201), isNotNull);
  });

  test('countByCategory cuenta miembros y ordena de mayor a menor', () {
    final prefs = [
      _pref('u1', ['Cultura', 'Aventura']),
      _pref('u2', ['Aventura']),
      _pref('u3', ['Descanso', 'Aventura', 'Cultura']),
    ];

    final counts = PreferenceRules.countByCategory(prefs);

    expect(counts.length, 3);
    expect(counts[0].category, 'Aventura');
    expect(counts[0].members, 3);
    expect(counts[1].category, 'Cultura');
    expect(counts[1].members, 2);
    expect(counts[2].category, 'Descanso');
    expect(counts[2].members, 1);
  });

  test('MemberPreference ida y vuelta por JSON', () {
    final original = MemberPreference(
      uid: 'u1',
      favoriteCategories: ['Cultura'],
      note: 'Prefiero mañanas',
      updatedAt: DateTime(2027, 1, 10, 9),
    );

    final copy = MemberPreference.fromJson(original.toJson());

    expect(copy.uid, 'u1');
    expect(copy.favoriteCategories, ['Cultura']);
    expect(copy.note, 'Prefiero mañanas');
    expect(copy.updatedAt, DateTime(2027, 1, 10, 9));
  });

  test('si falta un campo obligatorio el JSON se rechaza', () {
    expect(
      () => MemberPreference.fromJson({'uid': 'u1'}),
      throwsA(isA<TypeError>()),
    );
  });
}
