import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_app/data/datasources/local/app_database.dart';
import 'package:flutter_app/data/datasources/local/catalog_local_datasource.dart';
import 'package:flutter_app/data/repositories/catalog_repository.dart';
import 'package:flutter_app/data/services/catalog_source.dart';
import 'package:flutter_app/shared/models/catalog_activity.dart';
import 'package:flutter_test/flutter_test.dart';

/// Catálogo falso: devuelve la lista configurada o falla como si no hubiera red.
class FakeCatalogSource implements CatalogSource {
  List<CatalogActivity> options = [];
  bool offline = false;

  @override
  Future<List<CatalogActivity>> fetchCatalog() async {
    if (offline) {
      throw const CatalogException('Sin conexión a internet');
    }
    return options;
  }
}

const CatalogActivity _museum = CatalogActivity(
  id: 'cat-04',
  name: 'Museo del Cafe',
  category: 'Cultura',
  location: 'Armenia',
  estimatedCost: 60000,
);

const CatalogActivity _jeep = CatalogActivity(
  id: 'cat-10',
  name: 'Tour en jeep',
  category: 'Transporte',
  location: 'Salento',
  estimatedCost: 70000,
);

void main() {
  late AppDatabase db;
  late FakeCatalogSource source;
  late CatalogRepository repo;

  setUpAll(() {
    // Cada prueba abre su propia base en memoria; se evita el aviso de Drift.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    source = FakeCatalogSource();
    repo = CatalogRepository(source: source, local: CatalogLocalDataSource(db));
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'con internet devuelve el catálogo y guarda una copia en Drift',
    () async {
      source.options = [_museum, _jeep];

      final result = await repo.getOptions();
      final copy = await CatalogLocalDataSource(db).getAll();

      expect(result.fromCache, isFalse);
      expect(result.options.length, 2);
      expect(copy.length, 2);
    },
  );

  test('sin internet devuelve la última copia y lo avisa', () async {
    source.options = [_museum, _jeep];
    await repo.getOptions();

    source.offline = true;
    final result = await repo.getOptions();

    expect(result.fromCache, isTrue);
    expect(result.options.first.name, 'Museo del Cafe');
  });

  test('sin internet y sin copia se muestra el error original', () async {
    source.offline = true;

    expect(repo.getOptions(), throwsA(isA<CatalogException>()));
  });

  test('una descarga nueva reemplaza la copia anterior', () async {
    source.options = [_museum, _jeep];
    await repo.getOptions();

    source.options = [_jeep];
    await repo.getOptions();
    final copy = await CatalogLocalDataSource(db).getAll();

    expect(copy.length, 1);
    expect(copy.first.id, 'cat-10');
  });
}
