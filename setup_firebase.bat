@echo off
echo 🔥 BoviData V2 - Configuracion Firebase
echo =====================================

echo.
echo 1. Verificando Flutter...
flutter --version

echo.
echo 2. Verificando dependencias Firebase...
flutter pub get

echo.
echo 3. Verificando FlutterFire CLI...
flutterfire --version

echo.
echo 4. Configurando Firebase...
echo IMPORTANTE: Asegurate de haber creado el proyecto 'bovidata-v2-production' en Firebase Console
echo.
pause

echo.
echo 5. Iniciando configuracion FlutterFire...
flutterfire configure --project=bovidata-v2-prod

echo.
echo 6. Instalando dependencias actualizadas...
flutter pub get

echo.
echo 7. Limpiando cache de Flutter...
flutter clean

echo.
echo 8. Construyendo proyecto...
flutter build apk --debug

echo.
echo ✅ Configuracion completa!
echo 📱 APK generado en: build/app/outputs/flutter-apk/
echo 🔗 Proyecto Firebase: https://console.firebase.google.com/project/bovidata-v2-prod
echo.
pause