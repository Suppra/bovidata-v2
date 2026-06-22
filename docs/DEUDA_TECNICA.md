# 💳 DEUDA TÉCNICA — BoviData V2

Inventario priorizado de deuda técnica. Estados: 🔴 Crítico · 🟠 Importante · 🟡 Menor.
Cada ítem indica esfuerzo aproximado y archivos afectados.

---

## 🔴 Crítica (bloquea producción)

| ID | Deuda | Archivos | Esfuerzo | Acción |
|----|-------|----------|:--------:|--------|
| TD-01 | Reglas Firestore permiten lectura cruzada entre fincas (multi-tenant leak). | `firestore.rules` | S | Añadir scoping por `propietarioId` en `read/list` de bovines/treatments/inventory/incidents. |
| TD-02 | `getUserRole()` default `'Ganadero'` → escalada de privilegios. | `firestore.rules:76-79` | S | Negar por defecto; migrar a custom claims. |
| TD-03 | La UI lista con `getAll()` sin filtrar por dueño/`activo`. | `core/repositories/concrete_repositories.dart`, `core/controllers/solid_bovine_controller.dart` | M | Usar `getByOwner` + `activo`; eliminar `getAll` de la ruta de UI. |
| TD-04 | Notificaciones de negocio son `print()` (stub inyectado). | `core/services/solid_services.dart:298-317`, `core/locator/service_locator.dart:45` | M | Inyectar el servicio real de Firestore; borrar stub. |
| TD-05 | `notifications.create` sin validar `usuarioId`. | `firestore.rules:53` | S | Exigir `usuarioId == auth.uid` o rol emisor válido. |
| TD-06 | Sin Firebase App Check (backend abierto). | `pubspec.yaml`, `main.dart` | M | Añadir `firebase_app_check` y activarlo. |

## 🟠 Importante

| ID | Deuda | Archivos | Esfuerzo | Acción |
|----|-------|----------|:--------:|--------|
| TD-07 | Doble arquitectura paralela (legacy `services/` vs `core/`). | `lib/services/*`, `lib/core/*` | L | Consolidar en una sola por feature; eliminar la huérfana. |
| TD-08 | Servicios legacy huérfanos (no importados por pantallas). | `services/bovine_service.dart`, `treatment_service.dart`, `inventory_service.dart`, `user_service.dart` | M | Migrar lógica útil (filtros, búsquedas) y eliminar. |
| TD-09 | Tests sin valor (comparan strings). | `test/solid_principles_test.dart` | M | Reescribir con pruebas reales de use cases/reglas. |
| TD-10 | `ServiceLocator.initialize()` duplicado. | `main.dart:24,27` | XS | Eliminar la línea repetida. |
| TD-11 | Widgets gigantes con lógica de negocio. | `reports_screen.dart` (1437), `notifications_screen.dart` (1274), `medical_history_screen.dart` (1011), `treatment_detail` (892), `inventory_detail` (808) | L | Extraer widgets + mover lógica a use cases. |
| TD-12 | Re-fetch completo de colección tras cada CRUD. | `core/controllers/solid_*_controller.dart` | M | Actualizar estado local / usar streams. |
| TD-13 | `getLowStock()` umbral hardcodeado `<= 10`. | `concrete_repositories.dart:319-328` | S | Comparar contra `cantidadMinima` por ítem. |
| TD-14 | `SchedulerService` con `Timer.periodic` en cliente. | `services/scheduler_service.dart` | L | Migrar a Cloud Functions (cron) / scheduled tasks. |
| TD-15 | Modelos acoplados a Firestore (`Timestamp`, `DocumentSnapshot`). | `models/*` | L | Separar entidad pura de DTO; usar mappers. |
| TD-16 | Estadísticas/reportes calculados en cliente sobre colecciones completas. | `bovine_service.dart:424`, `reports_screen.dart` | L | Aggregation queries / contadores / Functions. |
| TD-17 | DI vía singletons estáticos (no inyectable). | `core/locator/service_locator.dart` | M | Migrar a `get_it`/`injectable` por constructor. |

## 🟡 Menor

| ID | Deuda | Archivos | Esfuerzo | Acción |
|----|-------|----------|:--------:|--------|
| TD-18 | Código muerto con `main()` propio. | `lib/example_patterns_implementation.dart` | XS | Eliminar o mover a `/examples` fuera de `lib`. |
| TD-19 | `print()` como logging. | `scheduler_service.dart`, `solid_services.dart` | S | Usar `logger` y niveles. |
| TD-20 | Variable de builder con nombre de clase. | `inventory_detail_screen.dart`, `inventory_form_screen.dart` | XS | Renombrar a `controller`. |
| TD-21 | `.gitignore` no excluye `google-services.json`/`.env.local`. | `.gitignore` | XS | Añadir patrones. |
| TD-22 | Lints laxos. | `analysis_options.yaml` | S | Añadir reglas estrictas (`avoid_print`, `prefer_const`, `always_declare_return_types`). |
| TD-23 | Duplicación de `copyWith/fromX/toFirestore` en 9 modelos. | `models/*` | M | `freezed` + `json_serializable`. |
| TD-24 | Tres sistemas de notificación. | `services/notification_service.dart`, `core/services/solid_notification_service.dart`, stub | M | Consolidar en uno. |
| TD-25 | `macos` reutiliza `appId` de iOS. | `firebase_options.dart` | XS | Regenerar con FlutterFire si se soporta macOS. |
| TD-26 | Excepciones silenciadas (`catch{return false}`). | múltiples servicios | M | Propagar `Failure`/`Result`. |

---

## Resumen de esfuerzo

| Nivel | Ítems | Esfuerzo agregado aprox. |
|-------|:-----:|--------------------------|
| 🔴 Crítica | 6 | ~2–4 días |
| 🟠 Importante | 11 | ~3–4 semanas |
| 🟡 Menor | 9 | ~3–5 días |

Leyenda esfuerzo: XS (<1h) · S (1–3h) · M (0.5–1.5d) · L (2–5d).
