# Bright Calculator (Flutter)

A simple, colorful calculator starter app with:
- Addition, subtraction, multiplication and division
- Percent, sign toggle, decimal point, clear and backspace
- Live result preview and calculation history
- Light/dark themes with a purple accent palette
- Responsive Material 3 interface

## Run it

1. Install Flutter SDK and Android Studio.
2. Extract this ZIP.
3. Open a terminal in this folder and run:

   ```bash
   flutter create .
   flutter pub get
   flutter run
   ```

`flutter create .` generates the Android/iOS platform folders for your computer while preserving the `lib/main.dart` app.

## Build an Android release

```bash
flutter build appbundle --release
```

The Play Store normally expects an Android App Bundle (`.aab`) for a new app. Before publishing, create and securely store your own upload keystore, configure signing in the Android project, add your final app icon, and complete the Play Console store listing, content rating, privacy/data safety forms, and testing requirements. Do not upload an unsigned debug build.

This ZIP contains the Flutter source project, not a published Play Store app or a signed release bundle.
