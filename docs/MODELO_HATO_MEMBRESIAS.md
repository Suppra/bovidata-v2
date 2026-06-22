# 🐄 Modelo de Hato y Membresías — Scoping Seguro

Documento de la funcionalidad implementada: **acceso por hato mediante invitaciones**.
Implementada como **feature hexagonal** en `lib/features/membership/`.

---

## 1. Concepto

- Un **Ganadero** es dueño de un **hato** (su `propietarioId` = su `uid`).
- Un **Veterinario** o **Empleado** **no ve nada** del hato hasta que el ganadero
  lo **invita** y el invitado **acepta** (la invitación llega como notificación).
- Al aceptar, el miembro ve los datos (**bovinos, tratamientos, inventario**) de
  ese hato. El ganadero puede **revocar** el acceso en cualquier momento.

```mermaid
sequenceDiagram
    participant G as Ganadero
    participant FM as FarmMembersPage
    participant MI as MembershipInteractor
    participant R as MembershipRepository
    participant N as Notificaciones
    participant V as Veterinario/Empleado

    G->>FM: Invitar (correo del usuario)
    FM->>MI: invite(ganadero, email)
    MI->>R: resuelve usuario + crea membership(pendiente)
    MI->>N: notifica al invitado
    V->>FM: abre 'Miembros del hato' → Aceptar
    FM->>MI: respond(accept=true)
    MI->>R: updateStatus(aceptada)
    MI->>N: notifica al ganadero
    Note over V: Ahora ve bovinos/tratamientos/inventario del hato
```

## 2. Estructura (hexagonal)

```
lib/features/membership/
├── domain/
│   ├── entities/membership.dart         # entidad pura + MembershipStatus
│   └── ports/membership_repository.dart  # interfaz (puerto)
├── application/
│   └── membership_interactor.dart        # casos de uso: invite/respond/revoke
├── infrastructure/
│   ├── dto/membership_dto.dart           # mapeo Firestore <-> entidad
│   └── repositories/membership_repository_impl.dart
└── presentation/
    ├── controllers/membership_controller.dart
    └── pages/farm_members_page.dart
lib/core/access/farm_access_service.dart   # resuelve hatos accesibles
```

## 3. Modelo de datos

**Colección `memberships`** — id determinista `"${ganaderoId}_${memberId}"`:

| Campo | Descripción |
|-------|-------------|
| `ganaderoId` / `ganaderoNombre` | Dueño del hato que invita |
| `memberId` / `memberEmail` / `memberNombre` / `memberRol` | Usuario invitado |
| `estado` | `pendiente` · `aceptada` · `rechazada` · `revocada` |
| `fechaCreacion` / `fechaRespuesta` | Auditoría |

**Campo `propietarioId`** añadido a `treatments`, `inventory`, `incidents` (los
bovinos ya lo tenían). Se **estampa automáticamente** al crear:
- Bovino / inventario → hato del usuario actual (`FarmAccessService.currentFarmOwnerId`).
- Tratamiento → hereda el `propietarioId` del bovino al que aplica.

## 4. Lectura con scoping

`FarmAccessService.accessibleOwnerIds()` = `{ uid }` ∪ `{ hatos con membresía aceptada }`.
Los repositorios exponen `getByOwners(ids)` (`whereIn`, sin índices nuevos) y los
controladores cargan vía `getAccessible*()`.

## 5. Seguridad (Firestore Rules)

`hasFarmAccess(ownerId)` concede acceso si es el propio hato o existe membresía
**aceptada** (documento determinista verificable con `exists()`/`get()`):

```
function hasFarmAccess(ownerId) {
  return isSignedIn() && (
    ownerId == '' ||                         // dato heredado (transitorio)
    ownerId == request.auth.uid ||
    (exists(membershipPath(ownerId)) &&
     get(membershipPath(ownerId)).data.estado == 'aceptada')
  );
}
```

## 6. Limitaciones conocidas / siguientes pasos

1. **Backfill de datos previos:** los documentos creados antes de este cambio
   tienen `propietarioId == ''`. La regla los permite de forma transitoria
   (`ownerId == ''`) para no romper datos antiguos, pero **no aparecen en los
   listados** (que consultan por `whereIn`). Acción recomendada: ejecutar un
   script de backfill que asigne `propietarioId` a los documentos históricos y
   luego **endurecer la regla** eliminando la cláusula `ownerId == ''`.
2. **Costo de reglas:** `hasFarmAccess` hace un `get()` de membresía por documento
   leído. Para hatos con muchos miembros/listas grandes conviene migrar el rol y
   los hatos accesibles a **custom claims** del token (set por Cloud Function al
   aceptar/revocar), eliminando los `get()` en reglas.
3. **`whereIn` admite hasta 30 hatos.** Si un veterinario pertenece a más de 30
   hatos, habrá que paginar/particionar las consultas.
4. **Incidencias/mortalidad:** ya tienen `propietarioId` en el modelo, pero su
   flujo de lectura aún no está acotado por hato (no hay controlador dedicado);
   queda pendiente cuando se construya la feature `mortality`.

---

## 7. Estado de la migración hexagonal

**Migración COMPLETADA.** Todo el código de `lib/` está organizado por features
hexagonales + un kernel compartido. Ya no existen `lib/screens`, `lib/services`
ni `lib/controllers`.

| Feature | Estado |
|---------|--------|
| membership | ✅ domain · application · infrastructure · presentation |
| authentication | ✅ puerto `AuthRepository`, sin tipos Firebase en la firma |
| animals | ✅ port + repo + service + controller + pantallas |
| treatments | ✅ port + repo + service + controller + pantallas |
| inventory | ✅ port + repo + service + controller + pantallas |
| notifications | ✅ servicio + controller + pantalla |
| dashboard | ✅ reports + pdf_generator + home + pdf/activity infra |
| settings | ✅ controller + pantalla |
| users | ✅ infraestructura (`user_service`) |

### Estructura final de `lib/`
```
lib/
├── app/            # orquestación de arranque (scheduler de fondo)
├── core/           # kernel compartido: interfaces base, DI (ServiceLocator),
│                   # FarmAccessService, ModelFactory, ConcreteValidation/Notification
├── constants/      # constantes y estilos (compartido)
├── models/         # modelos de datos (shared kernel / DDD-lite)
├── widgets/        # widgets reutilizables
└── features/<x>/   # domain · application · infrastructure · presentation
```

**Convenciones:** imports de paquete (`package:bovidata_new/...`) en todo el
proyecto; el barrel `core/controllers/controllers.dart` re-exporta los controllers
de las features para los consumidores existentes.

**Limpieza realizada:** eliminados servicios legacy muertos (`bovine_service`,
`treatment_service`), `concrete_services`, barrels muertos (`screens.dart`,
`core.dart`, `constants.dart`), `entity_builder` + factories sin uso, y `.md` de
estados obsoletos.

**Pendiente (siguiente etapa, ver [ROADMAP.md](ROADMAP.md)):** convertir los
modelos en entidades puras por feature (hoy son shared kernel acoplado a
Firestore), migrar `SchedulerService` a Cloud Functions, e introducir DI por
constructor (`get_it`) en sustitución del `ServiceLocator` estático.
