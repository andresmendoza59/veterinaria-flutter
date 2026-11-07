import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/data/datasources/remote/user_profile_remote_datasource.dart';
import 'package:flutter_app/shared/models/user_profile.dart';
import 'package:flutter_app/shared/models/user_role.dart';

class UserProfileRepository {
  final UserProfileRemoteDataSource remote;

  UserProfileRepository({required this.remote});

  Future<UserProfile> ensureProfile(String uid) async {
    final existing = await remote.fetchProfile(uid);
    if (existing != null) return existing;
    try {
      await remote.createMemberProfile(uid);
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') rethrow;
      final current = await remote.fetchProfile(uid);
      if (current == null) rethrow;
      return current;
    }
    return UserProfile(
      uid: uid,
      role: UserRole.member,
      createdAt: DateTime.now(),
    );
  }

  Future<UserRole> getRole(String uid) async {
    final profile = await remote.fetchProfile(uid);
    return profile?.role ?? UserRole.member;
  }
}
