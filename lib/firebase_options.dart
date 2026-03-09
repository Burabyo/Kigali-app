// ─────────────────────────────────────────────────────────────────────────────
// FILE: lib/firebase_options.dart
//
// ⚠️  SETUP REQUIRED: Replace the placeholder values below with your actual
//     Firebase project configuration.
//
// HOW TO GENERATE THIS FILE AUTOMATICALLY:
//   1. Install the FlutterFire CLI:
//        dart pub global activate flutterfire_cli
//   2. From your project root, run:
//        flutterfire configure
//      This command will:
//       • Let you select / create a Firebase project
//       • Register your Android, iOS, and Web apps
//       • Download google-services.json and GoogleService-Info.plist
//       • Auto-generate this file with your real credentials
//
// MANUAL CONFIGURATION (if you already have a Firebase project):
//   Go to https://console.firebase.google.com → Your Project →
//   Project Settings → Your Apps → SDK setup and configuration,
//   then copy the values into the placeholders below.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── WEB ──────────────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  // ── ANDROID ───────────────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  // ── iOS ───────────────────────────────────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.kigaliCityServices',
  );

  // ── macOS ─────────────────────────────────────────────────────────────────
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.kigaliCityServices',
  );
}
