#  Kigali City Services & Places Directory

A Flutter mobile application to help Kigali residents locate and navigate to essential public services and lifestyle locations. Built with Firebase Authentication, Cloud Firestore, Google Maps, and Provider state management.

---

## Features

| Feature | Details |
|---|---|
| **Authentication** | Email/password sign-up & login, email verification |
| **Directory (CRUD)** | Create, read, update, delete listings in Firestore |
| **Real-time sync** | UI updates instantly via Firestore streams |
| **Search & Filter** | Search by name/address; filter by category |
| **Detail Page** | Full listing info + embedded Google Map + reviews |
| **Navigation** | One-tap Google Maps turn-by-turn directions |
| **Map View** | All listings as markers on an interactive map |
| **My Listings** | Manage your own listings; edit or delete them |
| **Reviews** | Leave star ratings and comments on any listing |
| **Settings** | Profile info, notification toggles (local prefs) |
| **State Management** | Provider pattern; no direct Firestore calls in UI |

---

## Project Structure

```
lib/
├── main.dart                   # App entry point & router
├── firebase_options.dart       #  Requires your Firebase credentials
├── models/
│   ├── listing.dart            # Listing & Review models
│   └── user_profile.dart       # UserProfile model
├── services/
│   ├── auth_service.dart       # Firebase Auth wrapper
│   └── firestore_service.dart  # Firestore CRUD + streams
├── providers/
│   ├── auth_provider.dart      # Auth state (Provider)
│   └── listings_provider.dart  # Listings state (Provider)
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── home/
│   │   └── home_screen.dart    # BottomNavigationBar shell
│   ├── directory/
│   │   ├── directory_screen.dart
│   │   ├── listing_detail_screen.dart
│   │   └── add_edit_listing_screen.dart
│   ├── my_listings/
│   │   └── my_listings_screen.dart
│   ├── map/
│   │   └── map_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── widgets/
│   └── listing_card.dart       # Reusable card + category chip
└── utils/
    └── theme.dart              # Dark theme + AppConstants
```

---

##  Setup Instructions

### Prerequisites
- Flutter SDK ≥ 3.0.0 installed
- A Firebase account
- A Google Cloud account (for Maps API)

---

### Step 1 — Clone & Install Dependencies

```bash
flutter pub get
```

---

### Step 2 — Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add project** → name it (e.g., `kigali-city-services`)
3. Enable **Google Analytics** (optional)

---

### Step 3 — Enable Firebase Services

Inside your Firebase project:

#### Authentication
- Go to **Authentication → Get started**
- Enable **Email/Password** sign-in method

#### Cloud Firestore
- Go to **Firestore Database → Create database**
- Start in **production mode**
- Deploy the security rules from `firestore.rules`:
  ```bash
  firebase deploy --only firestore:rules
  ```
  Or paste them manually in **Firestore → Rules** tab.

---

### Step 4 — Configure Firebase in Flutter (Recommended: FlutterFire CLI)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# From your project root:
flutterfire configure
```

This auto-generates `lib/firebase_options.dart` with your real credentials and downloads `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).

#### Manual Alternative
Copy your Firebase config values into `lib/firebase_options.dart`, replacing all `YOUR_*` placeholders.

---

### Step 5 — Get a Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Create or select a project (link it to your Firebase project)
3. Enable these APIs:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
   - **Directions API** (for navigation)
4. Create an **API Key**

#### Android
In `android/app/src/main/AndroidManifest.xml`, replace:
```xml
android:value="YOUR_GOOGLE_MAPS_API_KEY"
```

#### iOS
In `ios/Runner/AppDelegate.swift`, add:
```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(...) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    ...
  }
}
```

Also in `ios/Runner/Info.plist`, add:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby services.</string>
```

---

### Step 6 — Run the App

```bash
flutter run
```

---

##  Firestore Data Schema

### `listings` collection
```json
{
  "name": "Kimironko Café",
  "category": "Café",
  "address": "Kimironko, Kigali",
  "contactNumber": "+250 788 000 000",
  "description": "Popular neighborhood café...",
  "latitude": -1.9355,
  "longitude": 30.1012,
  "createdBy": "uid_of_creator",
  "timestamp": "2024-01-01T00:00:00Z",
  "rating": 4.3,
  "reviewCount": 45
}
```

### `users` collection
```json
{
  "email": "user@example.com",
  "displayName": "Eric Mugisha",
  "phoneNumber": "+250 788 111 111",
  "createdAt": "2024-01-01T00:00:00Z",
  "notificationsEnabled": true
}
```

### `reviews` collection
```json
{
  "listingId": "listing_doc_id",
  "userId": "reviewer_uid",
  "userName": "Sarah",
  "comment": "Great coffee and friendly staff!",
  "rating": 5.0,
  "timestamp": "2024-01-02T00:00:00Z"
}
```

---

##  Key Dependencies

| Package | Purpose |
|---|---|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Authentication |
| `cloud_firestore` | Database + real-time streams |
| `provider` | State management |
| `google_maps_flutter` | Embedded maps |
| `geolocator` | Device GPS location |
| `url_launcher` | Launch Google Maps navigation |
| `shared_preferences` | Local notification preferences |

---

##  Architecture

```
UI Widgets
    │
    ▼ watch / read
Providers (AuthProvider, ListingsProvider)
    │
    ▼ call methods
Services (AuthService, FirestoreService)
    │
    ▼ stream / future
Firebase (Auth, Firestore)
```

- **No direct Firestore calls in UI** — all data access goes through services → providers
- **Real-time updates** via Firestore `snapshots()` streams subscribed in providers
- **Auth routing** — `_AppRouter` in `main.dart` watches `AuthProvider.status` and renders Login or Home

---

##  Design

Dark navy theme (`#0D1B2A`) with amber/gold accent (`#F5A623`), inspired by the provided UI mockup. All screens use a consistent color palette, card style, and typography.
