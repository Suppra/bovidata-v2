# BoviData - Sistema de Gestión de Ganado

BoviData es una aplicación Flutter moderna para la gestión integral de ganado bovino, diseñada para ganaderos, veterinarios y empleados del sector ganadero.

## Características Principales

### 🐄 Gestión de Bovinos
- Registro completo de animales (raza, edad, peso, identificación)
- Seguimiento del estado de salud
- Historial médico detallado
- Fotografías y documentación

### 💉 Gestión de Tratamientos
- Programación de vacunaciones
- Registro de medicamentos aplicados
- Control de dosis y fechas
- Seguimiento de efectos secundarios

### 📦 Control de Inventario
- Gestión de medicamentos y suministros
- Control de stock y fechas de vencimiento
- Alertas de inventario bajo
- Registro de proveedores

### 📊 Reportes y Análisis
- Estadísticas de salud del ganado
- Reportes de mortalidad
- Análisis de productividad
- Exportación a PDF

### 👥 Sistema de Usuarios
- **Ganadero**: Acceso completo al sistema
- **Veterinario**: Gestión de tratamientos y diagnósticos
- **Empleado**: Operaciones básicas del día a día

### 🔔 Sistema de Notificaciones
- Recordatorios de vacunación
- Alertas de inventario
- Notificaciones de tratamientos pendientes

## Tecnologías Utilizadas

- **Frontend**: Flutter 3.35.3
- **Backend**: Firebase (Firestore, Auth, Storage)
- **Estado**: Provider
- **UI**: Material Design 3
- **Generación PDF**: pdf & printing packages
- **Autenticación**: Firebase Auth con roles

## Configuración del Proyecto

### Requisitos Previos
- Flutter SDK 3.35.3 o superior
- Dart 3.9.2 o superior
- Android Studio / VS Code
- Cuenta de Firebase

### Instalación

1. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

2. **Configurar Firebase**
   - Instalar Node.js desde [nodejs.org](https://nodejs.org/)
   - Instalar Firebase CLI: `npm install -g firebase-tools`
   - Crear un proyecto en [Firebase Console](https://console.firebase.google.com)
   - Habilitar Authentication, Firestore y Storage
   - Configurar Flutter con Firebase: `dart pub global activate flutterfire_cli`
   - Ejecutar: `flutterfire configure --project=tu-proyecto-id`
   - Esto generará automáticamente `firebase_options.dart` y `google-services.json`
   - **Alternativamente**, ejecutar `setup_firebase.bat` para automatizar el proceso
   - Ver `FIREBASE_SETUP.md` para instrucciones detalladas

3. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 🔥 Configuración de Firebase

### Método Automatizado (Recomendado)
```bash
# En Windows, ejecutar:
setup_firebase.bat

# En otros sistemas:
chmod +x setup_firebase.sh && ./setup_firebase.sh
```

### Método Manual
1. **Instalar herramientas necesarias**
   ```bash
   # Instalar Node.js desde https://nodejs.org/
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   ```

2. **Crear proyecto Firebase**
   - Ir a [Firebase Console](https://console.firebase.google.com)
   - Crear nuevo proyecto (ej: "bovidata-v2-production")
   - Habilitar Authentication, Firestore Database, Storage

3. **Configurar Flutter**
   ```bash
   flutterfire configure --project=tu-proyecto-id
   ```

4. **Desplegar reglas de seguridad**
   ```bash
   firebase deploy --only firestore:rules,storage:rules,firestore:indexes
   ```

Ver `FIREBASE_SETUP.md` para instrucciones completas paso a paso.

## Compilación para Producción

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

## Estado del Proyecto

✅ **Completado:**
- Arquitectura base del proyecto
- Modelos de datos
- Servicios de Firebase  
- Controladores de estado
- Sistema de autenticación (Login, Registro, Recuperación)
- Dashboard principal
- Configuración de tema y estilos

🔄 **En desarrollo:**
- Pantallas de gestión de bovinos
- Sistema de tratamientos
- Gestión de inventario
- Reportes y análisis

---

**BoviData** - Gestión inteligente para tu ganado 🐄
