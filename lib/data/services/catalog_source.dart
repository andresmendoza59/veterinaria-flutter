import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;

import 'package:flutter_app/shared/models/catalog_activity.dart';

abstract class CatalogSource {
  Future<List<CatalogActivity>> fetchCatalog();
}

class CatalogException implements Exception {
  final String message;

  const CatalogException(this.message);

  @override
  String toString() => message;
}

class HttpCatalogSource implements CatalogSource {
  static const String defaultUrl =
      'https://raw.githubusercontent.com/andresmendoza59/veterinaria-flutter/main/mock_api/catalog.json';

  final String url;
  final Duration timeout;
  final http.Client _client;

  HttpCatalogSource({
    this.url = defaultUrl,
    this.timeout = const Duration(seconds: 10),
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<List<CatalogActivity>> fetchCatalog() async {
    try {
      final response = await _client.get(Uri.parse(url)).timeout(timeout);

      if (response.statusCode == 404) {
        throw const CatalogException('No se encontró el catálogo');
      } else if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CatalogException(
          'El servidor respondió con un error (${response.statusCode})',
        );
      }

      try {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((item) =>
                CatalogActivity.fromJson(item as Map<String, dynamic>))
            .toList();
      } on FormatException {
        throw const CatalogException('No se pudo leer el catálogo recibido');
      } on TypeError {
        throw const CatalogException('No se pudo leer el catálogo recibido');
      }
    } on CatalogException {
      rethrow;
    } on TimeoutException {
      throw const CatalogException('El servidor tardó demasiado en responder');
    } on SocketException {
      throw const CatalogException('Sin conexión a internet');
    } on http.ClientException {
      throw const CatalogException('Sin conexión a internet');
    } catch (_) {
      throw const CatalogException('No se pudo cargar el catálogo');
    }
  }
}
