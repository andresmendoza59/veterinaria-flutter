import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:flutter_app/model/animal.dart';

class AnimalService {
    final String baseUrl;

    AnimalService({required this.baseUrl});

    Future<List<Animal>> getAnimals() async {
        try {
            final response = await http.get(Uri.parse("$baseUrl/animals"));

            if (response.statusCode == 404) {
                throw const ApiException("Couldn't find animals");
            } else if (response.statusCode == 500) {
                throw const ApiException("Internal server error");
            } else if (response.statusCode == 400) {
                throw const ApiException("Bad request sent");
            }

            final List<dynamic> data = jsonDecode(response.body);

            return data.map((item) => Animal.fromJson(item)).toList();
        } on TimeoutException {
            throw const ApiException("It took too much time to respond");
        }
    }
}

class ApiException implements Exception {
    final String message;

    const ApiException(this.message);

    @override
    String toString() => message;
} 
