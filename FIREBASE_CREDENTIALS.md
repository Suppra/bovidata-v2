# 🔥 Instrucciones para obtener credenciales Firebase
# ====================================================

## 📋 Pasos para obtener la configuración:

### 1. Ir a Firebase Console
Abre: https://console.firebase.google.com/project/bovidata-v2

### 2. Configurar Android
1. Ve a "Configuración del proyecto" (⚙️ arriba a la izquierda)
2. Scroll hacia abajo hasta "Tus apps"
3. Haz clic en "Agregar app" → Selecciona Android (🤖)
4. Configuración:
   - Nombre del paquete Android: `com.example.bovidata_new`
   - Nombre de la app: `BoviData V2`
   - SHA-1 (opcional): dejar vacío por ahora
5. Haz clic "Registrar app"
6. **DESCARGAR google-services.json**
7. Colocar el archivo en: `android/app/google-services.json`

### 3. Configurar Web (para credenciales)
1. En "Tus apps", haz clic en "Agregar app" → Selecciona Web (🌐)
2. Configuración:
   - Nombre de la app: `BoviData V2 Web`
   - NO marcar "También configurar Firebase Hosting"
3. Haz clic "Registrar app"
4. **COPIAR las credenciales** que aparecen en pantalla:

```javascript
const firebaseConfig = {
  apiKey: "tu-api-key-aqui",
  authDomain: "bovidata-v2.firebaseapp.com",
  projectId: "bovidata-v2",
  storageBucket: "bovidata-v2.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef123456789"
};
```

### 4. Habilitar servicios necesarios
1. **Authentication:**
   - Ve a "Authentication" en el menú izquierdo
   - Pestaña "Sign-in method"
   - Habilitar "Correo electrónico/contraseña"

2. **Firestore Database:**
   - Ve a "Firestore Database"
   - Haz clic "Crear base de datos"
   - Seleccionar "Comenzar en modo de prueba"
   - Ubicación: `nam5 (us-central)` (recomendado)

3. **Storage:**
   - Ve a "Storage"
   - Haz clic "Comenzar"
   - Seleccionar "Comenzar en modo de prueba"

### 5. Después de obtener las credenciales:
Pega las credenciales aquí para que las configure automáticamente en el código.

## ✅ Lista de verificación:
- [ ] Proyecto creado: bovidata-v2 ✅
- [ ] App Android agregada
- [ ] App Web agregada  
- [ ] google-services.json descargado
- [ ] Authentication habilitado
- [ ] Firestore creado
- [ ] Storage habilitado
- [ ] Credenciales copiadas