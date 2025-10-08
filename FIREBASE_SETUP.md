# BoviData V2 - Configuración Firebase

## 🔥 Pasos para Configurar Firebase

### 1. Instalar Node.js
- Descargar desde: https://nodejs.org/
- Instalar la versión LTS recomendada

### 2. Instalar Firebase CLI
```bash
npm install -g firebase-tools
```

### 3. Inicializar Firebase
```bash
firebase login
firebase init
```

### 4. Configurar Flutter Firebase
```bash
# Desde la raíz del proyecto Flutter
flutterfire configure
```

### 5. Nombre del Proyecto Firebase
- **Proyecto**: `bovidata-v2-production`
- **ID**: `bovidata-v2-prod`
- **Región**: `us-central1` o tu región preferida

### 6. Servicios a Habilitar
- ✅ Authentication (Email/Password)
- ✅ Firestore Database
- ✅ Storage
- ✅ Hosting (opcional)

### 7. Configuración Android
- Descargar `google-services.json`
- Colocar en: `android/app/`

### 8. Configuración iOS
- Descargar `GoogleService-Info.plist`
- Colocar en: `ios/Runner/`

### 9. Desplegar Reglas
```bash
firebase deploy --only firestore:rules,storage
```

## 🔒 Configuraciones de Seguridad

### Firestore Rules (firestore.rules)
- Configuradas para roles: Ganadero, Veterinario, Empleado
- Control de acceso por colección
- Validación de datos

### Storage Rules (storage.rules)
- Límites de tamaño por tipo de archivo
- Control de acceso por carpeta
- Validación de tipos de archivo

## 🚀 Siguiente Paso
Una vez instalado Node.js, ejecutar:
```bash
firebase login
cd D:\BoviData\BoviDataV2\bovidata_new
flutterfire configure
```