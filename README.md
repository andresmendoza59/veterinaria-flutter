# G62-7 · Itinerario colaborativo con presupuesto

Proyecto final de **Desarrollo de Aplicaciones Móviles**, Universidad de Medellín, semestre 2026-2, grupo G62.

**Integrantes (trío):** Andrés Felipe Mendoza Henao · Luis Miguel Giraldo Hurtado · Santiago González Marín

**Versión:** `1.0.0+1` (definida en `pubspec.yaml`)

Aplicación Flutter para organizar un viaje académico ficticio, **"Escapada Eje Cafetero"** (del 1 al 5 de febrero de 2027), a partir de propuestas de actividades. La coordinación aprueba los horarios y un responsable financiero revisa el presupuesto, que es fijo: **$2.000.000 COP**.

---

## 1. Roles

| Rol | Valor en Firestore | Qué hace en la app |
|---|---|---|
| Miembro del viaje | `member` | Consulta opciones (catálogo HTTP), propone actividades (se guardan primero en Drift), edita sus propuestas mientras siguen en `PROPUESTA`, pide devolución, registra preferencias y consulta itinerario y balance. |
| Coordinador del viaje | `coordinator` | Aprueba horarios (ocupa la franja), rechaza propuestas, marca actividades como realizadas y cancela las confirmadas antes de que empiecen. |
| Responsable de presupuesto | `finance` | Aprueba el costo previsto (reserva presupuesto) o lo rechaza devolviendo la actividad a `PROPUESTA` con un motivo, y cierra el costo real de las actividades realizadas. |

- Quien se registra recibe siempre el rol `member`. Las reglas de Firestore no le permiten cambiar su propio rol.
- Los roles con privilegios se asignan a mano en Firebase Console (ver sección 4).
- La barra inferior muestra solo las pestañas de cada rol, así un rol no puede navegar a funciones de otro. Además, las reglas de Firestore validan cada operación: ocultar un botón no basta.

| Pestañas | Miembro | Coordinador | Presupuesto |
|---|:-:|:-:|:-:|
| Opciones y detalle | ✓ | | |
| Mis propuestas | ✓ | | |
| Aprobaciones (horarios) | | ✓ | |
| Revisión financiera | | | ✓ |
| Itinerario | ✓ | ✓ | ✓ |
| Preferencias | editar y ver | ver | ver |
| Balance | ✓ | ✓ | ✓ |

## 2. Proceso y estados

```
PROPUESTA → HORARIO_APROBADO → CONFIRMADA → REALIZADA → COSTO_CERRADO
    │              │                │
    │              │                └─ CANCELADA (coordinador, antes del inicio: libera franja y reserva)
    │              └─ PROPUESTA (presupuesto la devuelve con motivo: libera la franja)
    └─ RECHAZADA (coordinador, con motivo)
```

`RECHAZADA`, `CANCELADA` y `COSTO_CERRADO` son estados terminales: ya no tienen más acciones.

## 3. Reglas de negocio

| # | Regla | Dónde se valida |
|---|---|---|
| 1 | La actividad debe quedar dentro de las fechas del viaje, en una franja de 2 horas (8, 10, 12, 14, 16 o 18 h). No se acepta un fin anterior al inicio. | `ItineraryRules.validateWindow` (formulario y repositorio) |
| 2 | Cada franja la ocupa una sola actividad aprobada o confirmada. Al aprobar el horario se ocupa la franja de forma atómica. | Transacción `approveSchedule` + documento `slots/{yyyyMMdd_HH}` + reglas |
| 3 | Confirmar un costo no puede pasar de $2.000.000, sumando las reservas vigentes y los costos cerrados. | Transacción `approveCost` sobre `budget/trip` + `ItineraryRules.checkReserve` + reglas |
| 4 | Un miembro no puede editar su propuesta después de que se apruebe el horario; tiene que pedir la devolución. | `ItineraryRules.checkAction` (`edit` exige `PROPUESTA`) + regla `ownerEdit` |
| 5 | Para cerrar el costo, la actividad debe estar `REALIZADA` y el valor real no puede ser negativo. Si supera lo reservado, la diferencia debe caber en el saldo. Cancelar libera solo reservas, no gastos ya cerrados. | `ItineraryRules.checkCloseCost` + transacción `closeCost` |

Toda acción revisa el rol, el dueño y el estado actual con `ItineraryRules.checkAction`. Las transiciones que no están permitidas muestran un mensaje en español.

## 4. Cómo ejecutar

Requisitos: Flutter estable (Dart `^3.12`), Android SDK y un emulador o dispositivo Android con API 24 o superior.

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

`app_database.g.dart` ya está generado. Si se cambia una tabla de Drift, se vuelve a generar con:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Configuración de Firebase

