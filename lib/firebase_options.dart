/// Replace these options with the generated options from `flutterfire configure`
/// or your own Firebase project values. This is a placeholder allowing the
/// app to compile while you add real values.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions, FirebaseOptionsPlatform;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // TODO: Replace with your project's FirebaseOptions
    return const FirebaseOptions(
      apiKey: 'REPLACE_WITH_YOUR_API_KEY',
      appId: 'REPLACE_WITH_YOUR_APP_ID',
      messagingSenderId: 'REPLACE_WITH_YOUR_SENDER_ID',
      projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
      authDomain: 'REPLACE',
      storageBucket: 'REPLACE',
    );
  }
}
