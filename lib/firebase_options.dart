import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get web => const FirebaseOptions(
        apiKey: 'AIzaSyBOClan2ER3QJdzjaXLhcKtV2sZm9o2fEE',
        authDomain: 'techcompare-ac51b.firebaseapp.com',
        projectId: 'techcompare-ac51b',
        storageBucket: 'techcompare-ac51b.firebasestorage.app',
        messagingSenderId: '425679233015',
        appId: '1:425679233015:web:df0569f1597f824b2958f2',
      );
  
  static FirebaseOptions get android => const FirebaseOptions(
        apiKey: 'AIzaSyBOClan2ER3QJdzjaXLhcKtV2sZm9o2fEE',
        authDomain: 'techcompare-ac51b.firebaseapp.com',
        projectId: 'techcompare-ac51b',
        storageBucket: 'techcompare-ac51b.firebasestorage.app',
        messagingSenderId: '425679233015',
        appId: '1:425679233015:android:2f7bbf433ca3c82d2958f2',
      );
}