- Proyecto: `veterinaria-mobile-dev` (Authentication, Cloud Firestore y Crashlytics).
- Configuración del cliente: `lib/firebase_options.dart` y `android/app/google-services.json`. Son archivos de cliente, no secretos; la protección real la dan las reglas.
- **Authentication:** activar el proveedor *Email/Password*.
- **Reglas de Firestore:** están en `firestore.rules`. Se publican con `firebase deploy --only firestore:rules`, o copiándolas en Firebase Console → Firestore → Reglas.
- **Asignar roles de prueba:** registrar la cuenta desde la app (queda con `member`). Luego, en Firebase Console → Firestore → `users/{uid}`, cambiar el campo `role` a `coordinator` o `finance`. La app no permite hacer este cambio.

### Endpoint HTTP

Catálogo ficticio de 10 actividades, servido como JSON desde el repositorio:

```
https://raw.githubusercontent.com/andresmendoza59/veterinaria-flutter/main/mock_api/catalog.json
```

Cada registro tiene `id`, `name`, `category`, `location`, `estimated_cost` y `description`. Lo consume `HttpCatalogSource` (paquete `http`, timeout de 10 s). Los errores se traducen a mensajes claros: sin conexión, timeout, código distinto de 2xx, JSON inválido o error inesperado.

## 5. Arquitectura

```
lib/
  core/                 TripConfig, formatters, AppLogger, excepciones
  data/
    datasources/local/  Drift: AppDatabase, tabla itinerary_activities, ItineraryLocalDataSource
    datasources/remote/ Firestore: actividades (transacciones), perfiles, preferencias
    repositories/       ItineraryRepository, CatalogRepository, PreferenceRepository, UserProfileRepository
    services/           HTTP del catálogo, AuthService, CrashService, UiPreferences (SharedPreferences)
  features/
    auth/               LoginPage
    itinerary/          pantallas y widgets del proceso
  shared/models|widgets modelos y widgets comunes (LoadingView, ErrorView, EmptyView, LocalDataBanner)
  validators/           reglas puras: ItineraryRules, ActivityFilters, PreferenceRules, AuthValidators
```

- Las pantallas solo hablan con los repositorios. Los repositorios coordinan HTTP, Drift y Firestore según la operación.
- Las dependencias se crean en `main.dart` y se pasan por constructor.
- El estado se maneja con `StatefulWidget` + `setState`, `FutureBuilder` y `StreamBuilder` (en `AuthGate`).
- La navegación usa `Navigator.push` con `MaterialPageRoute`.

## 6. Modelo de datos

**Drift** (esquema **v3**; la migración v2 → v3 solo crea la tabla del catálogo):

- `catalog_options`: copia local del catálogo HTTP, para ver opciones y proponer sin conexión.
- `itinerary_activities`: las actividades del proceso, con la clave `id`.

| Campo | Para qué sirve |
|---|---|
| `id` | Identidad estable `uid_microsegundos`. Se crea antes del primer envío y se reutiliza en cada reintento. |
| `owner_uid` | Dueño de la propuesta (uid de Authentication). |
| `catalog_id`, `title`, `category`, `location` | Copia de la opción del catálogo. |
| `start_at`, `end_at`, `slot_id` | Franja de 2 horas. `slot_id` solo tiene valor cuando el horario está aprobado. |
| `estimated_cost`, `reserved_cost`, `real_cost` | Costo previsto, monto reservado y gasto real. |
| `status`, `reason`, `return_requested` | Estado del negocio, motivo y si se pidió devolución. |
| `updated_at` | Versión del registro: solo se marca sincronizado si coincide con la versión que se envió. |
| `pending_sync`, `sync_error` | Estado de sincronización, separado del estado del negocio. |

**Firestore**:

| Colección | Documento | Contenido |
|---|---|---|
| `users` | `{uid}` | `uid`, `role`, `created_at` |
| `activities` | `{id}` | Los mismos campos de negocio de la tabla de Drift. |
| `slots` | `{yyyyMMdd_HH}` | `activity_id` que ocupa la franja. |
| `budget` | `trip` | `reserved` y `spent`. |
| `preferences` | `{uid}` | `favorite_categories` (de 1 a 3), `note` y `updated_at`. |

**SharedPreferences**: `balance_category_{uid}` (último filtro de categoría del balance) y `last_tab_{uid}` (última pestaña abierta). Solo guarda preferencias de interfaz.

## 7. Operación local-first y sincronización

