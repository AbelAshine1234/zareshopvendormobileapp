# Zareshop Vendor App - Setup Guide

## Prerequisites

Before running the app, ensure you have:

1. **Flutter SDK** installed (version 3.9.2 or higher)
2. **Dart SDK** (comes with Flutter)
3. **Android Studio** or **VS Code** with Flutter extensions
4. **Android Emulator** or **iOS Simulator** (or physical device)

## Installation Steps

### 1. Clone or Navigate to Project
```bash
cd c:/Users/Abel/Documents/ZareshopVendorApp/zareshop_vendor_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

This will install all required packages:
- flutter_bloc (State management)
- equatable (Value equality)
- fl_chart (Charts and graphs)
- cached_network_image (Image caching)
- shimmer (Loading animations)
- intl (Date/number formatting)
- shared_preferences (Local storage)

### 3. Verify Flutter Installation
```bash
flutter doctor
```

Make sure all required components are installed.

### 4. Run the App

**On Android Emulator/Device:**
```bash
flutter run
```

**On iOS Simulator (macOS only):**
```bash
flutter run -d ios
```

**On Chrome (Web):**
```bash
flutter run -d chrome
```

### 5. Hot Reload
While the app is running, you can make changes to the code and press:
- `r` - Hot reload
- `R` - Hot restart
- `q` - Quit

## Project Structure Overview

```
lib/
├── core/              # Core app functionality (theme, constants, navigation)
├── data/              # Data models
├── features/          # Feature modules (dashboard, orders, products, wallet, profile)
│   └── [feature]/
│       ├── bloc/      # BLoC files (events, states, bloc)
│       └── screens/   # UI screens
└── main.dart          # App entry point
```

## Key Features Implemented

### ✅ Dashboard
- Sales overview (daily, weekly, monthly)
- Order statistics with visual cards
- Sales trend chart
- Quick action buttons

### ✅ Orders Management
- Order list with product thumbnails
- Accept/Decline orders
- Update order status
- Filter by status
- Customer information display

### ✅ Product Management
- Grid view of products
- Add/Edit/Delete products
- Add discounts
- Toggle active/inactive status
- Low stock indicators

### ✅ Wallet/Finance
- Balance overview with gradient card
- Earnings chart
- Transaction history
- Withdrawal functionality

### ✅ Profile & Settings
- Vendor profile with banner
- Contact information
- Language selection (4 languages)
- Settings and preferences
- Subscription plan display

## Testing

Run tests with:
```bash
flutter test
```

## Building for Production

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (macOS only)
```bash
flutter build ios --release
```

## Troubleshooting

### Issue: Dependencies not installing
**Solution:**
```bash
flutter clean
flutter pub get
```

### Issue: Build errors
**Solution:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Issue: Gradle build fails (Android)
**Solution:**
- Check Android Studio is installed
- Update Android SDK
- Check `android/app/build.gradle` for compatibility

### Issue: CocoaPods errors (iOS)
**Solution:**
```bash
cd ios
pod install
cd ..
flutter run
```

## Mock Data

The app currently uses mock data. Each BLoC file contains sample data:
- **Dashboard**: Mock sales statistics and chart data
- **Orders**: Sample orders with Ethiopian names and addresses
- **Products**: Ethiopian cultural products (coffee sets, spices, baskets, etc.)
- **Wallet**: Mock transactions and balance
- **Profile**: Sample vendor profile

## Customization

### Change Theme Colors
Edit `lib/core/theme/app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFF6B4CE6);
static const Color secondaryColor = Color(0xFFFF6B6B);
// ... modify colors as needed
```

### Add More Languages
Edit `lib/core/constants/app_constants.dart`:
```dart
static const List<Map<String, String>> supportedLanguages = [
  {'code': 'en', 'name': 'English'},
  // Add more languages here
];
```

### Modify Mock Data
Each BLoC file has a `_getMock*()` method. Edit these to customize sample data.

## Next Development Steps

1. **Backend Integration**
   - Create API service classes
   - Implement repositories
   - Connect BLoCs to real APIs

2. **Authentication**
   - Add login/registration screens
   - Implement JWT token management
   - Add secure storage

3. **Image Upload**
   - Integrate image_picker package
   - Add image upload for products
   - Implement profile picture upload

4. **Push Notifications**
   - Set up Firebase Cloud Messaging
   - Handle order notifications
   - Add notification settings

5. **Offline Support**
   - Implement local database (Hive/SQLite)
   - Add sync mechanism
   - Cache images and data

## Support

For issues or questions:
- Check Flutter documentation: https://flutter.dev/docs
- BLoC documentation: https://bloclibrary.dev
- Project structure: See `PROJECT_STRUCTURE.md`

## License

This project is for educational/commercial use.
