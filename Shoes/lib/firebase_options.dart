// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCuMsyygBhPHTdIT_UJasb3q7ydqoVkYd4',
    appId: '1:822397058468:android:c3e9de77687ca4fdc4d531',
    messagingSenderId: '822397058468',
    projectId: 'shoe-140bf',
    storageBucket: 'shoe-140bf.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBGtWhNn9JbzeOz8vYXuN6Rt3X9wv2hLj0',
    appId: '1:822397058468:ios:600bd1dbf84da7c7c4d531',
    messagingSenderId: '822397058468',
    projectId: 'shoe-140bf',
    storageBucket: 'shoe-140bf.firebasestorage.app',
    iosBundleId: 'com.example.shoeniverseFinalproject',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyChTpykc2LTXb8g_DTz0R8-ILEblATlHRs',
    appId: '1:822397058468:web:fc831df461ad6f74c4d531',
    messagingSenderId: '822397058468',
    projectId: 'shoe-140bf',
    authDomain: 'shoe-140bf.firebaseapp.com',
    storageBucket: 'shoe-140bf.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBGtWhNn9JbzeOz8vYXuN6Rt3X9wv2hLj0',
    appId: '1:822397058468:ios:f97fe0241db98f15c4d531',
    messagingSenderId: '822397058468',
    projectId: 'shoe-140bf',
    storageBucket: 'shoe-140bf.firebasestorage.app',
    iosBundleId: 'com.example.shoes',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyChTpykc2LTXb8g_DTz0R8-ILEblATlHRs',
    appId: '1:822397058468:web:bc8df5e7d212b4dec4d531',
    messagingSenderId: '822397058468',
    projectId: 'shoe-140bf',
    authDomain: 'shoe-140bf.firebaseapp.com',
    storageBucket: 'shoe-140bf.firebasestorage.app',
  );

}