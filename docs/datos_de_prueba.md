# Datos de prueba · G62-7

Todos los datos son ficticios. **Las contraseñas de las cuentas de prueba no se escriben en este repositorio.** Se comparten solo por el medio privado que indique el docente.

## 1. Cuentas (una por rol como mínimo)

| Cuenta | Rol (`users/{uid}.role`) | Cómo se prepara |
|---|---|---|
| `miembro1@viaje.test` | `member` | Registrarse desde la app. |
| `miembro2@viaje.test` | `member` | Registrarse desde la app. Sirve para el cambio de cuenta y para las propuestas en conflicto. |
| `coordinador@viaje.test` | `coordinator` | Registrarse desde la app y luego, en Firebase Console → Firestore → `users/{uid}`, cambiar `role` a `coordinator`. |
| `presupuesto@viaje.test` | `finance` | Registrarse desde la app y luego cambiar `role` a `finance` en Firebase Console. |

> El rol se cambia solo desde Firebase Console. Las reglas de Firestore no le permiten a nadie cambiar su propio rol desde la app.

## 2. Recurso HTTP (10 registros)

`mock_api/catalog.json`, servido en
`https://raw.githubusercontent.com/andresmendoza59/veterinaria-flutter/main/mock_api/catalog.json`

| id | Nombre | Categoría | Costo estimado |
|---|---|---|---:|
| cat-01 | Parapente en Chicamocha del Eje | Aventura | 180.000 |
| cat-02 | Canopy y senderismo en la reserva | Aventura | 120.000 |
| cat-03 | Recorrido por el pueblo patrimonio | Cultura | 45.000 |
| cat-04 | Museo del Cafe y la Arrieria | Cultura | 60.000 |
| cat-05 | Cena de cocina cafetera | Gastronomia | 95.000 |
| cat-06 | Catacion y tostion de cafe | Gastronomia | 85.000 |
| cat-07 | Tarde de termales | Descanso | 110.000 |
| cat-08 | Spa y masajes en finca | Descanso | 450.000 |
| cat-09 | Traslado privado entre municipios | Transporte | 40.000 |
| cat-10 | Tour en jeep Willys | Transporte | 70.000 |

## 3. Operaciones del negocio (7, repartidas entre los estados)

Partir de una base vacía: sin documentos en `activities` ni en `slots`, y `budget/trip` borrado o en `reserved: 0, spent: 0`. Hacer los pasos en este orden.

| # | Cuenta que propone | Actividad | Día y franja | Costo | Pasos | Estado final |
|---|---|---|---|---:|---|---|
| O1 | miembro1 | Recorrido por el pueblo (cat-03) | 01/02 08:00 | 45.000 | Proponer. | `PROPUESTA` |
| O2 | miembro1 | Spa y masajes (cat-08) | 01/02 10:00 | 450.000 | Proponer → coordinador **Rechazar** con motivo "Excede el plan". | `RECHAZADA` |
| O3 | miembro2 | Museo del Café (cat-04) | 02/02 10:00 | 60.000 | Proponer → coordinador **Aprobar horario**. | `HORARIO_APROBADO` |
| O4 | miembro1 | Cena cafetera (cat-05) | 02/02 18:00 | 95.000 | Proponer → coordinador **Aprobar horario** → presupuesto **Aprobar costo**. | `CONFIRMADA` |
| O5 | miembro2 | Tour en jeep (cat-10) | 03/02 08:00 | 70.000 | Igual que O4 → coordinador **Marcar realizada**. | `REALIZADA` |
| O6 | miembro1 | Termales (cat-07) | 03/02 14:00 | 110.000 | Igual que O5 → presupuesto **Cerrar costo real** con 120.000. | `COSTO_CERRADO` |
| O7 | miembro2 | Canopy (cat-02) | 04/02 10:00 | 120.000 | Igual que O4 → coordinador **Cancelar**. | `CANCELADA` |

Balance esperado al terminar: reservado **95.000** (O4) + **70.000** (O5) = 165.000; gasto real **120.000** (O6); saldo **2.000.000 − 165.000 − 120.000 = 1.715.000**. O7 cancelada no cuenta.

## 4. Cómo reproducir los escenarios de aceptación

**Escenario 1. Dos propuestas por la misma franja: solo una se aprueba.**
1. miembro1 propone "Catación de café" (cat-06) el 05/02 a las 10:00. miembro2 propone "Traslado" (cat-09) el mismo 05/02 a las 10:00.
2. El coordinador aprueba el horario de la primera: aparece "Horario aprobado: la franja quedó ocupada".
3. El coordinador intenta aprobar la segunda: aparece "La franja ya está ocupada por otra actividad" y la propuesta sigue en `PROPUESTA`.
4. Variante concurrente: dos dispositivos con dos cuentas de coordinador aprueban a la vez. La transacción deja pasar solo una.

**Escenario 2. Dos confirmaciones concurrentes no exceden el presupuesto.**
1. En Firebase Console, poner `budget/trip.reserved` en 1.800.000 (simula reservas anteriores).
2. Tener dos actividades en `HORARIO_APROBADO` de 120.000 y 180.000.
3. Aprobar el costo de ambas, una tras otra o desde dos dispositivos a la vez. La primera que llega se confirma. La segunda recibe "Presupuesto excedido…", porque 1.800.000 + 120.000 + 180.000 > 2.000.000.
4. Volver a poner `reserved` en su valor anterior.

**Escenario 3. Cancelar devuelve saldo y horario; cerrar el costo real ajusta el resumen sin duplicar el gasto.**
1. Con O4 confirmada, mirar el Balance: reservado incluye 95.000.
2. El coordinador cancela O4: el saldo sube 95.000 y en Itinerario la franja 02/02 18:00 queda "Libre".
3. Con O5 realizada (reserva 70.000), el responsable cierra el costo con 80.000: el reservado baja 70.000 y el gasto real sube 80.000 (no 150.000).
