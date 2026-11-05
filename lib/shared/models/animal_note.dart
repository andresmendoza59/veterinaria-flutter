class AnimalNote {
    final String animalId;
    final String note;
    final DateTime updatedAt;

    const AnimalNote({
        required this.animalId,
        required this.note,
        required this.updatedAt
    });

    factory AnimalNote.fromJson(Map<String, dynamic> json) {
        return AnimalNote(
            animalId: json['animal_id'] as String,
            note: json['note'],
            updatedAt: DateTime.parse(json['updated_at'])
        );
    }

    Map<String, dynamic> toJson() => {
        'animal_id': animalId,
        'note': note,
        'updated_at': updatedAt.toIso8601String()
    };
}
