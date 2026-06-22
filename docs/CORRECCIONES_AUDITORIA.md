# ✅ Correcciones de la Auditoría Técnica — BoviData V2

Registro de lo corregido en el sprint de endurecimiento posterior a la auditoría
de due diligence. Estado de verificación: **`flutter analyze` = 0 issues**,
**29 tests verdes**.

---

## Seguridad
- **Roles (anti-escalada):** las reglas impiden auto-asignarse `Administrador` y
  auto-cambiarse el rol; el cambio de rol queda reservado a un Administrador
  (`firestore.rules`).
- **Scoping de escritura:** `treatments/inventory/incidents` exigen `hasFarmAccess`
  en create/update/delete (no solo en lectura).
- **Incidencias** acotadas por hato en lectura.
- **Firebase App Check** inicializado en `main.dart` (Play Integrity / DeviceCheck;
  debug en desarrollo) — protege el backend frente a clientes no oficiales.
- **Storage colgante** eliminado de `firebase.json`.

## Arquitectura / Código
- **Fuga de capa cerrada:** ninguna pantalla consulta `FirebaseFirestore` directo.
  Nuevos `IncidentRepository` (mortality) y `ActivityRepository` (dashboard);
  `medical_history`, `treatment_detail` y `pdf_generator` leen vía repositorios.
- **"Éxitos falsos" corregidos:**
  - `profile`: guardar perfil y cambiar contraseña ahora **funcionan de verdad**
    (antes mostraban éxito sin hacer nada).
  - `settings`: cambio de contraseña real.
  - Controllers (bovino/tratamiento/inventario): respetan el resultado del
    servicio en update/delete (antes reportaban éxito aunque fallara).
  - `notifications`: marcar como leída / descartar persisten vía controller.
  - `bovine_detail`: botón "Agregar Tratamiento" navega al formulario.

## Rendimiento
- **Sin re-fetch tras CRUD:** update/delete mutan el estado local en vez de
  recargar la colección completa (bovino/tratamiento/inventario).
- *Nota:* la agregación de `reports` ya está acotada por hato (no descarga
  colecciones globales). Para escala muy grande, ver §Pendiente.

## Testing
- Suite real del **data layer** con `fake_cloud_firestore` (16 tests nuevos):
  repos de bovinos/tratamientos/inventario (CRUD, scoping `getByOwners`, filtros
  `activo`, `getLowStock` por `cantidadMinima`), `MembershipRepository` y
  `ConcreteNotificationService`. **13 → 29 tests.**

## Calidad
- **`flutter analyze`: 0 issues** (antes 209). Migración `Radio → RadioGroup`,
  guardas de `BuildContext` async, naming, llaves, `withOpacity → withValues`.

## Dependencias
- Actualización mayor: **firebase_core 4, firebase_auth 6, cloud_firestore 6**,
  app_check 0.4, get_it 9, fake_cloud_firestore 4. (freezed se mantiene en 2.x;
  3.x es migración rompedora.)

---

## Pendiente (requiere decisión/sesión externa)
1. **Despliegue** de reglas/índices/functions (necesita tu sesión Firebase) y
   **backfill** de `propietarioId` en datos antiguos.
2. **Descomposición de god widgets** (`reports` 1441, `notifications` 1268,
   `medical_history` 999, `treatment_detail` 888…): refactor incremental que
   conviene verificar ejecutando la UI; es el principal trabajo de
   mantenibilidad restante.
3. **Agregación server-side** para reportes a gran escala (contadores vía Cloud
   Functions) — opcional; hoy la agregación está acotada por hato.
