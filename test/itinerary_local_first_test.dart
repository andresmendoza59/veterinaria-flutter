import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_app/core/itinerary_exceptions.dart';
import 'package:flutter_app/data/datasources/local/app_database.dart';
import 'package:flutter_app/data/datasources/local/itinerary_local_datasource.dart';
import 'package:flutter_app/data/repositories/itinerary_repository.dart';
import 'package:flutter_app/shared/models/activity_status.dart';
import 'package:flutter_app/shared/models/catalog_activity.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';
import 'package:flutter_test/flutter_test.dart';

// Pruebas de la estrategia local-first con una base Drift en memoria.
// El repositorio se crea sin Firestore (remote: null), como si no hubiera
// conexión: así se prueba lo que pasa en el teléfono antes de sincronizar.

const CatalogActivity _option = CatalogActivity(
  id: 'cat-03',
  name: 'Recorrido por el pueblo',
  category: 'Cultura',
  location: 'Aguadulce',
  estimatedCost: 45000,
);

final DateTime _validSlot = DateTime(2027, 2, 1, 8);

void main() {
  late AppDatabase db;
  late ItineraryLocalDataSource local;
  late ItineraryRepository repo;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    local = ItineraryLocalDataSource(db);
    repo = ItineraryRepository(local: local);
  });

  tearDown(() async {
    await db.close();
  });

  Future<ItineraryActivity> propose(String uid) {
    return repo.createProposal(
      ownerUid: uid,
      option: _option,
      startAt: _validSlot,
      estimatedCost: 45000,
    );
  }

  test('proponer sin conexión guarda en Drift como pendiente', () async {
    final saved = await propose('miembro-1');

    final mine = await repo.getMine('miembro-1');

    expect(mine.length, 1);
    expect(mine.first.id, saved.id);
    expect(mine.first.status, ActivityStatus.proposed);
    expect(mine.first.pendingSync, isTrue);
    expect(mine.first.syncState, SyncState.queued);
    expect(mine.first.slotId, '', reason: 'pendiente no ocupa franja');
  });

  test('la regla 1 se valida antes de guardar', () async {
    final outsideTrip = repo.createProposal(
      ownerUid: 'miembro-1',
      option: _option,
      startAt: DateTime(2027, 3, 1, 8),
      estimatedCost: 45000,
    );

    await expectLater(outsideTrip, throwsA(isA<ItineraryException>()));
    expect(await repo.getMine('miembro-1'), isEmpty);
  });

  test(
    'cambio de cuenta: solo se envían los pendientes del usuario actual',
    () async {
      await propose('miembro-1');
      await propose('miembro-2');

      final queuedForSecond = await local.getQueued('miembro-2');
      final shared = await repo.loadShared(uid: 'miembro-2');

      expect(queuedForSecond.length, 1);
      expect(queuedForSecond.first.ownerUid, 'miembro-2');
      expect(shared.items.length, 1, reason: 'no ve pendientes de miembro-1');
    },
  );

  test(
    'una respuesta vieja no marca sincronizada una edición más reciente',
    () async {
      final sent = await propose('miembro-1');
      // Mientras el envío viajaba, el miembro editó la propuesta.
      final edited = await repo.editProposal(
        uid: 'miembro-1',
        activity: sent,
        startAt: DateTime(2027, 2, 1, 10),
        estimatedCost: 50000,
      );

      final markedOld = await local.markSynced(
        id: sent.id,
        sentUpdatedAt: sent.updatedAt,
      );
      final stillPending = await local.getById(sent.id);
      final markedNew = await local.markSynced(
        id: edited.id,
        sentUpdatedAt: edited.updatedAt,
      );

      expect(markedOld, isFalse);
      expect(stillPending?.pendingSync, isTrue);
      expect(markedNew, isTrue);
    },
  );

  test(
    'un rechazo del servidor queda como evidencia y no se reenvía',
    () async {
      final sent = await propose('miembro-1');

      await local.markRejected(
        id: sent.id,
        sentUpdatedAt: sent.updatedAt,
        error: 'La actividad ya fue procesada',
      );
      final row = await local.getById(sent.id);
      final queued = await local.getQueued('miembro-1');

      expect(row?.syncState, SyncState.rejected);
      expect(row?.syncError, 'La actividad ya fue procesada');
      expect(queued, isEmpty);
    },
  );

  test('regla 4: no se edita después de la aprobación de horario', () async {
    final sent = await propose('miembro-1');
    final approved = sent.copyWith(
      status: ActivityStatus.scheduleApproved,
      pendingSync: false,
    );
    await local.upsert(approved);

    final edit = repo.editProposal(
      uid: 'miembro-1',
      activity: approved,
      startAt: DateTime(2027, 2, 1, 12),
      estimatedCost: 45000,
    );

    await expectLater(edit, throwsA(isA<ItineraryException>()));
  });

  test('descartar borra solo cambios pendientes del dueño', () async {
    final sent = await propose('miembro-1');

    final otherUser = repo.discard(id: sent.id, uid: 'miembro-2');
    await expectLater(otherUser, throwsA(isA<ItineraryException>()));

    await repo.discard(id: sent.id, uid: 'miembro-1');
    expect(await repo.getMine('miembro-1'), isEmpty);
  });

  test('traer datos del servidor no pisa un pendiente local', () async {
    final pending = await propose('miembro-1');
    final remoteVersion = pending.copyWith(
      status: ActivityStatus.rejected,
      pendingSync: false,
    );

    await local.applyRemote([remoteVersion]);
    final row = await local.getById(pending.id);

    expect(row?.status, ActivityStatus.proposed);
    expect(row?.pendingSync, isTrue);
  });
}
