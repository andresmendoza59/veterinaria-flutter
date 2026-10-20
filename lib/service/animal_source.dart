import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import 'package:flutter_app/model/animal.dart';

/// Where the app gets its animal list from.
///
/// The bundled asset is the default source so the UI works everywhere,
/// including the web, where calling a third-party API from the browser is
/// subject to CORS. Swap in an HTTP-backed implementation when a real
/// backend is available; the rest of the app only sees `List<Animal>`.
abstract class AnimalSource {
  Future<List<Animal>> fetchAnimals();
}

/// Reads the animal list from a JSON asset shipped with the app.
class AssetAnimalSource implements AnimalSource {
  final String assetPath;

  const AssetAnimalSource({this.assetPath = 'assets/data/animals.json'});

  @override
  Future<List<Animal>> fetchAnimals() async {
    final raw = await rootBundle.loadString(assetPath);

    try {
      final List<dynamic> data = jsonDecode(raw);
      return data
          .map((item) => Animal.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException catch (e) {
      throw DecodeException(e);
    } on TypeError catch (e) {
      throw DecodeException(e);
    }
  }
}

/// Raised when the animal payload can't be understood.
class DecodeException implements Exception {
  final Object error;

  const DecodeException(this.error);

  @override
  String toString() => "Couldn't read the animals from the response: $error";
}

/// Fetches the animal list from an HTTP endpoint.
///
/// Not suitable for the web: the browser applies CORS to the response, so the
/// server must allow the app's origin. Used on native platforms.
class HttpAnimalSource implements AnimalSource {
  final String baseUrl;
  final http.Client _client;

  HttpAnimalSource({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<Animal>> fetchAnimals() async {
    final response = await _client.get(Uri.parse('$baseUrl/animals'));

    if (response.statusCode == 404) {
      throw const ApiException("Couldn't find animals");
    } else if (response.statusCode == 500) {
      throw const ApiException('Internal server error');
    } else if (response.statusCode == 400) {
      throw const ApiException('Bad request sent');
    } else if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Unexpected response (${response.statusCode})');
    }

    try {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => Animal.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException catch (e) {
      throw DecodeException(e);
    } on TypeError catch (e) {
      throw DecodeException(e);
    }
  }
}

/// Raised for HTTP-level failures.
class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}
