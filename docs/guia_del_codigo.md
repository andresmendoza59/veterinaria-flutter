# Guía del código para la sustentación

Esta guía recorre cada flujo importante de la app y dice por qué archivos y funciones pasa. Sirve para que cualquier integrante pueda explicarlo en voz alta y hacer una modificación en vivo.

Regla general: **pantalla → repositorio → fuente de datos** (Drift, Firestore o HTTP). Las reglas de negocio están en `lib/validators/` y no dependen de Firebase.

---

## 1. Arranque y sesión

1. `lib/main.dart` → `main()`: inicia Firebase, configura `CrashService`, crea la base Drift (`AppDatabase`), los repositorios y `UiPreferences`. Todo se pasa por constructor; no hay `get_it` ni Provider.
2. `AuthGate` (en `main.dart`): un `StreamBuilder` escucha `authStateChanges()`.
   - Sin usuario → `LoginPage` (`lib/features/auth/presentation/screens/login_page.dart`).
   - Con usuario → `ProfileGate`, que lee o crea `users/{uid}` con el rol `member`, y luego `ItineraryHomeScreen`.
3. Cerrar sesión solo llama a `authService.logout()`. El stream cambia y `AuthGate` vuelve a mostrar el login; no se navega a mano.

## 2. Pestañas según el rol

`ItineraryHomeScreen._buildTabs()` usa un `switch` sobre `widget.role` para decidir qué pestañas ve cada rol. La última pestaña abierta se guarda con `UiPreferences.saveLastTab` (SharedPreferences).

## 3. Proponer una actividad (local-first)

| Paso | Archivo → función |
|---|---|
| Ver el catálogo | `OptionsScreen` → `CatalogRepository.getOptions()`. Primero intenta HTTP (`HttpCatalogSource.fetchCatalog`) y guarda una copia en Drift (`CatalogLocalDataSource.replaceAll`). Si no hay red, usa esa copia. |
| Elegir día, franja y costo | `ProposalFormScreen._save()`. Los validadores salen de `ItineraryRules`. |
| Guardar | `ItineraryRepository.createProposal()` valida la regla 1 (`_validate`), guarda en Drift con `pendingSync = true` (`local.upsert`) y luego intenta enviar (`_pushBestEffort`). |
| Enviar | `_syncOne()` → `ItineraryRemoteDataSource.pushProposal()`: una transacción que no pisa una actividad que otro rol ya procesó. |
| Marcar sincronizada | `ItineraryLocalDataSource.markSynced(id, sentUpdatedAt)`: solo si `updated_at` sigue siendo el mismo que se envió. |
| Reintentar | Botón Sincronizar → `ItineraryRepository.syncPending(uid)`. Solo envía los pendientes de ese usuario (`getQueued`). |

## 4. Decisiones online (transacciones)

Todas siguen el mismo camino: **pantalla → `ItineraryRepository.X()` → `_decide()` → `ItineraryRemoteDataSource.X()`**. Dentro de `firestore.runTransaction`, cada una:
1. lee la actividad actual (`_load`);
2. revisa rol, dueño y estado con `ItineraryRules.checkAction` (`_ensure` lanza el error si no se cumple);
3. escribe los cambios (`_apply`).

| Decisión | Pantalla | Qué más hace la transacción |
|---|---|---|
| Aprobar horario | `ScheduleApprovalScreen` | Lee `slots/{slotId}`; si ya está ocupada, la rechaza (regla 2 y escenario 1). |
| Rechazar | `ScheduleApprovalScreen` | Guarda el motivo. |
| Marcar realizada | `ScheduleApprovalScreen` | — |
| Cancelar | `ScheduleApprovalScreen` | Borra la franja y resta la reserva de `budget/trip` (escenario 3). |
| Aprobar costo | `FinanceReviewScreen` | Lee `budget/trip` y aplica `checkReserve` (regla 3 y escenario 2). |
| Rechazar costo | `FinanceReviewScreen` | Devuelve a `PROPUESTA` y libera la franja. |
| Cerrar costo | `FinanceReviewScreen` | `checkCloseCost` (regla 5); cambia la reserva por el gasto real. |

Si dos personas deciden al mismo tiempo, Firestore repite la transacción con los datos nuevos, y por eso la segunda ve la franja o el presupuesto ya ocupados.

## 5. Vistas que leen datos compartidos

`ItineraryScreen`, `ScheduleApprovalScreen`, `FinanceReviewScreen` y `BalanceScreen` llaman a `ItineraryRepository.loadShared(uid)`:
1. `tryRefreshFromRemote()` trae Firestore y actualiza Drift (`applyRemote`, que no pisa los pendientes locales);
2. lee de Drift y aplica `ActivityFilters.visibleFor` (no muestra pendientes de otra cuenta);
3. devuelve `fromCache = true` si Firestore falló, y la pantalla muestra `LocalDataBanner`.

Después, cada pantalla filtra con `ActivityFilters`: `forCoordinator`, `forFinance`, `forItinerary` o `forBalance`.

## 6. Balance

`BalanceScreen._buildContent()`:
- `ItineraryRules.summarize(...)` calcula el total, lo reservado, lo gastado y el saldo;
- `_applyFilters()` aplica `byCategory`, `byDay` y `byStatus`, uno detrás de otro;
- el filtro de categoría se guarda con `UiPreferences.saveBalanceCategory(uid, ...)`.

## 7. Dónde hacer modificaciones típicas en vivo

| Si piden… | Dónde se cambia |
|---|---|
| Cambiar el presupuesto, las fechas o las horas de las franjas | `lib/core/trip_config.dart` (y el límite `2000000` en `firestore.rules`). |
| Agregar una regla de negocio | Una función pura en `lib/validators/itinerary_rules.dart`, una prueba en `test/` y la llamada en el repositorio o en la transacción. |
| Agregar un estado nuevo | `ActivityStatus` (`lib/shared/models/activity_status.dart`): valor y `label`. Luego `_requiredStatus` y `nextStatus` en `ItineraryRules` y las reglas en `firestore.rules`. |
| Agregar un campo a la actividad | Modelo `ItineraryActivity` (constructor, `copyWith`, `fromJson`, `toJson`), la tabla en `itinerary_activities_table.dart`, subir `schemaVersion` con su migración en `app_database.dart`, `dart run build_runner build`, y la lista `activityKeys()` en `firestore.rules`. |
| Guardar otra preferencia sencilla | Un par de métodos `get`/`save` en `lib/data/services/ui_preferences.dart`, con el uid en la clave. |
| Agregar un filtro al balance | Una función en `ActivityFilters`, una variable de estado y un `DropdownButton` en `BalanceScreen`. |
| Cambiar un mensaje de error de login | `_mapFirebaseError` en `login_page.dart`. |
| Agregar una pestaña | Un método `_xTab()` en `ItineraryHomeScreen` y agregarlo en `_buildTabs()`. |

## 8. Cómo correr las verificaciones

```bash
flutter analyze
flutter test
```

Las pruebas de `test/itinerary_local_first_test.dart` y `test/catalog_repository_test.dart` usan una base Drift en memoria (`AppDatabase.forTesting(NativeDatabase.memory())`). Así se prueba lo local-first sin Firebase.
