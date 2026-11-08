# Matriz de QA · G62-7 Itinerario colaborativo con presupuesto

- **Versión probada:** `1.0.0+1`
- **Rama:** `g62-7-itinerario-colaborativo-presupuesto`
- **Pruebas automáticas:** `flutter test` → **53 de 53 pasan**; `flutter analyze` → sin avisos.
- **Cuentas y datos:** ver [`datos_de_prueba.md`](datos_de_prueba.md).

**Columna Estado:**
- **Aprobado (auto):** lo verifica `flutter test` (archivo indicado en Evidencia).
- **Pendiente:** prueba manual que todavía hay que ejecutar en emulador o dispositivo. Al ejecutarla, llenar "Resultado obtenido", "Estado" y "Evidencia" (captura o video). **No marcar como aprobado un caso que falle.**

| ID | Precondición | Cuenta / rol | Pasos | Resultado esperado | Resultado obtenido | Estado | Versión | Evidencia |
|---|---|---|---|---|---|---|---|---|
| QA-01 | App instalada, cuenta existente | miembro1 | Iniciar sesión con correo y contraseña correctos. Cerrar y volver a abrir la app. | Entra a la app. Al reabrirla la sesión se restaura sin pedir login. | | Pendiente | 1.0.0+1 | |
| QA-02 | Pantalla de login | Sin sesión | a) Correo sin @. b) Contraseña de 3 caracteres. c) Contraseña incorrecta. d) Registrar un correo existente. e) Modo avión. | a, b) Errores de validación sin llamar a Firebase. c) "Las credenciales no coinciden". d) "Ya existe una cuenta con este correo". e) "Revisa tu conexión a internet". El botón se deshabilita mientras se procesa. | a, b, c, e verificados con FakeAuthService | Aprobado (auto) parcial; d pendiente manual | 1.0.0+1 | `test/login_page_test.dart`, `test/auth_validators_test.dart` |
| QA-03 | Cuenta recién registrada | Nueva cuenta | Registrarse y revisar `users/{uid}` en Firebase Console. | Rol `member`. La app solo muestra Opciones, Mis propuestas, Itinerario, Preferencias y Balance. | | Pendiente | 1.0.0+1 | |
| QA-04 | Sesión de miembro | miembro1 | Intentar desde la consola o un cliente modificado: cambiar su `role`, aprobar un horario o escribir `budget/trip`. | Firestore responde `permission-denied`. La interfaz no ofrece esas acciones al miembro. | | Pendiente | 1.0.0+1 | |
| QA-05 | miembro1 tiene una propuesta pendiente (modo avión) | miembro1 → miembro2 | Cerrar sesión con la propuesta pendiente. Entrar como miembro2 y pulsar Sincronizar. | miembro2 no ve la propuesta pendiente de miembro1 ni la envía. Al volver a miembro1 sigue pendiente. | Filtro `visibleFor` verificado | Aprobado (auto) en la lógica; flujo manual pendiente | 1.0.0+1 | `test/activity_filters_test.dart` |
| QA-06 | Internet activo | miembro1 | Abrir Opciones. | Se cargan las 10 opciones del catálogo HTTP. El detalle muestra nombre, categoría, ubicación y costo. | Parseo verificado con MockClient | Aprobado (auto) en el parseo; pantalla pendiente | 1.0.0+1 | `test/catalog_source_test.dart` |
| QA-07 | Respuestas simuladas | — | Respuesta `[]`, 404, 500, JSON inválido, timeout y sin red. | Lista vacía → "No hay opciones disponibles por ahora". Errores → mensaje claro con botón **Reintentar**, sin trazas técnicas. | Mensajes verificados | Aprobado (auto) | 1.0.0+1 | `test/catalog_source_test.dart` |
| QA-08 | Opciones cargadas, modo avión | miembro1 | Proponer una actividad. Cerrar la app por completo y volver a abrirla. | Se guarda en Drift como "Pendiente de envío". Sigue ahí después de reiniciar. No ocupa franja ni presupuesto. | | Pendiente | 1.0.0+1 | |
| QA-09 | QA-08 hecho | miembro1 | Quitar el modo avión y pulsar Sincronizar dos veces. | "Enviadas: 1". En Firestore hay **un solo** documento con el mismo `id`; el segundo envío no lo duplica. | | Pendiente | 1.0.0+1 | |
| QA-10 | Propuesta en `HORARIO_APROBADO` | miembro1 y coordinador | El miembro intenta editarla. El coordinador intenta aprobarla otra vez. El presupuesto intenta cerrar un costo de una actividad que no está realizada. | El miembro solo ve "Solicitar devolución". Las transiciones inválidas muestran "La actividad ya no está disponible para esta acción…". | Reglas verificadas | Aprobado (auto) en las reglas; interfaz pendiente | 1.0.0+1 | `test/itinerary_rules_test.dart` |
| QA-11 | Formulario de propuesta | miembro1 | Costo con letras, costo mayor a 2.000.000 y sin elegir día o franja. | Mensajes de validación. No se guarda nada. | Validadores verificados | Aprobado (auto) en los validadores | 1.0.0+1 | `test/itinerary_rules_test.dart` |
| QA-12 | **Escenario 1**: dos propuestas por la misma franja | coordinador | Ver `datos_de_prueba.md` §4. | Solo una se aprueba. La otra recibe "La franja ya está ocupada por otra actividad". | | Pendiente | 1.0.0+1 | |
| QA-13 | **Escenario 2**: dos confirmaciones concurrentes | presupuesto (2 dispositivos) | Ver `datos_de_prueba.md` §4. | La suma nunca pasa de 2.000.000. La segunda recibe "Presupuesto excedido…". | Cálculo verificado | Aprobado (auto) en el cálculo; concurrencia pendiente | 1.0.0+1 | `test/acceptance_scenarios_test.dart` |
| QA-14 | **Escenario 3**: cancelar y cerrar costo | coordinador y presupuesto | Ver `datos_de_prueba.md` §4. | Cancelar libera saldo y franja. Cerrar el costo cambia la reserva por el gasto real sin duplicarlo. | Resumen verificado | Aprobado (auto) en el cálculo; flujo pendiente | 1.0.0+1 | `test/acceptance_scenarios_test.dart` |
| QA-15 | Datos de prueba §3 cargados | Cualquiera | Balance: filtrar por categoría "Cultura", por día 02/02 y por estado "Cancelada". Cerrar y abrir la app. | Totales y lista cambian con cada filtro. Se distinguen confirmadas, realizadas, cerradas y canceladas. La categoría elegida se recuerda (SharedPreferences). | Filtros y preferencia verificados | Aprobado (auto) en la lógica; pantalla pendiente | 1.0.0+1 | `test/activity_filters_test.dart`, `test/ui_preferences_test.dart` |
| QA-16 | Datos cargados, luego modo avión | Cualquiera | Deslizar para recargar en Itinerario, Aprobaciones o Balance. | Se muestran los datos de Drift con el aviso "Sin conexión con el servidor…". | | Pendiente | 1.0.0+1 | |
| QA-17 | Build debug | miembro1 | Menú QA → "Registrar no fatal" y luego "Forzar crash fatal". Reabrir la app. | Los eventos aparecen en Firebase Console → Crashlytics, con el uid y sin correo. | | Pendiente | 1.0.0+1 | Captura de la consola con versión y dispositivo |
| QA-18 | APK release instalado | Los 3 roles | Recorrido O1–O7 de `datos_de_prueba.md` sobre el APK release. Verificar que el menú QA **no** aparece. | Todo el flujo funciona con HTTP, Auth, Drift, Firestore y sincronización. | | Pendiente (el APK aún no se genera) | 1.0.0+1 | |
| QA-19 | Miembro con sesión | miembro1 | Preferencias: elegir 0 categorías y guardar; luego elegir 2 con una nota y guardar. | 0 → "Elige al menos una categoría". 2 → "Preferencias guardadas" y el resumen del grupo se actualiza. | Reglas verificadas | Aprobado (auto) en las reglas; pantalla pendiente | 1.0.0+1 | `test/preference_rules_test.dart` |

