# Onboarding Components Guide

## 🎯 Quick Reference

This guide helps you use the modular onboarding components in your Flutter app.

---

## 📦 Available Components

### 1. **AnimatedCheckboxItem**
Checkbox with scale animation and link support.

```dart
import 'package:zareshop_vendor_app/features/onboarding/widgets/animated_checkbox.dart';

AnimatedCheckboxItem(
  text: 'I agree to the terms',
  value: _agreeToTerms,
  onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
  linkText: 'View terms',  // Optional
  onLinkTap: () => showTermsDialog(),  // Optional
)
```

**Props:**
- `text`: String - Main checkbox text
- `value`: bool - Current checked state
- `onChanged`: Function(bool?) - Callback when changed
- `linkText`: String? - Optional link text
- `onLinkTap`: VoidCallback? - Optional link action

---

### 2. **AnimatedTextField**
Text field with focus glow and stagger animation.

```dart
import 'package:zareshop_vendor_app/features/onboarding/widgets/animated_form_fields.dart';

AnimatedTextField(
  label: 'Email Address',
  hint: 'your@email.com',
  keyboardType: TextInputType.emailAddress,
  index: 0,  // For stagger effect
  onChanged: (value) => handleEmailChange(value),
)
```

**Props:**
- `label`: String - Field label
- `hint`: String - Placeholder text
- `keyboardType`: TextInputType? - Keyboard type
- `maxLines`: int - Number of lines (default: 1)
- `index`: int - Stagger delay multiplier
- `onChanged`: Function(String) - Callback

---

### 3. **AnimatedPhoneField**
Ethiopian phone number input with flag and +251 prefix.

```dart
import 'package:zareshop_vendor_app/features/onboarding/widgets/animated_form_fields.dart';

AnimatedPhoneField(
  onChanged: (phone) => handlePhoneChange(phone),
)
```

**Props:**
- `onChanged`: Function(String) - Callback with +251 prefix

**Features:**
- Ethiopian flag animation
- Auto +251 prefix
- Validates format (9 digits, starts with 9 or 7)

---

### 4. **StepIndicator**
Progress dots and animated progress bar.

```dart
import 'package:zareshop_vendor_app/features/onboarding/widgets/step_indicator.dart';

StepIndicator(
  currentStep: 2,
  totalSteps: 6,
  progress: 0.5,  // 0.0 to 1.0
  onDotTap: (index) => goToStep(index),
)
```

**Props:**
- `currentStep`: int - Current step index
- `totalSteps`: int - Total number of steps
- `progress`: double - Progress percentage (0.0-1.0)
- `onDotTap`: Function(int) - Callback when dot clicked

---

### 5. **AnimatedPaymentMethodCard**
Payment method selection card with animations.

```dart
import 'package:zareshop_vendor_app/features/onboarding/widgets/payment_widgets.dart';

AnimatedPaymentMethodCard(
  label: 'Mobile Wallet',
  value: 'wallet',
  icon: Icons.phone_android,
  isSelected: paymentMethod == 'wallet',
  onTap: () => selectPaymentMethod('wallet'),
  animationDelay: 0,  // 0 or 100 for slide direction
)
```

**Props:**
- `label`: String - Display name
- `value`: String - Internal value
- `icon`: IconData - Icon to display
- `isSelected`: bool - Selected state
- `onTap`: VoidCallback - Tap callback
- `animationDelay`: int - Slide animation delay

---

### 6. **PaymentMethodsList**
Display list of payment methods with verified badge.

```dart
import 'package:zareshop_vendor_app/features/onboarding/widgets/payment_widgets.dart';

PaymentMethodsList(
  isBank: true,
  bankAccountNumber: '1234567890',
  mobileWalletNumber: '+251912345678',
)
```

**Props:**
- `isBank`: bool - Show bank or wallet
- `bankAccountNumber`: String - Bank account
- `mobileWalletNumber`: String - Wallet number

---

### 7. **VendorTypeSelector**
Individual vs Business vendor selection.

```dart
import 'package:zareshop_vendor_app/features/onboarding/widgets/vendor_type_selector.dart';

VendorTypeSelector(
  selectedType: vendorType,
  onTypeSelected: (type) => updateVendorType(type),
)
```

**Props:**
- `selectedType`: String - 'individual' or 'business'
- `onTypeSelected`: Function(String) - Selection callback

---

### 8. **CategorySelector**
Business category grid selector.

```dart
import 'package:zareshop_vendor_app/features/onboarding/widgets/category_selector.dart';

CategorySelector(
  selectedCategory: category,
  onCategorySelected: (cat) => updateCategory(cat),
)
```

