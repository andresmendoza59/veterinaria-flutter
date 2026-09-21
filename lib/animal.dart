class Animal {
  String id;
  String name;
  String species;
  int age;
  String race;
  double weight;
  bool isAttended;
  String imagePath;

  Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.age,
    required this.race,
    required this.weight,
    required this.isAttended,
    required this.imagePath
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
        id: json['id'],
        name: json['name'],
        species: json['species'],
        age: json['age'],
        race: json['race'],
        weight: json['weight'],
        isAttended: json['is_attended'],
        imagePath: json['image_path']
    );
  }
}


