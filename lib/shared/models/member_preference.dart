/// Preferencias de un miembro del viaje: qué tipo de actividades le gustan y
/// un comentario libre. Se guardan en Firestore (colección preferences, un
/// documento por uid) para que coordinación y el grupo puedan consultarlas.
class MemberPreference {
  final String uid;
  final List<String> favoriteCategories;
  final String note;
  final DateTime updatedAt;

  const MemberPreference({
    required this.uid,
    required this.favoriteCategories,
    required this.note,
    required this.updatedAt,
  });

  factory MemberPreference.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['favorite_categories'] as List<dynamic>;
    final categories = <String>[];
    for (final item in rawCategories) {
      categories.add(item as String);
    }

    return MemberPreference(
      uid: json['uid'] as String,
      favoriteCategories: categories,
      note: json['note'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'favorite_categories': favoriteCategories,
    'note': note,
    'updated_at': updatedAt.toIso8601String(),
  };
}
