import 'package:drift/drift.dart';

@DataClassName('AnimalNoteRow')
class AnimalNotes extends Table {
    TextColumn get animalId => text()();
    TextColumn get note => text()();
    DateTimeColumn get updatedAt => dateTime()(); 

    BoolColumn get pendingSync => boolean()
        .withDefault(const Constant(true))();

    @override 
    Set<Column> get primaryKey => { animalId };
}
