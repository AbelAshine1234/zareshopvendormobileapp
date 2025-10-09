# Zareshop Vendor App - Project Structure

## Overview
This is a Flutter vendor management application built with **BLoC architecture** for Ethiopian marketplace vendors. The app includes comprehensive features for managing products, orders, wallet, and vendor profile.

## Folder Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # App-wide constants (languages, status codes)
│   ├── theme/
│   │   └── app_theme.dart              # App theme and colors
│   └── navigation/
│       └── main_navigation.dart        # Bottom navigation bar
│
├── data/
│   └── models/
│       ├── product_model.dart          # Product data model
│       ├── order_model.dart            # Order and OrderItem models
│       ├── transaction_model.dart      # Transaction and WalletData models
│       ├── vendor_model.dart           # Vendor profile model
│       └── dashboard_stats.dart        # Dashboard statistics model
│
├── features/
│   ├── dashboard/
│   │   ├── bloc/
│   │   │   ├── dashboard_bloc.dart     # Dashboard business logic
│   │   │   ├── dashboard_event.dart    # Dashboard events
│   │   │   └── dashboard_state.dart    # Dashboard states
│   │   └── screens/
│   │       └── dashboard_screen.dart   # Dashboard UI
│   │
│   ├── orders/
│   │   ├── bloc/
│   │   │   ├── orders_bloc.dart        # Orders business logic
│   │   │   ├── orders_event.dart       # Orders events
│   │   │   └── orders_state.dart       # Orders states
│   │   └── screens/
│   │       └── orders_screen.dart      # Orders management UI
│   │
│   ├── products/
│   │   ├── bloc/
│   │   │   ├── products_bloc.dart      # Products business logic
│   │   │   ├── products_event.dart     # Products events
│   │   │   └── products_state.dart     # Products states
│   │   └── screens/
│   │       └── products_screen.dart    # Products management UI
│   │
│   ├── wallet/
│   │   ├── bloc/
│   │   │   ├── wallet_bloc.dart        # Wallet business logic
│   │   │   ├── wallet_event.dart       # Wallet events
│   │   │   └── wallet_state.dart       # Wallet states
│   │   └── screens/
│   │       └── wallet_screen.dart      # Wallet/Finance UI
│   │
│   └── profile/
│       ├── bloc/
│       │   ├── profile_bloc.dart       # Profile business logic
│       │   ├── profile_event.dart      # Profile events
│       │   └── profile_state.dart      # Profile states
│       └── screens/
│           └── profile_screen.dart     # Profile & Settings UI
│
└── main.dart                           # App entry point
```

## Features

### 1. Dashboard Screen
- **Sales Overview**: Daily, weekly, and monthly sales cards
- **Sales Chart**: Weekly sales trend bar chart
- **Order Statistics**: Pending, fulfilled, and canceled orders count
- **Quick Actions**: Shortcuts to add products, view orders, wallet, and profile

### 2. Orders Management Screen
- **Order List**: Display all orders with product thumbnails
- **Order Details**: Customer info, delivery address, order items
- **Status Management**: Accept/Decline pending orders
- **Status Updates**: Update order status (Processing, Shipped, Completed)
- **Filter**: Filter orders by status
- **Pull to Refresh**: Refresh order list

### 3. Product Management Screen
- **Grid View**: Products displayed in a 2-column grid
- **Product Cards**: Show product image, name, price, stock, and discount badge
- **Actions**: Edit, Add Discount, Toggle Active/Inactive, Delete
- **Low Stock Indicator**: Visual indicator for products with stock < 10
- **Floating Action Button**: Quick add product button
- **Pull to Refresh**: Refresh product list

### 4. Wallet/Finance Screen
- **Balance Card**: Beautiful gradient card with cultural-inspired design
- **Balance Overview**: Available balance, total earnings, total withdrawals
- **Earnings Chart**: Pie chart showing balance vs withdrawals
- **Transaction List**: Recent transactions with type indicators
- **Withdraw Button**: Request withdrawal with validation
- **Pull to Refresh**: Refresh wallet data

### 5. Profile & Settings Screen
- **Profile Header**: Banner image with profile picture overlay
- **Contact Information**: Owner name, email, phone, address, join date
- **Language Selector**: Support for English, Amharic, Afan Oromo, Tigrigna
- **Settings**: Notifications toggle, change password, payment methods
- **Subscription**: Display current plan with upgrade option
- **Support**: Help & support, about, logout

## BLoC Architecture

Each feature follows the BLoC pattern:
- **Events**: User actions (LoadData, UpdateItem, etc.)
- **States**: UI states (Loading, Loaded, Error, etc.)
- **BLoC**: Business logic that transforms events into states

## Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3          # State management
  equatable: ^2.0.5             # Value equality
  fl_chart: ^0.65.0             # Charts
  cached_network_image: ^3.3.0  # Image caching
  shimmer: ^3.0.0               # Loading shimmer
  intl: ^0.19.0                 # Internationalization
  shared_preferences: ^2.2.2    # Local storage
```

## How to Run

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the App**:
   ```bash
   flutter run
   ```

3. **Build for Release**:
   ```bash
   # Android
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   ```

## Mock Data

Currently, the app uses mock data for demonstration. All BLoC files contain `_getMock*()` methods that generate sample data. To integrate with a real backend:

1. Create a `data/repositories/` folder
2. Create repository classes for each feature
3. Implement API calls in repositories
4. Update BLoC files to use repositories instead of mock data

## Color Scheme

- **Primary**: #6B4CE6 (Purple)
- **Secondary**: #FF6B6B (Red)
- **Accent**: #FFA500 (Orange)
- **Success**: #4CAF50 (Green)
- **Warning**: #FFC107 (Yellow)
- **Error**: #F44336 (Red)

## Supported Languages

- English (en)
- አማርኛ - Amharic (am)
- Afaan Oromoo (om)
- ትግርኛ - Tigrigna (ti)

## Next Steps

1. **Backend Integration**: Connect to real API endpoints
2. **Authentication**: Implement login/registration
3. **Image Upload**: Add image picker for products and profile
4. **Push Notifications**: Implement FCM for order notifications
5. **Analytics**: Add analytics tracking
6. **Offline Support**: Implement local caching with Hive or SQLite
7. **Testing**: Add unit tests and widget tests
8. **Localization**: Implement full i18n support

## Notes

- All screens support pull-to-refresh
- Bottom navigation allows easy switching between features
- Error handling with retry functionality
- Loading states with circular progress indicators
- Success messages with snackbars
- Confirmation dialogs for destructive actions
