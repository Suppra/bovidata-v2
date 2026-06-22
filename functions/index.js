// Cloud Functions de BoviData — tareas programadas (cron real del lado servidor).
//
// Reemplaza el SchedulerService basado en Timer del cliente (que solo corría con
// la app abierta y se duplicaba por dispositivo). Estas funciones se ejecutan en
// el servidor de forma centralizada y persisten notificaciones en Firestore.
//
// Despliegue:  firebase deploy --only functions --project bovidata-v2
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");

initializeApp();
const db = getFirestore();

const TREATMENTS = "treatments";
const BOVINES = "bovines";
const INVENTORY = "inventory";
const USERS = "users";
const NOTIFICATIONS = "notifications";

async function createNotification(userId, titulo, mensaje, tipo, prioridad) {
  if (!userId) return;
  await db.collection(NOTIFICATIONS).add({
    titulo,
    mensaje,
    tipo: tipo || "general",
    usuarioId: userId,
    leida: false,
    fechaCreacion: Timestamp.now(),
    prioridad: prioridad || "normal",
  });
}

async function bovineInfo(bovineId) {
  if (!bovineId) return { nombre: "Desconocido", propietarioId: null };
  const doc = await db.collection(BOVINES).doc(bovineId).get();
  const data = doc.exists ? doc.data() : {};
  return {
    nombre: (data && data.nombre) || "Desconocido",
    propietarioId: (data && data.propietarioId) || null,
  };
}

// Notifica tratamientos cuyo proximaAplicacion cae dentro de [desde, hasta].
async function notifyTreatmentsInWindow(desde, hasta, prioridad) {
  let query = db.collection(TREATMENTS).where("completado", "==", false);
  if (desde) query = query.where("proximaAplicacion", ">=", Timestamp.fromDate(desde));
  if (hasta) query = query.where("proximaAplicacion", "<=", Timestamp.fromDate(hasta));
  const snap = await query.get();

  for (const doc of snap.docs) {
    const t = doc.data();
    if (!t.proximaAplicacion) continue;
    const fecha = t.proximaAplicacion.toDate();
    const { nombre, propietarioId } = await bovineInfo(t.bovineId);
    const titulo = `Tratamiento: ${t.tipo || "aplicación"}`;
    const mensaje = `El tratamiento de "${nombre}" está programado para ${fecha.toLocaleDateString("es-ES")}.`;
    const destinatarios = new Set([t.veterinarioId, propietarioId].filter(Boolean));
    for (const uid of destinatarios) {
      await createNotification(uid, titulo, mensaje, "tratamiento", prioridad);
    }
  }
}

// Notifica inventario bajo / vencido.
async function notifyInventory(onlyCritical) {
  const now = new Date();
  const snap = await db.collection(INVENTORY).where("activo", "==", true).get();

  // Destinatarios: ganaderos y empleados activos.
  const usersSnap = await db.collection(USERS).where("activo", "==", true).get();
  const destinatarios = usersSnap.docs
    .filter((d) => ["Ganadero", "Empleado"].includes(d.data().rol))
    .map((d) => d.id);

  for (const doc of snap.docs) {
    const item = doc.data();
    const cantidad = item.cantidadActual || 0;
    const minimo = item.cantidadMinima || 0;
    const nombre = item.nombre || "Producto";
    const owner = item.propietarioId;
    const targets = owner ? [owner] : destinatarios;

    const lowStock = onlyCritical ? cantidad === 0 : cantidad <= minimo;
    if (lowStock) {
      for (const uid of targets) {
        await createNotification(
          uid,
          "Stock bajo",
          `El ítem "${nombre}" tiene ${cantidad} unidades.`,
          "inventario",
          "alta"
        );
      }
    }

    if (item.fechaVencimiento) {
      const venc = item.fechaVencimiento.toDate();
      const dias = Math.ceil((venc - now) / (1000 * 60 * 60 * 24));
      const expira = onlyCritical ? dias <= 0 : dias <= 30;
      if (expira) {
        for (const uid of targets) {
          await createNotification(
            uid,
            dias <= 0 ? "Medicamento vencido" : "Medicamento por vencer",
            `El ítem "${nombre}" ${dias <= 0 ? "está vencido" : `vence en ${dias} días`}.`,
            "inventario",
            dias <= 0 ? "alta" : "media"
          );
        }
      }
    }
  }
}

// Diario 08:00 — próximos (3 días), vencidos e inventario por vencer.
exports.dailyChecks = onSchedule(
  { schedule: "every day 08:00", timeZone: "America/Bogota" },
  async () => {
    const now = new Date();
    const en3dias = new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000);
    await notifyTreatmentsInWindow(now, en3dias, "media"); // próximos
    await notifyTreatmentsInWindow(null, now, "alta"); // vencidos
    await notifyInventory(false);
  }
);

// Horario — tratamientos urgentes (hoy/vencidos) e inventario crítico.
exports.hourlyChecks = onSchedule(
  { schedule: "every 1 hours", timeZone: "America/Bogota" },
  async () => {
    const now = new Date();
    const manana = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);
    await notifyTreatmentsInWindow(null, manana, "alta");
    await notifyInventory(true);
  }
);
