// File configured for Firebase project: bovidata-v2
// ignore_for_file: type=lint

// ✅ CONFIGURADO: Firebase conectado al proyecto 'bovidata-v2'
// 📝 Proyecto: bovidata-v2 (Producción)
// 🔄 Configurado el: 8 de octubre, 2025

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCdBeUAvpimr3sRMOgeM33AhGoem3ILk5Y',
    appId: '1:900212600285:web:e3ce2864add80d897d5a34',
    messagingSenderId: '900212600285',
    projectId: 'bovidata-v2',
    authDomain: 'bovidata-v2.firebaseapp.com',
    storageBucket: 'bovidata-v2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMrb3Vd-O-NpqIbMWUgjFkiqEZLLvTjSE',
    appId: '1:900212600285:android:95282b3ce25295d07d5a34',
    messagingSenderId: '900212600285',
    projectId: 'bovidata-v2',
    storageBucket: 'bovidata-v2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCdBeUAvpimr3sRMOgeM33AhGoem3ILk5Y',
    appId: '1:900212600285:ios:95282b3ce25295d07d5a34',
    messagingSenderId: '900212600285',
    projectId: 'bovidata-v2',
    storageBucket: 'bovidata-v2.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCdBeUAvpimr3sRMOgeM33AhGoem3ILk5Y',
    appId: '1:900212600285:ios:95282b3ce25295d07d5a34',
    messagingSenderId: '900212600285',
    projectId: 'bovidata-v2',
    storageBucket: 'bovidata-v2.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCdBeUAvpimr3sRMOgeM33AhGoem3ILk5Y',
    appId: '1:900212600285:web:e3ce2864add80d897d5a34',
    messagingSenderId: '900212600285',
    projectId: 'bovidata-v2',
    authDomain: 'bovidata-v2.firebaseapp.com',
    storageBucket: 'bovidata-v2.firebasestorage.app',
  );
}