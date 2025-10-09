# Zareshop Vendor App - Architecture Diagram

## 🏗️ Application Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        ZARESHOP VENDOR APP                       │
│                     (Flutter + BLoC Pattern)                     │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                          MAIN.DART                               │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  ZareshopVendorApp (MaterialApp)                       │    │
│  │    ├── Theme: AppTheme.lightTheme                      │    │
│  │    └── Home: MainNavigation                            │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                      MAIN NAVIGATION                             │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  Bottom Navigation Bar (5 Tabs)                        │    │
│  │    ├── Dashboard                                       │    │
│  │    ├── Orders                                          │    │
│  │    ├── Products                                        │    │
│  │    ├── Wallet                                          │    │
│  │    └── Profile                                         │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                                 │
        ┌────────────────────────┼────────────────────────┐
        │                        │                        │
        ▼                        ▼                        ▼
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│   FEATURES   │      │     CORE     │      │     DATA     │
└──────────────┘      └──────────────┘      └──────────────┘
```

---

## 📦 Feature Modules (BLoC Pattern)

```
┌─────────────────────────────────────────────────────────────────┐
│                         FEATURE MODULE                           │
│                    (Dashboard/Orders/Products/                   │
│                      Wallet/Profile)                             │
└─────────────────────────────────────────────────────────────────┘
                                 │
                ┌────────────────┼────────────────┐
                │                │                │
                ▼                ▼                ▼
        ┌──────────┐     ┌──────────┐     ┌──────────┐
        │  SCREEN  │     │   BLOC   │     │  EVENTS  │
        │   (UI)   │────▶│ (Logic)  │◀────│  (User)  │
        └──────────┘     └──────────┘     └──────────┘
                │                │                │
                │                ▼                │
                │         ┌──────────┐           │
                │         │  STATES  │           │
                │         │ (Output) │           │
                │         └──────────┘           │
                │                │                │
                └────────────────┼────────────────┘
                                 │
                                 ▼
                          ┌──────────┐
                          │  MODELS  │
                          │  (Data)  │
                          └──────────┘
```

---

## 🎯 BLoC Flow Diagram

```
┌─────────────┐
│    USER     │
│  INTERFACE  │
└─────────────┘
       │
       │ 1. User Action (Tap, Swipe, etc.)
       │
       ▼
┌─────────────┐
│    EVENT    │
│  (Trigger)  │
└─────────────┘
       │
       │ 2. Event Dispatched
       │
       ▼
┌─────────────┐
│    BLOC     │
│  (Process)  │──────┐
└─────────────┘      │
       │             │ 3. Fetch/Process Data
       │             │    (Mock or API)
       │             │
       │             ▼
       │      ┌─────────────┐
       │      │    DATA     │
       │      │  (Models)   │
       │      └─────────────┘
       │             │
       │◀────────────┘
       │
       │ 4. Emit State
       │
       ▼
┌─────────────┐
│    STATE    │
│  (Result)   │
└─────────────┘
       │
       │ 5. UI Rebuilds
       │
       ▼
