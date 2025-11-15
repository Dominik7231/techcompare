import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get web => const FirebaseOptions(
        apiKey: 'REPLACE_WITH_API_KEY',
        authDomain: 'REPLACE_WITH_AUTH_DOMAIN',
        projectId: 'REPLACE_WITH_PROJECT_ID',
        storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
        messagingSenderId: 'REPLACE_WITH_SENDER_ID',
        appId: 'REPLACE_WITH_APP_ID',
      );
}