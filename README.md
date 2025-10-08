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
   - Crear un proyecto en [Firebase Console](https://console.firebase.google.com)
   - Habilitar Authentication, Firestore y Storage
   - Descargar `google-services.json` para Android
   - Actualizar `lib/firebase_options.dart` con la configuración real

3. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

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
