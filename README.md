# 🛍️ ZareShop Vendor Mobile App

A comprehensive Flutter vendor management application for Ethiopian marketplace vendors.

![Flutter](https://img.shields.io/badge/Flutter-3.24+-blue)
![Dart](https://img.shields.io/badge/Dart-3.5+-blue)
![BLoC](https://img.shields.io/badge/State%20Management-BLoC-purple)

## ✨ Features

### 🏪 Core Features
- **Product Management** - Add, edit, and manage product inventory
- **Order Management** - Track and fulfill customer orders
- **B2B Marketplace** - Browse and connect with suppliers
- **Supplier Directory** - Search and filter 50+ top-ranked suppliers
- **Wallet Management** - Track earnings, add funds, and request cashouts
- **Messages** - Direct communication with suppliers and customers
- **Cart** - Shopping cart for B2B purchases

### 💳 Payment Integration
- **Chapa SDK** - Ethiopian payment gateway
- Supports: Telebirr, CBE Birr, M-Pesa, E-Birr
- Real-time payment processing
- Automatic wallet fund addition

### 🔔 Real-time Features (WebSocket)
- Vendor approval/rejection notifications
- Live wallet balance updates
- Cashout request status updates
- Auto-reconnection on connection loss

### 🎨 Theme System
5 business-specific themes:
- ☕ **Coffee** - Restaurants/Cafés
- 🌿 **Green** - Organic/Wellness
- 📦 **Basic** - Shops/Marketplaces
- 🌟 **Mustard** - Creative/Marketing
- 🏭 **Beige** - Industrial/Professional

### 🌍 Localization
Multi-language support:
- English
- አማርኛ (Amharic)
- Afaan Oromoo (Oromo)

## 🚀 Quick Start

```bash
# Install dependencies
flutter pub get

# Run on Chrome (Web)
flutter run -d chrome

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios
```

## 🏗️ Architecture

Built with **Clean Architecture** and **BLoC Pattern**:

```
lib/
├── core/
│   ├── navigation/          # GoRouter configuration
│   ├── services/            # API, Storage, WebSocket, Localization
│   └── utils/               # Helpers and utilities
├── features/
│   ├── auth/                # Login & Authentication
│   ├── onboarding/          # Vendor registration (8 steps)
│   ├── products/            # Product management
│   ├── orders/              # Order tracking
│   ├── b2b/                 # B2B marketplace
│   ├── suppliers/           # Supplier directory
│   ├── wallet_management/   # Wallet & transactions
│   ├── messages/            # Chat functionality
│   └── cart/                # Shopping cart
└── shared/
    ├── utils/theme/         # Theme system
    └── widgets/             # Reusable components
```

## 📦 Key Dependencies

```yaml
# State Management
flutter_bloc: ^8.1.6
equatable: ^2.0.5

# Navigation
go_router: ^14.6.2

# Networking
http: ^1.2.2
socket_io_client: ^2.0.3+1

# Payment
chapasdk: ^0.0.8+1

# UI/UX
cached_network_image: ^3.4.1
shimmer: ^3.0.0
fl_chart: ^0.69.2

# Storage
shared_preferences: ^2.3.3

# Localization
intl: ^0.19.0
```

## 🔧 Configuration

### API Endpoints
Update in `lib/core/services/api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:4000/api';
```

### WebSocket
Update in `lib/core/services/socket_service.dart`:
```dart
static const String socketUrl = 'http://localhost:4000';
```

### Chapa Payment Keys
Update in payment dialogs with your keys:
```dart
static const String _chapaPublicKey = 'YOUR_PUBLIC_KEY';
static const String _chapaSecretKey = 'YOUR_SECRET_KEY';
```

## 🎯 App Flow

1. **Splash Screen** → Login
2. **Login** → Dashboard (if authenticated)
3. **Sign Up** → 8-Step Onboarding:
   - Phone & Password
   - OTP Verification
   - Business Info
   - Shipping Address
   - Documents Upload
   - Payout Method
   - Subscription Plan
   - Admin Approval
4. **Dashboard** → Main Navigation (5 tabs)

## 📱 Main Screens

### Bottom Navigation
1. **Home** - B2B Market with categories and products
2. **Suppliers** - Top 50 ranked suppliers with search/filter
3. **Cart** - Shopping cart for B2B orders
4. **Messages** - Chat with suppliers
5. **Products** - Vendor's product inventory

### Additional Screens
- **Settings** - Profile, theme, language, logout
- **Wallet** - Balance, transactions, add funds, cashout
- **Orders** - Order management
- **Product Detail** - View/edit product details
- **Supplier Detail** - View supplier info, contact

## 🎨 UI Features

- **Dynamic Theming** - 5 complete color palettes
- **Responsive Design** - Works on mobile, tablet, web
- **Smooth Animations** - Loading states, transitions
- **Image Caching** - Fast image loading
- **Shimmer Effects** - Professional loading placeholders

## 🔐 Authentication

- Phone number + Password login
- OTP verification
- JWT token management
- Auto-login with stored credentials
- Secure logout with data clearing

## 💰 Wallet Features

- View balance and transaction history
- Add funds via Chapa payment gateway
- Request cashouts
- Real-time balance updates via WebSocket
- Transaction filtering and search

## 🛒 B2B Features

- Browse supplier marketplace
- View top 50 ranked suppliers
- Search and filter suppliers by category
- Contact suppliers directly
- View supplier products and details
- Add products to cart

## 📊 Product Management

- Add new products with images
- Edit existing products
- View product inventory
- Promotions and discounts
- Stock management
- Product status toggle

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Clean and rebuild
flutter clean && flutter pub get
```

## 🚢 Build & Deploy

```bash
# Build APK (Android)
flutter build apk --release

# Build App Bundle (Android)
flutter build appbundle --release

# Build iOS
flutter build ios --release

# Build Web
flutter build web --release
```

## 🐛 Known Issues

- DevTools warnings on web are normal and don't affect functionality
- WebSocket may show connection warnings in debug mode
- Image loading may be slow on first load (cached afterwards)

## 📝 Development Notes

### State Management
- Uses BLoC pattern throughout
- Separate BLoCs for each feature
- Global providers for theme and localization

### Code Organization
- Feature-first structure
- Shared components in `/shared`
- Reusable widgets and utilities
- Clean separation of concerns

### Best Practices
- Null safety enabled
- Proper error handling
- Loading states for async operations
- User feedback via SnackBars
- Consistent theming

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Support

For issues and questions, please open an issue on GitHub.

---

**Built with ❤️ for Ethiopian Vendors** 🇪🇹
