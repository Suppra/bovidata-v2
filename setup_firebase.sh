#!/bin/bash

# ===================================================================
# Script de Configuración Firebase para BoviData V2
# Versión: Linux/macOS
# Autor: Sistema Automatizado
# Fecha: $(date)
# ===================================================================

echo "🔥 Configurando Firebase para BoviData V2..."
echo "================================================"

# Verificar si Node.js está instalado
echo "📋 Verificando Node.js..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado."
    echo "   Instala Node.js desde: https://nodejs.org/"
    echo "   Después ejecuta este script nuevamente."
    exit 1
fi

echo "✅ Node.js encontrado: $(node --version)"

# Verificar si npm está disponible
if ! command -v npm &> /dev/null; then
    echo "❌ npm no está disponible."
    exit 1
fi

# Instalar Firebase CLI
echo ""
echo "🔧 Instalando Firebase CLI..."
npm install -g firebase-tools

# Verificar instalación
if ! command -v firebase &> /dev/null; then
    echo "❌ Error instalando Firebase CLI."
    exit 1
fi

echo "✅ Firebase CLI instalado: $(firebase --version)"

# Activar FlutterFire CLI
echo ""
echo "🔧 Activando FlutterFire CLI..."
dart pub global activate flutterfire_cli

# Verificar que Flutter está disponible
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no está instalado o no está en PATH."
    echo "   Instala Flutter desde: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Obtener dependencias de Flutter
echo ""
echo "📦 Obteniendo dependencias de Flutter..."
flutter pub get

# Información para el usuario
echo ""
echo "🎉 Herramientas instaladas correctamente!"
echo ""
echo "📋 SIGUIENTES PASOS:"
echo "   1. Ve a Firebase Console: https://console.firebase.google.com"
echo "   2. Crea un nuevo proyecto (ej: 'bovidata-v2-production')"
echo "   3. Habilita los siguientes servicios:"
echo "      - Authentication (Email/Password)"
echo "      - Firestore Database"
echo "      - Storage"
echo "   4. Ejecuta: flutterfire configure --project=tu-proyecto-id"
echo "   5. Ejecuta: firebase login"
echo "   6. Ejecuta: firebase deploy --only firestore:rules,storage:rules,firestore:indexes"
echo ""
echo "💡 Ver FIREBASE_SETUP.md para instrucciones detalladas"
echo ""
echo "⚡ Para configurar automáticamente (después de crear el proyecto):"
echo "   flutterfire configure --project=tu-proyecto-id"
echo ""

# Crear archivo .env si no existe
if [ ! -f ".env" ]; then
    echo "📄 Creando archivo .env desde plantilla..."
    cp .env.example .env 2>/dev/null || echo "⚠️  Crea manualmente el archivo .env usando .env.example como plantilla"
fi

echo "✅ Configuración inicial completada!"
echo "   Revisa los pasos anteriores antes de continuar."