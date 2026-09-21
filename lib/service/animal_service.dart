import 'dart:convert';

import 'package:http/http.dart' as http;
import '../animal.dart';

class AnimalService {
    final String baseUrl;

    AnimalService({required this.baseUrl});

    Future<List<Animal>> getAnimals() async {
        final response = await http.get(Uri.parse("$baseUrl/animals"));

        if (response.statusCode != 200) {
            throw Exception("Couldn't get animals");
        }

        final List<dynamic> data = jsonDecode(response.body);

        return data.map((item) => Animal.fromJson(item)).toList();
    }
}
