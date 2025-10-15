# Onboarding Feature

A multi-step onboarding screen for ZareShop Vendor App with BLoC architecture and smooth animations.

## Structure

```
onboarding/
├── bloc/
│   ├── onboarding_bloc.dart           # Main BLoC logic
│   ├── onboarding_event.dart          # All onboarding events
│   └── onboarding_state.dart          # All onboarding states
├── models/
│   └── onboarding_data.dart           # Data models
├── screens/
│   └── onboarding_screen.dart         # Main screen (refactored)
├── widgets/                            # ✨ Modular Components
│   ├── animated_checkbox.dart         # Checkbox with animations
│   ├── animated_form_fields.dart      # Text fields with focus effects
│   ├── payment_widgets.dart           # Payment method cards & lists
│   ├── step_indicator.dart            # Progress dots & animated bar
│   ├── vendor_type_selector.dart      # Individual/Business selector
│   ├── category_selector.dart         # Category grid with 8 options
│   ├── image_upload_field.dart        # Image upload with preview
│   ├── onboarding_header.dart         # Animated collapsible header
│   └── welcome_section.dart           # Welcome text section
├── utils/                              # ✨ Utilities
│   ├── onboarding_constants.dart      # Colors, durations, categories
│   └── onboarding_dialogs.dart        # Reusable dialog utilities
├── README.md                           # This file
├── REFACTORING_SUMMARY.md             # Architecture overview
└── COMPONENT_GUIDE.md                 # Component usage guide
```

## ⭐ What's New - Modular Architecture

The onboarding has been **fully refactored** into reusable, modular components:

### 📦 Reusable Components (11 Widget Files)
1. **AnimatedCheckbox** - Interactive checkbox with scale animations
2. **AnimatedTextField** - Text fields with focus glow effects
3. **AnimatedPhoneField** - Ethiopian phone input with +251 flag
4. **StepIndicator** - Progress dots with spring animations
5. **PaymentMethodCard** - Animated payment selection cards
6. **VendorTypeSelector** - Individual/Business type selection
7. **CategorySelector** - 8 business categories in grid
8. **ImageUploadField** - Upload with animated preview
9. **OnboardingHeader** - Collapsible animated header
10. **WelcomeSection** - Fade/slide welcome text
11. **PaymentMethodsList** - Payment methods with badges

### 🛠️ Utilities (2 Files)
- **OnboardingConstants** - Centralized colors, durations, spacing
- **OnboardingDialogs** - Terms & success dialogs

### 📚 Documentation (3 Files)
- **README.md** - Main documentation (this file)
- **REFACTORING_SUMMARY.md** - Architecture & improvements
- **COMPONENT_GUIDE.md** - Usage guide for all components

---

## Features

### ✨ 6-Step Vendor Onboarding
- **Step 0**: Phone Number & Vendor Type - Ethiopian number validation
- **Step 1**: OTP Verification - 6-digit code entry
- **Step 2**: Basic Info - Business name, description, category
- **Step 3**: Documents - Fayda ID or Business License upload
- **Step 4**: Payout Details - Mobile wallet or bank account
- **Step 5**: Admin Approval - Completion & waiting screen

### 🎨 Modern UI Design
- Clean and modern design inspired by the reference images
- Smooth animations and transitions between steps
- Progress indicator showing completion percentage
- Step list with visual feedback for completed steps
- Responsive layout with proper spacing

### 🔄 Smooth Animations
- Fade and slide transitions between steps
- Progress bar animation
- Button state animations
- Form validation feedback animations

### 🏗️ BLoC Architecture
- Clean separation of business logic and UI
- State management with flutter_bloc
- Immutable states with Equatable
- Event-driven architecture

### ✅ Features
- Step validation before proceeding
- Navigation between completed steps
- Auto-advance after selection (Steps 2 & 3)
- Back button navigation
- Mock data support for testing
- Email validation
- Progress tracking

## Usage

### Navigate to Onboarding Screen

#### Option 1: Without Mock Data (Empty Form)
```dart
context.go('/onboarding');
// or
context.goNamed('onboarding');
```

#### Option 2: With Mock Data (Pre-filled for Testing)
```dart
context.go('/onboarding?mock=true');
```

### Programmatic Usage

```dart
// Navigate to onboarding
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const OnboardingScreen(useMockData: true),
  ),
);
```

## Mock Data

When initialized with mock data, the form is pre-filled with:
- **Full Name**: Arthur Taylor
- **Sells Products Online**: Yes
- **Monthly Revenue**: $5,000 - $10,000
- **Email Address**: arthur.taylor@zareshop.com

## Events

- `InitializeOnboarding(useMockData)` - Initialize with optional mock data
- `NextStep()` - Move to next step
- `PreviousStep()` - Move to previous step
- `GoToStep(step)` - Jump to specific step (if accessible)
- `UpdateFullName(fullName)` - Update full name
- `UpdateSellsProductsOnline(value)` - Update products online status
- `UpdateMonthlyRevenue(revenue)` - Update monthly revenue
- `UpdateEmailAddress(email)` - Update email address
- `CompleteOnboarding()` - Finish onboarding

## States

- `OnboardingInitial` - Initial state
- `OnboardingInProgress` - Active onboarding with current step and data
- `OnboardingCompleted` - Onboarding finished (navigates to dashboard)
- `OnboardingError` - Error state with message

## Validation

Each step has validation:
- **Step 1**: Name must not be empty
- **Step 2**: Must select Yes or No
- **Step 3**: Must select a revenue option
- **Step 4**: Must be a valid email address

Users can only proceed to the next step if the current step is valid.

## Customization

### Adding New Steps

1. Add new field to `OnboardingData` model
2. Add new event in `onboarding_event.dart`
3. Handle event in `onboarding_bloc.dart`
4. Create new widget in `widgets/` folder
5. Add widget to `_getStepWidget()` in `onboarding_screen.dart`
6. Update `totalSteps` and step list

### Changing Colors

The onboarding uses colors from `AppTheme`:
- Primary: `Color(0xFF10B981)` - Emerald Green
- Error: `Color(0xFFEF4444)` - Red
- Warning: `Color(0xFFF59E0B)` - Amber

## Integration

After completing onboarding, the user is automatically navigated to the dashboard (`/`). You can customize this behavior in the `BlocListener` in `onboarding_screen.dart`:

```dart
BlocListener<OnboardingBloc, OnboardingState>(
  listener: (context, state) {
    if (state is OnboardingCompleted) {
      // Save onboarding data
      // Navigate to desired route
      context.go('/');
    }
  },
  // ...
)
```

## Testing

The onboarding includes support for mock data to facilitate testing:

```dart
// For manual testing
context.go('/onboarding?mock=true');

// For widget testing
testWidgets('Onboarding with mock data', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: OnboardingScreen(useMockData: true),
    ),
  );
  // Test assertions...
});
```

## Notes

- The onboarding automatically advances after selecting options in Steps 2 and 3
- Users can navigate back to completed steps by tapping on them in the step list
- The finish button is only enabled when all steps are completed
- Email validation uses a standard regex pattern
- All animations use Material Design motion curves
