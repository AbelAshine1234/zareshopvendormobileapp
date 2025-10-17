# 🛍️ Zareshop Vendor App - Complete Documentation

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue)
![Dart](https://img.shields.io/badge/Dart-3.0-blue)
![BLoC](https://img.shields.io/badge/State%20Management-BLoC-purple)
![License](https://img.shields.io/badge/License-MIT-green)

A comprehensive Flutter vendor management application built with **BLoC architecture** for Ethiopian marketplace vendors.

## 📋 Table of Contents

1. [Quick Start](#-quick-start)
2. [Features Overview](#-features-overview)
3. [Project Structure](#-project-structure)
4. [Shared Components](#-shared-components)
5. [Onboarding System](#-onboarding-system)
6. [Authentication](#-authentication)
7. [API Integration](#-api-integration)
8. [Testing](#-testing)
9. [Build & Deployment](#-build--deployment)
10. [Contributing](#-contributing)

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.9.2+
- Dart 3.0+
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd zareshopvendormobileapp

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Development Setup

```bash
# Start Android emulator
flutter emulators --launch Medium_Phone_API_36.1

# Run with hot reload
flutter run --hot

# Run tests
flutter test

# Build for release
flutter build apk --release
```

## ✨ Features Overview

### 📊 Dashboard
- **Sales Overview**: Daily, weekly, monthly analytics
- **Interactive Charts**: Visual sales data representation
- **Order Statistics**: Real-time order metrics
- **Quick Actions**: Fast access to common tasks

### 📦 Orders Management
- **Order List**: Product thumbnails and details
- **Status Management**: Accept/Decline/Update orders
- **Filtering**: Filter by order status
- **Customer Info**: Complete customer details

### 🛍️ Product Management
- **Product Grid**: Visual product overview
- **CRUD Operations**: Add, edit, delete products
- **Inventory**: Stock tracking with alerts
- **Discounts**: Price management system

### 💰 Wallet & Finance
- **Balance Overview**: Beautiful gradient cards
- **Transaction History**: Complete financial records
- **Withdrawals**: Easy money withdrawal
- **Analytics**: Visual financial charts

### 👤 Profile & Settings
- **Vendor Profile**: Complete business information
- **Multi-language**: 4 Ethiopian languages
- **Settings**: Comprehensive preferences
- **Subscription**: Plan management

### 🎯 Onboarding System
- **Multi-step Process**: Guided vendor registration
- **Data Validation**: Real-time form validation
- **Progress Tracking**: Visual step indicators
- **Error Handling**: User-friendly error messages

## 🏗️ Project Structure

```
lib/
├── core/                           # Core app functionality
│   ├── constants/                  # App-wide constants
│   ├── navigation/                 # Navigation logic
│   ├── services/                   # Core services
│   ├── theme/                      # Legacy theme (deprecated)
│   └── utils/                      # Utility functions
│
├── shared/                         # 🆕 Global shared components
│   ├── theme/
│   │   └── app_theme.dart          # Unified app theme
│   └── widgets/
│       ├── forms/
│       │   └── app_text_field.dart # Global text fields
│       ├── buttons/
│       │   └── app_buttons.dart    # Global buttons
│       ├── cards/
│       │   └── app_cards.dart      # Global cards
│       ├── common/
│       │   └── app_widgets.dart    # Common widgets
│       └── widgets.dart            # Export file
│
├── data/
│   └── models/                     # Data models
│       ├── product_model.dart
│       ├── order_model.dart
│       ├── transaction_model.dart
│       ├── vendor_model.dart
│       └── dashboard_stats.dart
│
├── features/                       # Feature modules
│   ├── auth/                       # Authentication
│   ├── dashboard/                  # Main dashboard
│   ├── onboarding/                 # Vendor onboarding
│   ├── orders/                     # Order management
│   ├── products/                   # Product management
│   ├── profile/                    # User profile
│   ├── sales/                      # Sales analytics
│   ├── settings/                   # App settings
│   └── wallet/                     # Financial management
│
└── main.dart                       # App entry point
```

## 🎨 Shared Components

### Theme System
The app uses a unified theme system located in `lib/shared/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:zareshopvendormobileapp/shared/shared.dart';

// Usage in widgets
Text('Hello', style: AppTheme.titleLarge),
Container(decoration: AppTheme.cardDecoration),
ElevatedButton(style: AppTheme.primaryButtonStyle),
```

### Global Widgets

#### Text Fields
```dart
// Basic text field
AppTextField(
  label: 'Full Name',
  hint: 'Enter your full name',
  onChanged: (value) => print(value),
  required: true,
)

// Specialized fields
AppEmailField(onChanged: (email) => print(email))
AppPhoneField(onChanged: (phone) => print(phone))
AppPasswordField(onChanged: (password) => print(password))
```

#### Buttons
```dart
// Primary button
AppPrimaryButton(
  text: 'Continue',
  onPressed: () => print('Pressed'),
  isLoading: false,
  icon: Icons.arrow_forward,
)

// Secondary button
AppSecondaryButton(
  text: 'Cancel',
  onPressed: () => print('Cancelled'),
)

// Button group
AppButtonGroup(
  primaryText: 'Save',
  onPrimaryPressed: () => print('Save'),
  secondaryText: 'Cancel',
  onSecondaryPressed: () => print('Cancel'),
)
```

#### Cards
```dart
// Basic card
AppCard(
  child: Text('Content'),
  onTap: () => print('Tapped'),
)

// Step card with header
AppStepCard(
  title: 'Personal Information',
  subtitle: 'Enter your details',
  icon: Icons.person,
  child: Column(children: [...]),
)

// Info card
AppInfoCard(
  title: 'Success',
  message: 'Profile updated successfully',
  icon: Icons.check_circle,
  color: AppTheme.successGreen,
)

// Progress card
AppProgressCard(
  currentStep: 2,
  totalSteps: 4,
  stepTitles: ['Basic', 'Business', 'Contact', 'Review'],
)
```

#### Common Widgets
```dart
// Loading indicator
AppLoadingIndicator(message: 'Please wait...')

// Divider with text
AppDivider(text: 'OR')

// Badge
AppBadge(text: 'New', icon: Icons.star)

// Step indicator
AppStepIndicator(
  currentStep: 1,
  totalSteps: 4,
  stepLabels: ['Start', 'Info', 'Review', 'Done'],
)

// Snackbar
AppSnackBar.show(
  context: context,
  message: 'Success!',
  type: SnackBarType.success,
)
```

## 🎯 Onboarding System

### Architecture
The onboarding system follows BLoC pattern with these components:

```
lib/features/onboarding/
├── bloc/
│   ├── onboarding_bloc.dart        # Business logic
│   ├── onboarding_event.dart       # Events
│   └── onboarding_state.dart       # States
├── models/
│   └── onboarding_data.dart        # Data model
├── screens/
│   └── onboarding_screen.dart      # Main screen
└── widgets/                        # Step widgets
    ├── steps/
    └── common/
```

### Usage
```dart
// Navigate to onboarding
Navigator.pushNamed(context, '/onboarding');

// Listen to onboarding state
BlocListener<OnboardingBloc, OnboardingState>(
  listener: (context, state) {
    if (state is OnboardingSuccess) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  },
  child: OnboardingScreen(),
)
```

### Data Model
```dart
class OnboardingData {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String businessName;
  final String businessType;
  final String businessAddress;
  // ... other fields
  
  // Validation methods
  bool get isBasicInfoValid => fullName.isNotEmpty && email.isNotEmpty;
  bool get isBusinessInfoValid => businessName.isNotEmpty;
  bool get isComplete => isBasicInfoValid && isBusinessInfoValid;
}
```

## 🔐 Authentication

### Flow
1. **Login/Register**: User credentials validation
2. **Token Management**: JWT token storage and refresh
3. **Protected Routes**: Automatic authentication checks
4. **Logout**: Secure session termination

### Implementation
```dart
// Login
context.read<AuthBloc>().add(LoginRequested(email, password));

// Check authentication status
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthAuthenticated) {
      return DashboardScreen();
    }
    return LoginScreen();
  },
)
```

## 🌐 API Integration

### Base Configuration
```dart
class ApiService {
  static const String baseUrl = 'https://api.zareshop.com';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
```

### Error Handling
The app includes comprehensive error handling:
- Network connectivity issues
- Server errors (4xx, 5xx)
- Timeout handling
- User-friendly error messages

### Token Management
- Automatic token refresh
- Secure token storage
- Token expiration handling

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/onboarding/onboarding_bloc_test.dart
```

### Test Structure
```
test/
├── features/
│   ├── onboarding/
│   │   ├── onboarding_bloc_test.dart
│   │   └── onboarding_screen_test.dart
│   └── auth/
│       └── auth_bloc_test.dart
├── shared/
│   └── widgets/
│       └── app_widgets_test.dart
└── widget_test.dart
```

## 📱 Build & Deployment

### Android Build
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App bundle for Play Store
flutter build appbundle --release
```

### iOS Build
```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

### Build Configuration
- **Minimum SDK**: Android 21, iOS 11.0
- **Target SDK**: Android 34, iOS 17.0
- **Permissions**: Internet, Camera, Storage

## 🤝 Contributing

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable names
- Add comments for complex logic
- Maintain consistent formatting

### Pull Request Process
1. Fork the repository
2. Create feature branch
3. Make changes with tests
4. Submit pull request
5. Code review and merge

### Commit Messages
```
feat: add user authentication
fix: resolve onboarding navigation issue
docs: update API documentation
refactor: improve widget structure
test: add unit tests for auth bloc
```

## 📚 Additional Resources

### Documentation Files (Legacy - Now Consolidated)
- ~~API_INTEGRATION.md~~ → See [API Integration](#-api-integration)
- ~~APP_ARCHITECTURE.md~~ → See [Project Structure](#-project-structure)
- ~~AUTH_IMPLEMENTATION.md~~ → See [Authentication](#-authentication)
- ~~BUILD_SUMMARY.md~~ → See [Build & Deployment](#-build--deployment)
- ~~FEATURES_OVERVIEW.md~~ → See [Features Overview](#-features-overview)
- ~~ONBOARDING_COMPLETE.md~~ → See [Onboarding System](#-onboarding-system)
- ~~PROJECT_STRUCTURE.md~~ → See [Project Structure](#-project-structure)
- ~~SETUP_GUIDE.md~~ → See [Quick Start](#-quick-start)

### Key Improvements Made
1. **🎨 Unified Theme System**: Single source of truth for styling
2. **🧩 Global Widgets**: Reusable components across the app
3. **📚 Consolidated Documentation**: Single comprehensive guide
4. **🔧 Improved Architecture**: Better separation of concerns
5. **🚀 Enhanced Developer Experience**: Easier to maintain and extend

### Migration Guide
When updating existing code to use the new shared components:

```dart
// Old onboarding-specific imports
import '../../core/onboarding_theme.dart';
import '../../widgets/form/onboarding_text_field.dart';

// New shared imports
import 'package:zareshopvendormobileapp/shared/shared.dart';

// Old widget usage
OnboardingTextField(...)
OnboardingPrimaryButton(...)

// New widget usage
AppTextField(...)
AppPrimaryButton(...)
```

---

**Last Updated**: October 2024  
**Version**: 2.0.0  
**Maintainer**: Development Team

For questions or support, please create an issue in the repository.
