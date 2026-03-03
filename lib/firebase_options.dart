import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAOzS04jNe5sevUjR-rzSXKbmneHEU8Ak4',
    appId: '1:944607586667:android:7e507ab25abf6564d9c42e',
    messagingSenderId: '944607586667',
    projectId: 'expense-tracker-farid',
    storageBucket: 'expense-tracker-farid.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCRGTwDAiC6TEhRVIKXN7t3nvaU_zAKfvc',
    appId: '1:944607586667:ios:26e7a651a33e71a4d9c42e',
    messagingSenderId: '944607586667',
    projectId: 'expense-tracker-farid',
    storageBucket: 'expense-tracker-farid.firebasestorage.app',
    iosBundleId: 'com.expensetracker.expenseTracker',
  );
}