**Props:**
- `selectedCategory`: String? - Current category
- `onCategorySelected`: Function(String) - Selection callback

**Categories:**
Electronics, Fashion, Food & Beverage, Beauty & Health, Home & Garden, Sports & Outdoor, Books & Media, Toys & Kids

---

### 9. **ImageUploadField**
Image upload with preview and animations.

```dart
import 'package:zareshop_vendor_app/features/onboarding/widgets/image_upload_field.dart';

ImageUploadField(
  label: 'Business License',
  hint: 'Tap to upload',
  imagePath: licensePath,  // Can be null
  onTap: () => pickImage(),
)
```

**Props:**
- `label`: String - Field label
- `hint`: String - Upload hint text
- `imagePath`: String? - Path to image (optional)
- `onTap`: VoidCallback - Tap to upload

**Supports:**
- Local file paths (mobile/desktop)
- Data URLs (web)
- Network URLs

---

### 10. **OnboardingHeader**
Animated header with collapsible logo.

```dart
import 'package:zareshop_vendor_app/features/onboarding/widgets/onboarding_header.dart';

OnboardingHeader(
  isCollapsed: _isHeaderCollapsed,
)
```

**Props:**
- `isCollapsed`: bool - Collapsed state

---

### 11. **WelcomeSection**
Welcome text with fade/slide animation.

```dart
import 'package:zareshop_vendor_app/features/onboarding/widgets/welcome_section.dart';

WelcomeSection(
  isCollapsed: _isHeaderCollapsed,
)
```

**Props:**
- `isCollapsed`: bool - Visibility state

---

## 🛠️ Utility Functions

### **OnboardingDialogs**

```dart
import 'package:zareshop_vendor_app/features/onboarding/utils/onboarding_dialogs.dart';

// Show terms dialog
OnboardingDialogs.showTermsDialog(context);

// Show success dialog
OnboardingDialogs.showSuccessDialog(
  context,
  title: 'Success!',
  message: 'Your profile is complete',
  onContinue: () => navigateNext(),
);
```

### **OnboardingConstants**

```dart
import 'package:zareshop_vendor_app/features/onboarding/utils/onboarding_constants.dart';

// Colors
OnboardingConstants.primaryGreen
OnboardingConstants.darkGreen
OnboardingConstants.textDark

// Durations
OnboardingConstants.fastAnimation
OnboardingConstants.normalAnimation
OnboardingConstants.slowAnimation

// Spacing
OnboardingConstants.smallSpace
OnboardingConstants.mediumSpace
OnboardingConstants.largeSpace

// Radius
OnboardingConstants.smallRadius
OnboardingConstants.mediumRadius
OnboardingConstants.largeRadius
```

---

## 🎨 Animation Guidelines

### Timing
- **Fast**: 200ms - Simple transitions
- **Normal**: 300ms - Standard animations
- **Slow**: 600ms - Complex animations
- **Elastic**: 800ms - Spring effects

### Curves
- `Curves.easeOut` - Simple fades
- `Curves.easeOutBack` - Slight overshoot
- `Curves.elasticOut` - Spring bounce
- `Curves.easeOutCubic` - Smooth deceleration

### Stagger Delays
- **Sequential**: 50-100ms between items
- **Grouped**: 100-200ms between groups
- **Wave**: index * delay for cascade

---

## 🧪 Testing Components

```dart
testWidgets('AnimatedCheckboxItem works correctly', (tester) async {
  bool checked = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AnimatedCheckboxItem(
          text: 'Test',
          value: checked,
          onChanged: (val) => checked = val ?? false,
        ),
      ),
    ),
  );
  
  // Find and tap checkbox
  await tester.tap(find.byType(Checkbox));
  await tester.pump();
  
  expect(checked, true);
});
```

---

## 💡 Best Practices

1. **Always dispose controllers** - All animated widgets handle this internally
2. **Use constants** - Import from `onboarding_constants.dart`
3. **Clamp opacity** - Always use `.clamp(0.0, 1.0)`
4. **Key animated items** - Use `ValueKey` for AnimatedSwitcher
5. **Test on real devices** - Animations may differ on emulators

---

## 📚 Further Reading

- [Flutter Animation Documentation](https://flutter.dev/docs/development/ui/animations)
- [Widget Composition](https://flutter.dev/docs/development/ui/widgets-intro)
- [Best Practices](https://flutter.dev/docs/perf/best-practices)

---

**Version**: 1.0.0
**Last Updated**: October 15, 2025
