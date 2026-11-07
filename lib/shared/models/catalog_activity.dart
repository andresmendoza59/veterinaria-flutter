class CatalogActivity {
  final String id;
  final String name;
  final String category;
  final String location;
  final String description;
  final int estimatedCost;

  const CatalogActivity({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.estimatedCost,
    this.description = '',
  });

  factory CatalogActivity.fromJson(Map<String, dynamic> json) {
    return CatalogActivity(
      id: json['id'].toString(),
      name: json['name'] as String,
      category: json['category'] as String,
      location: json['location'] as String,
      estimatedCost: (json['estimated_cost'] as num).toInt(),
      description: (json['description'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'location': location,
        'estimated_cost': estimatedCost,
        'description': description,
      };
}
