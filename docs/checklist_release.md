# Checklist de release · G62-7

Versión objetivo: **`1.0.0+1`** (en `pubspec.yaml`). Si se genera un nuevo APK para entregar, subir el número después del `+` (por ejemplo `1.0.0+2`) y actualizar el README y la matriz de QA.

Marca con `[x]` solo lo que se haya comprobado de verdad.

## Código y calidad
- [x] `flutter analyze` sin avisos.
- [x] `flutter test` en verde (53 pruebas).
- [x] Las pantallas no usan Firebase directamente; pasan por los repositorios y por `CrashService`.
- [x] El menú QA está detrás de `kDebugMode`.

## Autenticación, roles y reglas
- [x] Registro, login, logout, restauración de sesión y recuperación de contraseña implementados.
- [x] Quien se registra recibe `member` y no puede cambiar su rol (regla `users`).
- [x] Reglas por rol, dueño y campos permitidos en `activities`, `slots`, `budget` y `preferences`.
- [ ] Reglas publicadas en Firebase Console (`firebase deploy --only firestore:rules`).
- [ ] Una cuenta por rol creada y con su rol asignado en Firebase Console.

## Flujo y reglas de negocio
- [x] Las 5 reglas de negocio implementadas y con pruebas unitarias.
- [ ] Recorrido completo O1–O7 ejecutado con los tres roles (ver `datos_de_prueba.md`).
- [ ] Escenarios de aceptación 1, 2 y 3 ejecutados a mano (QA-12, 13 y 14).

## Drift, sincronización y cambio de cuenta
- [x] Propuesta guardada primero en Drift con `pendingSync`, con id estable y `updated_at` como versión.
- [ ] Probado: guardar sin conexión, reiniciar, sincronizar y que no haya duplicados (QA-08 y QA-09).
- [ ] Probado: cambio de cuenta con pendientes (QA-05).

## Crashlytics, logs y permisos
- [x] `CrashService` con implementación real para Android y stub para web; solo se asocia el uid.
- [x] Los logs (`AppLogger` y `debugPrint`) no incluyen contraseñas ni tokens.
- [x] Permiso `INTERNET` en el manifiesto principal; no se piden otros permisos.
- [ ] Evento no fatal y crash fatal visibles en Firebase Console, con captura de versión y dispositivo (QA-17).

## APK (todavía no se genera)
- [ ] `flutter build apk --release`.
- [ ] APK instalado en un emulador o dispositivo Android (API 24 o superior).
- [ ] Recorrido principal con los 3 roles sobre el APK; el menú QA no aparece (QA-18).
- [ ] APK nombrado con el código del proyecto y la versión, por ejemplo `G62-7_itinerario_1.0.0+1.apk`.
- [x] La firma es la de depuración del proyecto (`signingConfigs.debug`); está documentada en el README.
- [x] `.gitignore` deja fuera `build/`. No hay `key.properties`, `*.jks` ni `*.keystore` en el repositorio.

## Entregables
- [x] README con integrantes, caso, roles, ejecución, Firebase, endpoint, modelo de datos, reglas, local-first, límites y nota de privacidad.
- [x] Matriz de QA (19 casos) con el registro de defectos.
- [x] Datos de prueba documentados.
- [ ] Evidencias (capturas o video) agregadas a la matriz.