## Registro de defectos

| ID | Defecto | Cómo se detectó | Corrección | Estado |
|---|---|---|---|---|
| DEF-01 | El `AndroidManifest.xml` principal no declaraba `INTERNET`. El APK release no podría hablar con Firebase ni con el catálogo (en debug funciona porque Flutter agrega el permiso solo en los manifiestos de debug). | Revisión de permisos antes del release. | Se agrega `android.permission.INTERNET` al manifiesto principal. | Corregido |
| DEF-02 | Cualquier usuario con sesión, incluidos el coordinador y el responsable de presupuesto, podía crear propuestas. | Revisión de `firestore.rules` contra los roles. | `activities/create` exige `isRole('member')`. | Corregido |
| DEF-03 | El coordinador o el responsable podían borrar cualquier documento de `slots` y liberar una franja ocupada. | Revisión de `firestore.rules`. | `slots/delete` solo se permite si la actividad queda con `slot_id == ''` en la misma transacción. | Corregido |
| DEF-04 | El login mostraba el título "Movies", heredado de la guía de clase. | Revisión de la interfaz. | Ahora muestra el nombre del viaje (`TripConfig.name`). | Corregido |
| DEF-05 | Las pestañas Itinerario, Balance y las de revisión mostraban "Disponible pronto". | Revisión contra el enunciado. | Se implementaron las vistas. | Corregido |

## Limitaciones conocidas

Ver la sección 11 del [README](../README.md).
