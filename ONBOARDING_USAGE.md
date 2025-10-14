# Onboarding Feature - Usage Guide

## 🎉 Feature Complete!

The onboarding feature has been successfully created with:
- ✅ BLoC folder structure
- ✅ Multi-step form with 4 stages
- ✅ Smooth animations between steps
- ✅ Mock data support
- ✅ Full validation

## Quick Start

### 1. Navigate to Onboarding

#### From any screen in the app:
```dart
import 'package:go_router/go_router.dart';

// Navigate to onboarding (empty form)
context.go('/onboarding');

// Navigate to onboarding with mock data (pre-filled)
context.go('/onboarding?mock=true');
```

### 2. Test URLs

Open these URLs in your app to test:
- **Empty Form**: `/onboarding`
- **With Mock Data**: `/onboarding?mock=true`

### 3. Programmatic Navigation

```dart
// Option 1: Using GoRouter
context.goNamed('onboarding');

// Option 2: Direct navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const OnboardingScreen(useMockData: true),
  ),
);
```

## Features Implemented

### 🔢 4-Step Process

**Step 1: Full Name**
- Text input field
- Real-time validation
- Shows confirmation when completed
- Auto-focus on field
- Submit with Enter/Next key

**Step 2: Do you sell products online?**
- Yes/No button selection
- Smooth hover/selection animations
- Auto-advances to next step after selection

**Step 3: Average Monthly Revenue**
- 5 revenue range options:
  - Less than $1,000
  - $1,000 - $5,000
  - $5,000 - $10,000
  - $10,000 - $50,000
  - More than $50,000
- Radio-style selection
- Auto-advances to next step after selection

**Step 4: Email Address**
- Email input field
- Real-time email validation
- Visual feedback for valid/invalid emails
- Error messages for invalid format

### 🎨 Design Features

- **Modern UI** - Clean, professional design matching ZareShop brand
- **Smooth Animations**:
  - Fade in/out transitions between steps
  - Progress bar animation
  - Button state changes
  - Validation feedback animations
- **Progress Tracking**:
  - Visual progress bar (0-100%)
  - Step counter (1/4, 2/4, etc.)
  - Completed step indicators
- **Interactive Step List**:
  - Click on completed steps to go back
  - Visual feedback for current step
  - Checkmarks for completed steps
  - Numbered badges for pending steps

### 🏗️ BLoC Architecture

```
lib/features/onboarding/
├── bloc/
│   ├── onboarding_bloc.dart      # Business logic
│   ├── onboarding_event.dart     # Events (9 events)
│   └── onboarding_state.dart     # States (4 states)
├── models/
│   └── onboarding_data.dart      # Data model + revenue options
├── screens/
│   └── onboarding_screen.dart    # Main screen (500+ lines)
├── widgets/
│   ├── full_name_step.dart       # Step 1 widget
│   ├── sells_products_step.dart  # Step 2 widget
│   ├── monthly_revenue_step.dart # Step 3 widget
│   └── email_address_step.dart   # Step 4 widget
└── README.md                      # Detailed documentation
```

## Mock Data

When testing with mock data (`?mock=true`), the form is pre-filled with:
```dart
Full Name: Arthur Taylor
Sells Products Online: Yes
Monthly Revenue: $5,000 - $10,000
Email Address: arthur.taylor@zareshop.com
```

## Validation Rules

- **Full Name**: Must not be empty
- **Sells Products Online**: Must select Yes or No
- **Monthly Revenue**: Must select one option
- **Email Address**: Must match email format (xxx@xxx.xxx)

Users cannot proceed to the next step until the current step is valid.

## Navigation Flow

1. User enters data for each step
2. "Continue" button enables when step is valid
3. Steps 2 & 3 auto-advance after 400ms delay
4. User can go back to any completed step
5. When all 4 steps complete, "Finish" button appears
6. Upon finishing, user is redirected to dashboard (`/`)

## Customization

### Change Initial Route

Edit `lib/core/navigation/app_router.dart`:
```dart
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/onboarding', // Change this
    // ...
  );
}
```

### Modify Redirect After Completion

Edit `lib/features/onboarding/screens/onboarding_screen.dart`:
```dart
BlocListener<OnboardingBloc, OnboardingState>(
  listener: (context, state) {
    if (state is OnboardingCompleted) {
      // Change this navigation
      context.go('/'); // Your desired route
    }
  },
  // ...
)
```

### Add More Steps

1. Add field to `OnboardingData` model
2. Add update event to `onboarding_event.dart`
3. Handle event in `onboarding_bloc.dart`
4. Create widget in `widgets/` folder
5. Add to `_getStepWidget()` switch statement
6. Update `totalSteps` constant

## Testing Commands

```bash
# Analyze onboarding code
flutter analyze lib/features/onboarding

# Run the app
flutter run

# Build for production
flutter build apk
flutter build ios
```

## Screenshots Reference

The design was inspired by:
- Modern Shopify-style onboarding
- Multi-step form with animations
- Clean progress indicators
- Interactive step navigation

## Next Steps

To make this a complete user flow:

1. **Add Splash Screen** - Show before onboarding
2. **Check Onboarding Status** - Skip if already completed
3. **Save Data** - Store onboarding data in SharedPreferences
4. **API Integration** - Send data to backend
5. **Welcome Screen** - Show after completion

## Support

For questions or issues:
- See: `lib/features/onboarding/README.md`
- Check: BLoC documentation
- Review: Widget implementation files
