import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/shared/models/member_preference.dart';

/// Conoce Firestore: lee y guarda documentos de la colección preferences.
class PreferenceRemoteDataSource {
  final FirebaseFirestore firestore;

  PreferenceRemoteDataSource(this.firestore);

  static const Duration _timeout = Duration(seconds: 15);

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('preferences');

  Future<List<MemberPreference>> fetchAll() async {
    final snapshot = await _collection.get().timeout(_timeout);
    final result = <MemberPreference>[];
    for (final doc in snapshot.docs) {
      result.add(MemberPreference.fromJson(doc.data()));
    }
    return result;
  }

  /// Un documento por miembro con su uid como id: guardar dos veces no
  /// duplica, solo reemplaza.
  Future<void> save(MemberPreference preference) {
    return _collection
        .doc(preference.uid)
        .set(preference.toJson())
        .timeout(_timeout);
  }
}
