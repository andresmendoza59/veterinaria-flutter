import 'package:flutter_app/core/app_logger.dart';
import 'package:flutter_app/data/datasources/local/catalog_local_datasource.dart';
import 'package:flutter_app/data/services/catalog_source.dart';
import 'package:flutter_app/shared/models/catalog_activity.dart';

/// Resultado de pedir el catálogo. fromCache = true significa que el servidor
/// no respondió y se muestra la última copia guardada en Drift.
class CatalogResult {
  final List<CatalogActivity> options;
  final bool fromCache;

  const CatalogResult({required this.options, required this.fromCache});
}

/// Punto de entrada al catálogo para las pantallas.
/// Las pantallas no conocen la URL, el paquete http ni Drift: solo le piden
/// datos a este repositorio.
class CatalogRepository {
  final CatalogSource source;
  final CatalogLocalDataSource? local;

  CatalogRepository({required this.source, this.local});

  /// Primero intenta HTTP y guarda la respuesta en Drift.
  /// Si HTTP falla y hay una copia local, devuelve la copia.
  /// Si no hay copia, lanza el mismo CatalogException para mostrar el error.
  Future<CatalogResult> getOptions() async {
    try {
      final options = await source.fetchCatalog();
      await _saveCopy(options);
      return CatalogResult(options: options, fromCache: false);
    } on CatalogException {
      final cached = await _readCopy();
      if (cached.isEmpty) rethrow;
      return CatalogResult(options: cached, fromCache: true);
    }
  }

  /// Categorías únicas del catálogo, en orden alfabético.
  Future<List<String>> getCategories() async {
    final result = await getOptions();
    return extractCategories(result.options);
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

  Future<void> _saveCopy(List<CatalogActivity> options) async {
    final store = local;
    if (store == null) return;
    try {
      await store.replaceAll(options);
    } catch (error) {
      // No guardar la copia no impide mostrar el catálogo recién descargado.
      AppLogger.warning('[Catálogo] no se pudo guardar la copia local');
    }
  }

  Future<List<CatalogActivity>> _readCopy() async {
    final store = local;
    if (store == null) return <CatalogActivity>[];
    return store.getAll();
  }
}
