# Wynford Weather Mission

A secure weather alert system with Admin and Public access built with Flutter & Firebase.

Quick setup:
1. Install Flutter 3.10+ and Dart 3+
2. Create a Firebase project and enable:
   - Authentication (Email/Password, Phone)
   - Firestore
   - Cloud Messaging
3. Add Android `google-services.json` and iOS `GoogleService-Info.plist` to respective platform folders.
4. Replace `lib/firebase_options.dart` with your generated FirebaseOptions (or run `flutterfire configure`).
5. (Optional but required for server-side push) Deploy Cloud Function in `functions/` folder to send topic notifications.
6. Add a real custom alert sound at `assets/sounds/scary_alert.wav` (WAV). For iOS/Android platform integration see below.
7. Run:
   flutter pub get
   flutter run

iOS code signing:
- For development you can run on a device without App Store signing by setting a development team in Xcode, or use a simulator that doesn't require signing.
- For TestFlight/App Store follow normal Apple signing steps.

Cloud Function (example):
- We include a sample Cloud Function (under functions/) that sends notifications to the `public` topic when an admin writes to `notifications` collection.
- Deploy with Firebase CLI:
  cd functions
  npm install
  firebase deploy --only functions

Push notifications:
- Public users are subscribed to the `public` topic.
- Admins create a notification document in Firestore or use the Cloud Function to forward it to FCM.
- For production, use server keys or Cloud Functions for sending FCM messages.

SMS authentication:
- The app uses Firebase Phone authentication flow. Ensure phone sign-in is enabled.

Assets:
- Replace the placeholder sound at assets/sounds/scary_alert.wav with a real .wav file.
- For Android put the sound file under android/app/src/main/res/raw (create raw folder) and name it `scary_alert.wav`.
- For iOS add the sound to Runner project and ensure it is included in the bundle.

Security:
- Use Firebase Security Rules to restrict Firestore writes: only authenticated admins can write warnings/notifications.

This repository contains a functional example app. Replace the Firebase options and platform files with your project-specific credentials.
