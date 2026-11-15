import 'package:drift/drift.dart';
import 'package:flutter_app/data/datasources/local/app_database.dart';
import 'package:flutter_app/shared/models/catalog_activity.dart';

/// Conoce Drift: guarda y lee la copia local del catálogo HTTP.
class CatalogLocalDataSource {
  final AppDatabase db;

  CatalogLocalDataSource(this.db);

  CatalogActivity _toDomain(CatalogOptionRow row) {
    return CatalogActivity(
      id: row.id,
      name: row.name,
      category: row.category,
      location: row.location,
      description: row.description,
      estimatedCost: row.estimatedCost,
    );
  }

  Future<List<CatalogActivity>> getAll() async {
    final query = db.select(db.catalogOptions)
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);
    final rows = await query.get();

    final result = <CatalogActivity>[];
    for (final row in rows) {
      result.add(_toDomain(row));
    }
    return result;
  }

  /// Reemplaza la copia local por la lista recién descargada.
  /// Se hace en una transacción para no dejar el catálogo a medias.
  Future<void> replaceAll(List<CatalogActivity> options) async {
    await db.transaction(() async {
      await db.delete(db.catalogOptions).go();
      for (final option in options) {
        await db
            .into(db.catalogOptions)
            .insertOnConflictUpdate(
              CatalogOptionsCompanion.insert(
                id: option.id,
                name: option.name,
                category: option.category,
                location: option.location,
                description: Value(option.description),
                estimatedCost: option.estimatedCost,
              ),
            );
      }
    });
  }
}
