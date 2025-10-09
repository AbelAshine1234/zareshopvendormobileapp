# 🛍️ Zareshop Vendor App

A comprehensive Flutter vendor management application built with **BLoC architecture** for Ethiopian marketplace vendors.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue)
![Dart](https://img.shields.io/badge/Dart-3.0-blue)
![BLoC](https://img.shields.io/badge/State%20Management-BLoC-purple)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

### 📊 Dashboard
- Sales overview (daily, weekly, monthly)
- Interactive sales chart
- Order statistics with visual indicators
- Quick action shortcuts

### 📦 Orders Management
- Order list with product thumbnails
- Accept/Decline orders
- Update order status (Processing, Shipped, Completed)
- Filter by order status
- Customer information display

### 🛍️ Product Management
- Grid view of products
- Add, edit, and delete products
- Discount management
- Stock tracking with low stock alerts
- Toggle active/inactive status

### 💰 Wallet & Finance
- Balance overview with beautiful gradient card
- Earnings and withdrawal tracking
- Transaction history
- Withdrawal functionality
- Visual charts

### 👤 Profile & Settings
- Vendor profile with banner
- Contact information
- Multi-language support (4 Ethiopian languages)
- Settings and preferences
- Subscription plan display

## 🚀 Quick Start

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 📱 Screenshots

The app includes 5 main screens:
1. **Dashboard** - Sales overview and statistics
2. **Orders** - Order management with status updates
3. **Products** - Product inventory management
4. **Wallet** - Financial tracking and withdrawals
5. **Profile** - Settings and vendor information

## 🏗️ Architecture

This project follows **Clean Architecture** principles with **BLoC pattern** for state management:

```
lib/
├── core/           # Theme, constants, navigation
├── data/           # Data models
└── features/       # Feature modules
    └── [feature]/
        ├── bloc/   # BLoC (events, states, logic)
        └── screens/# UI screens
```

## 🎨 Tech Stack

- **Framework**: Flutter 3.9.2
- **Language**: Dart 3.0
- **State Management**: flutter_bloc
- **Charts**: fl_chart
- **Image Caching**: cached_network_image
- **Formatting**: intl

## 🌍 Localization

Supports 4 Ethiopian languages:
- English (en)
- አማርኛ - Amharic (am)
- Afaan Oromoo (om)
- ትግርኛ - Tigrigna (ti)

## 📚 Documentation

All documentation is organized in the **[docs](docs/)** folder:

- **[Quick Start](docs/QUICK_START.md)** - Get started in 3 steps
- **[Setup Guide](docs/SETUP_GUIDE.md)** - Detailed installation instructions
- **[Project Structure](docs/PROJECT_STRUCTURE.md)** - Folder organization
- **[Features Overview](docs/FEATURES_OVERVIEW.md)** - Detailed feature descriptions
- **[App Architecture](docs/APP_ARCHITECTURE.md)** - Architecture diagrams
- **[Build Summary](docs/BUILD_SUMMARY.md)** - Complete build details

> 💡 **Note**: DevTools warnings when running on web are normal and don't affect functionality.

## 🎯 Key Highlights

✅ **BLoC Architecture** - Clean separation of UI and business logic  
✅ **Ethiopian Context** - Culturally relevant content and languages  
✅ **Beautiful UI** - Modern, professional design  
✅ **Mock Data** - Pre-loaded sample data for testing  
✅ **Production Ready** - Scalable and maintainable structure  
✅ **Comprehensive Features** - All vendor management needs covered  

## 🔧 Development

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio or VS Code
- Android Emulator or iOS Simulator

### Build Commands

```bash
# Run in debug mode
flutter run

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Run tests
flutter test

# Clean build
flutter clean
```

## 📦 Dependencies

```yaml
flutter_bloc: ^8.1.3          # State management
equatable: ^2.0.5             # Value equality
fl_chart: ^0.65.0             # Charts
cached_network_image: ^3.3.0  # Image caching
shimmer: ^3.0.0               # Loading effects
intl: ^0.19.0                 # Formatting
shared_preferences: ^2.2.2    # Local storage
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

Built with ❤️ for Ethiopian Vendors

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- BLoC library for state management
- Ethiopian developer community

---

**Ready to manage your vendor business? Get started now!** 🚀
