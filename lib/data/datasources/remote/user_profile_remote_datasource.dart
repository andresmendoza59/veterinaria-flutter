import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/shared/models/user_profile.dart';

class UserProfileRemoteDataSource {
  final FirebaseFirestore firestore;

  UserProfileRemoteDataSource(this.firestore);

  Future<UserProfile?> fetchProfile(String uid) async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .get()
        .timeout(const Duration(seconds: 15));
    final data = snapshot.data();
    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  Future<void> createMemberProfile(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .set({
          'uid': uid,
          'role': 'member',
          'created_at': DateTime.now().toIso8601String(),
        })
        .timeout(const Duration(seconds: 15));
  }
}
