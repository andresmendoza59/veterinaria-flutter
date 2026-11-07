import 'package:flutter_app/shared/models/user_role.dart';

class UserProfile {
  final String uid;
  final UserRole role;
  final DateTime createdAt;

  const UserProfile({
    required this.uid,
    required this.role,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      role: UserRole.fromValue(json['role'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'role': role.value,
    'created_at': createdAt.toIso8601String(),
  };
}
