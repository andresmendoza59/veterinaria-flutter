import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/core/app_logger.dart';
import 'package:flutter_app/core/itinerary_exceptions.dart';
import 'package:flutter_app/data/datasources/remote/preference_remote_datasource.dart';
import 'package:flutter_app/shared/models/member_preference.dart';
import 'package:flutter_app/validators/preference_rules.dart';

/// Lo que muestra la vista de preferencias: las mías y el resumen del grupo.
class PreferencesSummary {
  final MemberPreference? mine;
  final List<CategoryCount> groupCounts;
  final int membersWithPreferences;

  const PreferencesSummary({
    required this.mine,
    required this.groupCounts,
    required this.membersWithPreferences,
  });
}

/// Coordina las preferencias de los miembros. Las preferencias se comparten
/// con todo el viaje, por eso viven en Firestore y se consultan online.
class PreferenceRepository {
  final PreferenceRemoteDataSource remote;

  PreferenceRepository({required this.remote});

  Future<PreferencesSummary> loadSummary(String uid) async {
    final all = await remote.fetchAll();
    final mine = _findMine(all, uid);
    return PreferencesSummary(
      mine: mine,
      groupCounts: PreferenceRules.countByCategory(all),
      membersWithPreferences: all.length,
    );
  }

  Future<void> save({
    required String uid,
    required List<String> categories,
    required String note,
  }) async {
    final categoriesError = PreferenceRules.validateCategories(categories);
    if (categoriesError != null) {
      throw ItineraryException(categoriesError);
    }
    final noteError = PreferenceRules.validateNote(note);
    if (noteError != null) {
      throw ItineraryException(noteError);
    }

    final preference = MemberPreference(
      uid: uid,
      favoriteCategories: categories,
      note: note.trim(),
      updatedAt: DateTime.now(),
    );

    try {
      await remote.save(preference);
    } on FirebaseException catch (error) {
      AppLogger.warning('[Preferencias] ${error.code}');
      throw ItineraryException(_friendlyMessage(error.code));
    } catch (_) {
      throw const ItineraryException(
        'No se pudieron guardar tus preferencias. Revisa tu conexión',
      );
    }
  }

  MemberPreference? _findMine(List<MemberPreference> all, String uid) {
    for (final preference in all) {
      if (preference.uid == uid) {
        return preference;
      }
    }
    return null;
  }

  String _friendlyMessage(String code) {
    if (code == 'permission-denied') {
      return 'Tu rol no permite guardar preferencias';
    }
    return 'No se pudieron guardar tus preferencias. Revisa tu conexión';
  }
}
