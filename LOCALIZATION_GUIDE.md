# Localization System for Zareshop Vendor App

This document explains how to use the comprehensive localization system implemented for the Zareshop Vendor App, supporting English, Amharic, and Oromo languages.

## 📁 File Structure

```
assets/localization/
├── en.json          # English translations
├── am.json          # Amharic translations (አማርኛ)
└── om.json          # Oromo translations (Afaan Oromoo)

lib/core/services/
└── localization_service.dart  # Main localization service

lib/examples/
└── localization_example.dart   # Usage examples
```

## 🚀 Quick Start

### 1. Basic Usage

```dart
import '../core/services/localization_service.dart';

// Method 1: Using extension method (recommended)
Text('auth.login.welcome'.tr())

// Method 2: Using service directly
Text(LocalizationService.instance.get('auth.login.subtitle'))

// Method 3: Using LocalizedText widget
const LocalizedText('auth.login.phoneNumber')
```

### 2. With Parameters

```dart
// For dynamic content
Text('auth.forgotPassword.otpSent'.tr(params: {
  'phoneNumber': '+251912345678'
}))
```

### 3. Language Switching

```dart
// Change language
await LocalizationService.instance.loadLanguage('am'); // Amharic
await LocalizationService.instance.loadLanguage('om'); // Oromo
await LocalizationService.instance.loadLanguage('en'); // English

// Get current language
String currentLang = LocalizationService.instance.currentLanguage;

// Get supported languages
List<Map<String, String>> languages = LocalizationService.instance.supportedLanguages;
```

## 📝 Translation Keys Structure

The translation keys follow a hierarchical structure:

```json
{
  "app": {
    "name": "Zareshop Vendor",
    "version": "1.0.0"
  },
  "auth": {
    "login": {
      "title": "Login",
      "welcome": "Welcome Back!",
      "subtitle": "Login to manage your shop..."
    },
    "forgotPassword": {
      "title": "Reset Password",
      "phoneNumber": "Phone Number"
    }
  },
  "common": {
    "loading": "Loading...",
    "error": "Error",
    "save": "Save"
  }
}
```

## 🔧 Implementation Examples

### Updating Existing Screens

**Before:**
```dart
Text('Welcome Back!')
Text('Login to manage your shop and grow your business.')
Text('Phone Number')
```

**After:**
```dart
Text('auth.login.welcome'.tr())
Text('auth.login.subtitle'.tr())
Text('auth.login.phoneNumber'.tr())
```

### Language Selector Widget

```dart
DropdownButton<String>(
  value: LocalizationService.instance.currentLanguage,
  items: LocalizationService.instance.supportedLanguages.map((lang) {
    return DropdownMenuItem<String>(
      value: lang['code'],
      child: Text(lang['name']!),
    );
  }).toList(),
  onChanged: (String? newLanguage) async {
    if (newLanguage != null) {
      await LocalizationService.instance.loadLanguage(newLanguage);
      // Trigger rebuild
      setState(() {});
    }
  },
)
```

### Error Handling

```dart
// The service automatically falls back to English if a language fails to load
// If a translation key is not found, it returns the key itself
Text('nonexistent.key'.tr()) // Returns: "nonexistent.key"
```

## 🌐 Supported Languages

| Code | Language | Native Name |
|------|----------|-------------|
| `en` | English | English |
| `am` | Amharic | አማርኛ |
| `om` | Oromo | Afaan Oromoo |
| `ti` | Tigrigna | ትግርኛ |

## 📋 Available Translation Categories

- **app**: App name, version, description
- **common**: Common UI elements (buttons, labels, etc.)
- **auth**: Authentication screens (login, forgot password, OTP)
- **onboarding**: Onboarding flow screens
- **dashboard**: Dashboard and main app screens
- **profile**: Profile and settings screens
- **orders**: Order management screens
- **products**: Product management screens
- **wallet**: Wallet and payment screens
- **settings**: App settings screens
- **errors**: Error messages
- **validation**: Form validation messages
- **languages**: Language names
- **themes**: Theme-related text

## 🔄 Adding New Translations

### 1. Add to English (en.json)
```json
{
  "newSection": {
    "newKey": "New English Text"
  }
}
```

### 2. Add to Amharic (am.json)
```json
{
  "newSection": {
    "newKey": "አዲስ አማርኛ ጽሑፍ"
  }
}
```

### 3. Add to Oromo (om.json)
```json
{
  "newSection": {
    "newKey": "Qabiyyee Afaan Oromoo Haaraa"
  }
}
```

### 4. Use in Code
```dart
Text('newSection.newKey'.tr())
```

## 🎯 Best Practices

1. **Use descriptive keys**: `auth.login.welcome` instead of `welcome`
2. **Group related translations**: Keep related text under the same section
3. **Use parameters for dynamic content**: `'user.greeting'.tr(params: {'name': userName})`
4. **Test all languages**: Ensure translations work in all supported languages
5. **Keep translations consistent**: Use the same terminology across the app
6. **Handle missing translations gracefully**: The service returns the key if translation is missing

## 🚨 Important Notes

- The app initializes with English (`en`) by default
- Language switching requires calling `loadLanguage()` and rebuilding the UI
- All translation files must have the same key structure
- Missing translations fall back to the key name itself
- The service is a singleton, so language changes affect the entire app

## 🔧 Troubleshooting

### Translation not showing
- Check if the key exists in the JSON file
- Verify the key path is correct (use dots for nesting)
- Ensure the language file is loaded properly

### Language not switching
- Make sure to call `loadLanguage()` before rebuilding UI
- Check if the language code is supported
- Verify the JSON file exists in `assets/localization/`

### Performance issues
- The service loads translations once and caches them
- Language switching is fast after initial load
- Consider lazy loading for very large translation files

## 📞 Support

For questions or issues with the localization system, please refer to the development team or create an issue in the project repository.