┌─────────────┐
│    USER     │
│  INTERFACE  │
│  (Updated)  │
└─────────────┘
```

---

## 📊 Dashboard Feature Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      DASHBOARD SCREEN                            │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  BlocProvider<DashboardBloc>                           │    │
│  │    └── BlocBuilder<DashboardBloc, DashboardState>     │    │
│  │          ├── DashboardLoading → CircularProgress      │    │
│  │          ├── DashboardLoaded → Content                │    │
│  │          └── DashboardError → Error + Retry           │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DASHBOARD BLOC                             │
│  Events:                                                         │
│    ├── LoadDashboardData                                        │
│    ├── RefreshDashboardData                                     │
│    └── ChangeSalesPeriod                                        │
│                                                                  │
│  States:                                                         │
│    ├── DashboardInitial                                         │
│    ├── DashboardLoading                                         │
│    ├── DashboardLoaded (with DashboardStats)                   │
│    └── DashboardError (with message)                            │
│                                                                  │
│  Logic:                                                          │
│    └── _getMockDashboardStats() → Returns sample data          │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DASHBOARD STATS MODEL                       │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  - dailySales: double                                  │    │
│  │  - weeklySales: double                                 │    │
│  │  - monthlySales: double                                │    │
│  │  - pendingOrders: int                                  │    │
│  │  - fulfilledOrders: int                                │    │
│  │  - canceledOrders: int                                 │    │
│  │  - totalProducts: int                                  │    │
│  │  - lowStockProducts: int                               │    │
│  │  - salesChart: List<SalesDataPoint>                    │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📦 Orders Feature Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       ORDERS SCREEN                              │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  BlocProvider<OrdersBloc>                              │    │
│  │    └── BlocConsumer<OrdersBloc, OrdersState>          │    │
│  │          ├── OrdersLoading → CircularProgress          │    │
│  │          ├── OrdersLoaded → ListView                   │    │
│  │          ├── OrderUpdating → Show loading indicator    │    │
│  │          └── OrdersError → Error + Retry               │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                        ORDERS BLOC                               │
│  Events:                                                         │
│    ├── LoadOrders                                               │
│    ├── RefreshOrders                                            │
│    ├── AcceptOrder(orderId)                                     │
│    ├── DeclineOrder(orderId)                                    │
│    ├── UpdateOrderStatus(orderId, status)                       │
│    └── FilterOrdersByStatus(status)                             │
│                                                                  │
│  States:                                                         │
│    ├── OrdersInitial                                            │
│    ├── OrdersLoading                                            │
│    ├── OrdersLoaded (with orders, filterStatus)                │
│    ├── OrderUpdating (orderId)                                  │
│    └── OrdersError (message)                                    │
│                                                                  │
│  Logic:                                                          │
│    └── _getMockOrders() → Returns sample orders                │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                        ORDER MODEL                               │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  Order:                                                │    │
│  │    - id, customerId, customerName                      │    │
│  │    - customerPhone, deliveryAddress                    │    │
│  │    - items: List<OrderItem>                            │    │
│  │    - totalAmount, status, createdAt                    │    │
│  │                                                         │    │
│  │  OrderItem:                                            │    │
│  │    - productId, productName, productImage              │    │
│  │    - quantity, price                                   │    │
│  │                                                         │    │
│  │  OrderStatus (enum):                                   │    │
│  │    - pending, processing, shipped                      │    │
│  │    - completed, canceled                               │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🛍️ Products Feature Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRODUCTS SCREEN                             │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  BlocProvider<ProductsBloc>                            │    │
│  │    └── BlocConsumer<ProductsBloc, ProductsState>      │    │
│  │          ├── ProductsLoading → CircularProgress        │    │
│  │          ├── ProductsLoaded → GridView                 │    │
│  │          ├── ProductOperationSuccess → Snackbar        │    │
│  │          └── ProductsError → Error + Retry             │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                       PRODUCTS BLOC                              │
│  Events:                                                         │
│    ├── LoadProducts                                             │
│    ├── RefreshProducts                                          │
│    ├── AddProduct(product)                                      │
│    ├── UpdateProduct(product)                                   │
│    ├── DeleteProduct(productId)                                 │
│    ├── ToggleProductStatus(productId)                           │
│    └── AddDiscount(productId, discountPrice)                    │
│                                                                  │
│  States:                                                         │
│    ├── ProductsInitial                                          │
│    ├── ProductsLoading                                          │
│    ├── ProductsLoaded (with products)                           │
│    ├── ProductOperationSuccess (message, products)              │
│    └── ProductsError (message)                                  │
│                                                                  │
│  Logic:                                                          │
│    └── _getMockProducts() → Returns sample products            │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                       PRODUCT MODEL                              │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  - id, name, description                               │    │
│  │  - price, discountPrice                                │    │
│  │  - imageUrl, stock, category                           │    │
│  │  - isActive, createdAt                                 │    │
│  │                                                         │    │
│  │  Computed Properties:                                  │    │
│  │    - hasDiscount: bool                                 │    │
│  │    - finalPrice: double                                │    │
│  │    - discountPercentage: int                           │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 💰 Wallet Feature Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       WALLET SCREEN                              │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  BlocProvider<WalletBloc>                              │    │
│  │    └── BlocConsumer<WalletBloc, WalletState>          │    │
│  │          ├── WalletLoading → CircularProgress          │    │
│  │          ├── WalletLoaded → Content                    │    │
│  │          ├── WithdrawalSuccess → Snackbar              │    │
│  │          └── WalletError → Snackbar                    │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                        WALLET BLOC                               │
│  Events:                                                         │
│    ├── LoadWalletData                                           │
│    ├── RefreshWalletData                                        │
│    └── RequestWithdrawal(amount)                                │
│                                                                  │
│  States:                                                         │
│    ├── WalletInitial                                            │
│    ├── WalletLoading                                            │
│    ├── WalletLoaded (with walletData)                          │
│    ├── WithdrawalSuccess (message, walletData)                  │
│    └── WalletError (message)                                    │
│                                                                  │
│  Logic:                                                          │
│    └── _getMockWalletData() → Returns sample wallet data       │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                   TRANSACTION & WALLET MODELS                    │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  Transaction:                                          │    │
│  │    - id, type, amount                                  │    │
│  │    - description, createdAt, orderId                   │    │
│  │                                                         │    │
│  │  TransactionType (enum):                               │    │
│  │    - sale, withdrawal, refund                          │    │
│  │                                                         │    │
│  │  WalletData:                                           │    │
│  │    - balance, totalEarnings                            │    │
│  │    - totalWithdrawals                                  │    │
│  │    - recentTransactions: List<Transaction>             │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 👤 Profile Feature Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      PROFILE SCREEN                              │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  BlocProvider<ProfileBloc>                             │    │
│  │    └── BlocConsumer<ProfileBloc, ProfileState>        │    │
│  │          ├── ProfileLoading → CircularProgress         │    │
│  │          ├── ProfileLoaded → Content                   │    │
│  │          ├── ProfileUpdateSuccess → Snackbar           │    │
│  │          └── ProfileError → Error + Retry              │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                       PROFILE BLOC                               │
│  Events:                                                         │
│    ├── LoadProfile                                              │
│    ├── UpdateProfile(vendor)                                    │
│    └── ChangeLanguage(languageCode)                             │
│                                                                  │
│  States:                                                         │
│    ├── ProfileInitial                                           │
│    ├── ProfileLoading                                           │
│    ├── ProfileLoaded (vendor, currentLanguage)                  │
│    ├── ProfileUpdateSuccess (message, vendor)                   │
│    └── ProfileError (message)                                   │
│                                                                  │
│  Logic:                                                          │
│    └── _getMockVendor() → Returns sample vendor data           │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                       VENDOR MODEL                               │
│  ┌────────────────────────────────────────────────────────┐    │
│  │  - id, shopName, ownerName                             │    │
│  │  - email, phone                                        │    │
│  │  - profileImageUrl, bannerImageUrl                     │    │
│  │  - address, subscriptionPlan                           │    │
│  │  - joinedDate                                          │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎨 Core Components

```
┌─────────────────────────────────────────────────────────────────┐
│                          CORE LAYER                              │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │    THEME     │  │  CONSTANTS   │  │  NAVIGATION  │         │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤         │
│  │ - Colors     │  │ - App Name   │  │ - Bottom Nav │         │
│  │ - Typography │  │ - Languages  │  │ - Routes     │         │
│  │ - Styles     │  │ - Status     │  │ - Tabs       │         │
│  │ - Buttons    │  │ - Periods    │  │              │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📱 Navigation Flow

