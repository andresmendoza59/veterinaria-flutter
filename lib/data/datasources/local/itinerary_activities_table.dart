import 'package:drift/drift.dart';

@DataClassName('ItineraryActivityRow')
class ItineraryActivities extends Table {
  TextColumn get id => text()();
  TextColumn get ownerUid => text()();
  TextColumn get catalogId => text()();
  TextColumn get title => text()();
  TextColumn get category => text()();
  TextColumn get location => text()();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime()();
  IntColumn get estimatedCost => integer()();
  TextColumn get status => text()();
  TextColumn get slotId => text().withDefault(const Constant(''))();
  IntColumn get reservedCost => integer().withDefault(const Constant(0))();
  IntColumn get realCost => integer().withDefault(const Constant(0))();
  TextColumn get reason => text().withDefault(const Constant(''))();
  BoolColumn get returnRequested =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();
  TextColumn get syncError => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
