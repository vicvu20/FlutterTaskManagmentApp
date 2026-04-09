# CSC 4360 CW-03 — Level Up Life

This project is a Flutter + Firebase Firestore task management app built for the CSC 4360 CRUD assignment.

## Features
- Create tasks
- Real-time task stream with Firestore
- Toggle task completion
- Delete tasks
- Nested subtasks
- Search/filter tasks and subtasks
- Priority tags
- Dark/light theme toggle
- Progress tracker and simple XP/level display

## Folder Structure
- `lib/models/` → Task model
- `lib/services/` → Firestore service
- `lib/screens/` → main screen
- `lib/widgets/` → reusable task card widget

## Setup
1. Create a Flutter project or use this one.
2. Run:
   - `flutter pub get`
3. Configure Firebase:
   - `flutterfire configure`
4. Make sure `lib/firebase_options.dart` exists.
5. In Firebase console, enable Firestore in test mode.
6. Run:
   - `flutter run`

## Build APK
```bash
flutter build apk
```

APK output:
```bash
build/app/outputs/flutter-apk/app-release.apk
```

## Firestore Rules for Development
```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```