```
                    Main Navigation
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
   Dashboard          Orders           Products
        │                 │                 │
        │                 │                 │
        ▼                 ▼                 ▼
   [Content]         [Content]         [Content]
        │                 │                 │
        └─────────────────┼─────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
     Wallet            Profile          Settings
        │                 │                 │
        │                 │                 │
        ▼                 ▼                 ▼
   [Content]         [Content]         [Content]
```

---

## 🔄 Data Flow Pattern

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│   USER   │────▶│  EVENT   │────▶│   BLOC   │────▶│  STATE   │
│  ACTION  │     │ DISPATCH │     │ PROCESS  │     │  EMIT    │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
                                         │                 │
                                         │                 │
                                         ▼                 ▼
                                   ┌──────────┐     ┌──────────┐
                                   │   DATA   │     │    UI    │
                                   │  LAYER   │     │ REBUILD  │
                                   └──────────┘     └──────────┘
```

---

## 🎯 Summary

This architecture provides:
- ✅ **Separation of Concerns**: UI, Logic, and Data are separated
- ✅ **Scalability**: Easy to add new features
- ✅ **Testability**: Business logic can be tested independently
- ✅ **Maintainability**: Clear structure and organization
- ✅ **Reusability**: Components can be reused across features
- ✅ **Predictability**: State management is predictable and traceable
