import 'package:drift/drift.dart';

/// Copia local del catálogo HTTP. Permite ver opciones y proponer sin
/// conexión, siempre que el catálogo se haya cargado al menos una vez.
@DataClassName('CatalogOptionRow')
class CatalogOptions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get location => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get estimatedCost => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
