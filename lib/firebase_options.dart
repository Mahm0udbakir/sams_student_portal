import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCxGHlkhGD10q2yevB5Xbz9lqbkrS7Db9g",
    authDomain: "sams-portal-2026-bakir.firebaseapp.com",
    projectId: "sams-portal-2026-bakir",
    storageBucket: "sams-portal-2026-bakir.firebasestorage.app",
    messagingSenderId: "514020824962",
    appId: "1:514020824962:web:03603c90bf853c1737619b",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDfKFvTqoTcNwbjdcmq4tA4tgVgjm4CYAQ",
    appId: "1:514020824962:android:6dca3c794028f2db37619b",
    messagingSenderId: "514020824962",
    projectId: "sams-portal-2026-bakir",
    storageBucket: "sams-portal-2026-bakir.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyA9VoeHZTRpXjgjBbelYMQxIEFKvpMCXdo",
    appId: "1:514020824962:ios:29a20f722d0b3f3737619b",
    messagingSenderId: "514020824962",
    projectId: "sams-portal-2026-bakir",
    storageBucket: "sams-portal-2026-bakir.firebasestorage.app",
    iosBundleId: "com.example.samsstudentportal",
  );
}
