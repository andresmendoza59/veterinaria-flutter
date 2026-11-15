import 'dart:async';
import 'dart:io';

import 'package:flutter_app/data/repositories/catalog_repository.dart';
import 'package:flutter_app/data/services/catalog_source.dart';
import 'package:flutter_app/shared/models/catalog_activity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const String _twoOptionsJson = '''
[
  {"id": "cat-01", "name": "Parapente", "category": "Aventura",
   "location": "Salento", "estimated_cost": 180000},
  {"id": "cat-03", "name": "Recorrido", "category": "Cultura",
   "location": "Aguadulce", "estimated_cost": 45000, "description": "Paseo"}
]
''';

// Crea un HttpCatalogSource que no sale a internet: responde lo que le digamos.
HttpCatalogSource _sourceAnswering(String body, int statusCode) {
  final client = MockClient((request) async {
    return http.Response(body, statusCode);
  });
  return HttpCatalogSource(client: client);
}

HttpCatalogSource _sourceThrowing(Object error) {
  final client = MockClient((request) async {
    throw error;
  });
  return HttpCatalogSource(client: client);
}

Future<String> _errorMessageOf(HttpCatalogSource source) async {
  try {
    await source.fetchCatalog();
    return 'sin error';
  } on CatalogException catch (error) {
    return error.message;
  }
}

void main() {
  test('HTTP exitoso: convierte el JSON en modelos CatalogActivity', () async {
    final source = _sourceAnswering(_twoOptionsJson, 200);

    final options = await source.fetchCatalog();

    expect(options.length, 2);
    expect(options.first.name, 'Parapente');
    expect(options.first.estimatedCost, 180000);
    expect(options.first.description, '');
    expect(options.last.description, 'Paseo');
  });

  test('HTTP vacío: una lista vacía no es un error', () async {
    final source = _sourceAnswering('[]', 200);

    final options = await source.fetchCatalog();

    expect(options, isEmpty);
  });

  test('código HTTP no exitoso muestra un mensaje entendible', () async {
    final notFound = await _errorMessageOf(_sourceAnswering('', 404));
    final serverError = await _errorMessageOf(_sourceAnswering('', 500));

    expect(notFound, 'No se encontró el catálogo');
    expect(serverError, 'El servidor respondió con un error (500)');
  });

  test('JSON inválido o con campos faltantes no rompe la app', () async {
    final brokenJson = await _errorMessageOf(_sourceAnswering('{oops', 200));
    final missingField = await _errorMessageOf(
      _sourceAnswering('[{"id": "x"}]', 200),
    );

    expect(brokenJson, 'No se pudo leer el catálogo recibido');
    expect(missingField, 'No se pudo leer el catálogo recibido');
  });

  test('sin conexión y timeout se traducen a mensajes claros', () async {
    final offline = await _errorMessageOf(
      _sourceThrowing(const SocketException('sin red')),
    );
    final slow = await _errorMessageOf(
      _sourceThrowing(TimeoutException('lento')),
    );

    expect(offline, 'Sin conexión a internet');
    expect(slow, 'El servidor tardó demasiado en responder');
  });

  test('CatalogRepository extrae categorías únicas y ordenadas', () {
    const options = [
      CatalogActivity(
        id: '1',
        name: 'A',
        category: 'Cultura',
        location: 'X',
        estimatedCost: 1,
      ),
      CatalogActivity(
        id: '2',
        name: 'B',
        category: 'Aventura',
        location: 'Y',
        estimatedCost: 2,
      ),
      CatalogActivity(
        id: '3',
        name: 'C',
        category: 'Cultura',
        location: 'Z',
        estimatedCost: 3,
      ),
    ];

    final categories = CatalogRepository.extractCategories(options);

    expect(categories, ['Aventura', 'Cultura']);
  });
}