1. **Proponer** guarda primero en Drift con `pendingSync = true`. Funciona sin conexión, incluso después de reiniciar la app: el catálogo se toma de la copia local (`catalog_options`) si el servidor HTTP no responde.
2. "Mis propuestas" muestra por separado el **estado del negocio** y el **estado de sincronización** (*Sincronizada*, *Pendiente de envío* o *No aceptada al enviar*). Una propuesta pendiente no ocupa franja ni gasta presupuesto.
3. La app intenta enviarla a Firestore enseguida. Si falla, el botón **Sincronizar** de la barra superior la reintenta (`syncPending`).
4. Se marca sincronizada **solo** si Firestore confirma y el `updated_at` del registro coincide con la versión enviada.
5. Si Firestore la rechaza por una regla, por ejemplo porque otro rol ya la procesó, se guarda el motivo en `sync_error`. El miembro puede **corregir** o **descartar**; la app no la reenvía sin fin.
6. Un reintento del miembro no puede sobrescribir una decisión de otro rol: `pushProposal` vuelve a leer el estado remoto dentro de una transacción.
7. Al cambiar de cuenta, solo se sincronizan los pendientes del usuario actual (`getQueued(uid)`). Las vistas compartidas no muestran pendientes de otra cuenta (`ActivityFilters.visibleFor`).
8. **Decisiones** (aprobar horario, aprobar o rechazar costo, rechazar, cancelar, marcar realizada, cerrar costo): se hacen **online** con transacciones de Firestore, después de leer el estado remoto.
9. **Lectura con respaldo:** las vistas intentan Firestore primero y actualizan Drift. Si Firestore falla, muestran Drift con el aviso *"Sin conexión con el servidor…"*. El catálogo funciona igual: primero HTTP y, si falla, la copia de Drift.
10. Mientras una decisión se envía, los botones de esa vista se deshabilitan para evitar envíos repetidos.

## 8. Datos recolectados, privacidad y Crashlytics

- **Qué se guarda:** correo y uid (Firebase Authentication), rol, propuestas de actividades, decisiones con su motivo, montos ficticios del presupuesto y preferencias de viaje.
- **Para qué:** solo para coordinar el viaje académico ficticio.
- **Quién accede:** cualquier usuario con sesión lee las actividades, el itinerario, el presupuesto y las preferencias, porque el viaje es compartido. Cada usuario solo lee su propio perfil. Las escrituras dependen del rol y del dueño, según `firestore.rules`.
- **Contraseñas:** las maneja únicamente Firebase Authentication. Nunca se guardan en Drift, SharedPreferences, Firestore ni en los logs.
- **Crashlytics:** registra errores fatales (`CrashService.configure`) y no fatales. Las validaciones de negocio y los fallos de red esperados solo muestran un mensaje. Los errores inesperados de Firestore o de la sincronización se registran además como no fatales. Solo se asocia el `uid`, nunca el correo. El menú QA para provocar errores de prueba solo existe en modo debug (`kDebugMode`) y no aparece en el APK release.
- **Permisos Android:** solo `INTERNET`. No se usan cámara, ubicación, micrófono ni almacenamiento externo.

## 9. Pruebas y QA

- `flutter test` corre **65 pruebas** unitarias y de widget: reglas de negocio, escenarios de aceptación, filtros, preferencias, catálogo HTTP con `MockClient`, caché del catálogo y estrategia local-first con **Drift en memoria** (`AppDatabase.forTesting`), SharedPreferences, validadores y LoginPage con `FakeAuthService`.
- La app completa compila (`flutter build web` sin errores) y abre en la pantalla de login.
- Matriz de QA: [`docs/matriz_pruebas.md`](docs/matriz_pruebas.md).
- Datos de prueba y cómo reproducir los escenarios: [`docs/datos_de_prueba.md`](docs/datos_de_prueba.md).
- Checklist de release: [`docs/checklist_release.md`](docs/checklist_release.md).

## 10. APK release y firma

```bash
flutter analyze
flutter test
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`. **Firma:** el APK release usa la **firma de depuración** del proyecto (`signingConfig = signingConfigs.getByName("debug")` en `android/app/build.gradle.kts`), que los lineamientos aceptan para la entrega académica. No se creó un keystore de producción. En el repositorio no se suben `key.properties`, `*.jks` ni `*.keystore`.

## 11. Límites conocidos

- Un solo viaje ficticio, una sola moneda (COP) y franjas fijas de 2 horas. No hay pagos, reservas comerciales, mapas ni integración con agencias.
- Las preferencias de los miembros se consultan y guardan online; no se guardan en Drift.
- El catálogo HTTP solo informa. La disponibilidad real, es decir las franjas y el presupuesto, vive en Firestore. Sin conexión, el catálogo se muestra desde la última copia guardada; si nunca se descargó, aparece el error con **Reintentar**.
- Las reglas de Firestore validan rol, estado y campos permitidos, pero no recalculan el `slot_id` desde `start_at`; lo calcula la app dentro de la transacción. El responsable de presupuesto puede escribir `budget/trip` siempre que `reserved + spent ≤ 2.000.000`.
- Las reglas de Firestore no se probaron con el emulador de Firebase; se verifican a mano (ver la matriz de QA).
- La base local se llama `animals.sqlite` por herencia de la práctica anterior (veterinaria). Los archivos `features/animals` y `animal_note_*` siguen en el repositorio, pero el itinerario no los usa.
