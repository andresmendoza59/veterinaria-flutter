import 'package:flutter_app/data/services/catalog_source.dart';
import 'package:flutter_app/shared/models/catalog_activity.dart';

/// Punto de entrada al catálogo HTTP para las pantallas.
/// Las pantallas no conocen la URL ni el paquete http: solo le piden datos
/// a este repositorio.
class CatalogRepository {
  final CatalogSource source;

  CatalogRepository({required this.source});

  Future<List<CatalogActivity>> getOptions() {
    return source.fetchCatalog();
  }

  /// Categorías únicas del catálogo, en orden alfabético.
  Future<List<String>> getCategories() async {
    final options = await source.fetchCatalog();
    return extractCategories(options);
  }

  static List<String> extractCategories(List<CatalogActivity> options) {
    final categories = <String>{};
    for (final option in options) {
      categories.add(option.category);
    }
    final result = categories.toList();
    result.sort();
    return result;
  }
}
