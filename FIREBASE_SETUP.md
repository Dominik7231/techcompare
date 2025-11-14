# Firebase Setup Guide

Ez az útmutató segít beállítani a Firebase Authentication-t az alkalmazáshoz.

## Szükséges lépések

### 1. Firebase Projekt létrehozása

1. Menj a [Firebase Console](https://console.firebase.google.com/) oldalra
2. Kattints az "Add project" gombra
3. Add meg a projekt nevét (pl. "Tech Compare")
4. Kövesd a lépéseket a projekt létrehozásához

### 2. Android App hozzáadása

1. A Firebase Console-ban válaszd ki a projektet
2. Kattints az Android ikonra (vagy "Add app" → Android)
3. Add meg a következő adatokat:
   - **Package name**: Megtalálható az `android/app/build.gradle.kts` fájlban (pl. `com.example.techcomparev1`)
   - **App nickname** (opcionális): Tech Compare Android
   - **Debug signing certificate SHA-1** (opcionális): Google Sign-In-hoz szükséges
4. Kattints a "Register app" gombra
5. Töltsd le a `google-services.json` fájlt
6. Helyezd el a fájlt: `android/app/google-services.json`

### 3. iOS App hozzáadása (ha iOS-t is támogatsz)

1. A Firebase Console-ban válaszd ki a projektet
2. Kattints az iOS ikonra (vagy "Add app" → iOS)
3. Add meg a következő adatokat:
   - **Bundle ID**: Megtalálható az `ios/Runner.xcodeproj/project.pbxproj` fájlban
   - **App nickname** (opcionális): Tech Compare iOS
4. Kattints a "Register app" gombra
5. Töltsd le a `GoogleService-Info.plist` fájlt
6. Helyezd el a fájlt: `ios/Runner/GoogleService-Info.plist`

### 4. Android build.gradle konfiguráció

#### `android/build.gradle` (project level)

Add hozzá a `dependencies` szekcióhoz:

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

#### `android/app/build.gradle` (app level)

Add hozzá a fájl végére:

```gradle
apply plugin: 'com.google.gms.google-services'
```

### 5. Firebase Authentication engedélyezése

1. A Firebase Console-ban menj az **Authentication** menüpontra
2. Kattints a **Get started** gombra (ha első alkalommal használod)
3. Menj a **Sign-in method** fülre
4. Engedélyezd az **Email/Password** bejelentkezést:
   - Kattints az "Email/Password" sorra
   - Kapcsold be az "Enable" kapcsolót
   - Kattints a "Save" gombra
5. Engedélyezd a **Google** bejelentkezést (opcionális):
   - Kattints a "Google" sorra
   - Kapcsold be az "Enable" kapcsolót
   - Add meg a **Support email**-t
   - Kattints a "Save" gombra
   - **Fontos**: Google Sign-In-hoz szükséges a SHA-1 certificate fingerprint az Android app-hoz

### 6. SHA-1 Certificate lekérése (Google Sign-In-hoz)

#### Windows PowerShell:

```powershell
cd android
.\gradlew signingReport
```

A kimenetben keresd meg a `SHA1` értéket a `Variant: debug` résznél.

#### macOS/Linux:

```bash
cd android
./gradlew signingReport
```

### 7. SHA-1 hozzáadása Firebase-hez

1. A Firebase Console-ban menj a **Project Settings**-hez
2. Válaszd ki az **Android app**-ot
3. Add hozzá a **SHA certificate fingerprints** szekcióhoz a SHA-1 értéket

### 8. FlutterFire CLI telepítése és konfigurálása (Opcionális, de ajánlott)

```bash
# FlutterFire CLI telepítése
dart pub global activate flutterfire_cli

# Firebase konfigurálása
flutterfire configure
```

Ez automatikusan létrehozza a `lib/firebase_options.dart` fájlt, amit importálni kell a `main.dart`-ban.

### 9. Firebase Options importálása (ha FlutterFire CLI-t használtad)

Módosítsd a `lib/main.dart` fájlt:

```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  
  // ... rest of the code
}
```

### 10. Tesztelés

1. Futtasd az alkalmazást: `flutter run`
2. Próbáld ki a regisztrációt email/password-del
3. Próbáld ki a bejelentkezést
4. Próbáld ki a Google Sign-In-t (ha engedélyezted)

## Hibaelhárítás

### Firebase initialization error

- Ellenőrizd, hogy a `google-services.json` (Android) vagy `GoogleService-Info.plist` (iOS) fájlok a megfelelő helyen vannak
- Ellenőrizd, hogy a package name/bundle ID egyezik-e a Firebase projektben beállítottal

### Google Sign-In nem működik

- Ellenőrizd, hogy hozzáadtad-e a SHA-1 certificate fingerprint-et a Firebase Console-ban
- Ellenőrizd, hogy engedélyezted-e a Google Sign-In-t az Authentication beállításokban

### Email/Password regisztráció nem működik

- Ellenőrizd, hogy engedélyezted-e az Email/Password bejelentkezést a Firebase Console-ban
- Ellenőrizd a jelszó követelményeket (minimum 6 karakter)

## További információk

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication Guide](https://firebase.google.com/docs/auth)

