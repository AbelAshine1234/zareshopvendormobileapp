# Zareshop Vendor App - Features Overview

## 📱 Application Screens

### 1. 📊 Dashboard Screen
**Purpose**: Central hub for vendor business overview

**Visual Elements**:
- **Sales Overview Cards**:
  - Daily Sales (Purple card with calendar icon)
  - Weekly Sales (Red card with week icon)
  - Monthly Sales (Orange card with month icon)
  - Each card shows formatted currency (ETB)

- **Weekly Sales Chart**:
  - Interactive bar chart
  - 7 days of data (Mon-Sun)
  - Visual representation of sales trends
  - Color-coded bars in primary purple

- **Order Statistics**:
  - Pending Orders (Yellow/Warning color)
  - Fulfilled Orders (Green/Success color)
  - Canceled Orders (Red/Error color)
  - Icon-based visual indicators

- **Quick Actions Grid**:
  - Add Product (Purple)
  - View Orders (Red)
  - Wallet (Orange)
  - Profile (Green)
  - Large icons with labels

**Interactions**:
- Pull-to-refresh to update data
- Tap quick action buttons to navigate
- Auto-refresh on screen focus

---

### 2. 📦 Orders Management Screen
**Purpose**: Handle incoming orders and update order status

**Visual Elements**:
- **Order Cards**:
  - Order ID with status badge
  - Product thumbnail (60x60)
  - Customer name, phone, address
  - Order date and time
  - Total amount in ETB
  - Status color-coded chips

- **Status Badges**:
  - PENDING (Yellow/Orange)
  - PROCESSING (Blue)
  - SHIPPED (Purple)
  - COMPLETED (Green)
  - CANCELED (Red)

- **Action Buttons**:
  - Accept/Decline for pending orders
  - Update Status for active orders
  - Color-coded buttons

**Interactions**:
- Filter orders by status (top-right menu)
- Accept order → Changes to Processing
- Decline order → Shows confirmation dialog
- Update Status → Shows radio button dialog
- Pull-to-refresh to reload orders
- Tap card to view full details

**Ethiopian Context**:
- Ethiopian names (Abebe, Tigist, Dawit)
- Ethiopian addresses (Bole, Piazza, Merkato)
- Ethiopian phone format (+251)

---

### 3. 🛍️ Product Management Screen
**Purpose**: Manage product inventory and pricing

**Visual Elements**:
- **Grid Layout**: 2 columns
- **Product Cards**:
  - Product image (140px height)
  - Discount badge (top-right corner)
  - Product name (2 lines max)
  - Original price (strikethrough if discounted)
  - Discount price (bold, purple)
  - Stock count with icon
  - Low stock warning (red) if < 10
  - Inactive overlay if not active

- **Action Menu** (3-dot button):
  - Edit Product
  - Add Discount
  - Activate/Deactivate
  - Delete (red text)

- **Floating Action Button**:
  - "Add Product" extended FAB
  - Purple background
  - Bottom-right corner

**Interactions**:
- Tap product → View details
- Tap menu → Show actions
- Add Discount → Shows dialog with price input
- Delete → Shows confirmation dialog
- Toggle status → Instant update with overlay
- Pull-to-refresh to reload products

**Ethiopian Products**:
- Traditional Coffee Set
- Ethiopian Spice Mix (Berbere, Mitmita)
- Handwoven Basket (Mesob)
- Cotton Shawl (Netela)
- Ethiopian Honey
- Leather Bag

---

### 4. 💰 Wallet/Finance Screen
**Purpose**: Track earnings and manage withdrawals

**Visual Elements**:
- **Balance Card** (Gradient):
  - Purple to red gradient background
  - Wallet icon in semi-transparent container
  - Large balance amount (36px font)
  - Total Earnings indicator
  - Total Withdrawals indicator
  - White "Withdraw" button
  - Cultural-inspired gradient design

- **Earnings Chart**:
  - Pie chart showing balance vs withdrawals
  - Color-coded sections
  - Center space for visual appeal

- **Transaction List**:
  - Transaction type icon (up/down arrows)
  - Description text
  - Date and time
  - Amount with +/- indicator
  - Color-coded by type:
    - Sale (Green, down arrow)
    - Withdrawal (Red, up arrow)
    - Refund (Yellow, refresh icon)

**Interactions**:
- Tap Withdraw → Shows dialog
- Enter amount → Validates against balance
- Confirms withdrawal → Updates balance
- Pull-to-refresh to reload data
- Tap transaction → View details

**Currency**:
- All amounts in Ethiopian Birr (ETB)
- Formatted with 2 decimal places

---

### 5. 👤 Profile & Settings Screen
**Purpose**: Manage vendor profile and app settings

**Visual Elements**:
- **Profile Header**:
  - Banner image (180px height)
  - Circular profile picture (100px)
  - White border around avatar
  - Shop name (24px bold)
  - Subscription badge (Premium/Basic)

- **Contact Information Card**:
  - Icon-based rows
  - Owner name
  - Email address
  - Phone number
  - Physical address
  - Join date

- **Language Selector**:
  - Current language display
  - Arrow indicator
  - Tap to show dialog with 4 options:
    - English
    - አማርኛ (Amharic)
    - Afaan Oromoo
    - ትግርኛ (Tigrigna)

- **Settings Section**:
  - Notifications toggle
  - Change Password
  - Payment Methods
  - Upgrade Plan (gold accent)

- **Support Section**:
  - Help & Support
  - About
  - Logout (red text)

**Interactions**:
- Tap Edit (top-right) → Edit profile
- Tap Language → Shows language dialog
- Toggle Notifications → Updates preference
- Tap Logout → Shows confirmation dialog
- Each setting item navigates to detail screen

---

## 🎨 Design System

### Color Palette
- **Primary**: #6B4CE6 (Purple) - Main brand color
- **Secondary**: #FF6B6B (Red) - Accent color
- **Accent**: #FFA500 (Orange) - Highlights
- **Success**: #4CAF50 (Green) - Positive actions
- **Warning**: #FFC107 (Yellow) - Warnings
- **Error**: #F44336 (Red) - Errors/Destructive actions
- **Background**: #F5F5F5 (Light gray)
- **Card**: #FFFFFF (White)

### Typography
- **Headings**: Bold, 18-24px
- **Body**: Regular, 14-16px
- **Captions**: 12px, gray
- **Currency**: Bold, 16-36px depending on context

### Spacing
- Card padding: 16px
- Section spacing: 24px
- Element spacing: 8-12px
- Screen padding: 16px

### Components
- **Cards**: Rounded corners (12px), elevation 2
- **Buttons**: Rounded (8px), padding 12-24px
- **Chips**: Rounded (12px), semi-transparent background
- **Icons**: 20-32px depending on context

---

## 🔄 BLoC State Management

Each feature follows this pattern:

### Events (User Actions)
- Load Data
- Refresh Data
- Update Item
- Delete Item
- Filter/Sort

### States (UI States)
- Initial
- Loading
- Loaded (with data)
- Error (with message)
- Success (with confirmation)

### Flow
1. User triggers event (tap, pull-to-refresh)
2. BLoC receives event
3. BLoC emits Loading state
4. BLoC processes (API call or mock data)
5. BLoC emits Loaded/Error state
6. UI rebuilds based on state

---

## 📊 Data Flow

```
User Action → Event → BLoC → State → UI Update
     ↑                                    ↓
     └────────── User sees result ────────┘
```

---

## 🌍 Localization Support

Currently supports 4 Ethiopian languages:
- **English** (en) - Default
- **Amharic** (am) - አማርኛ
- **Afan Oromo** (om) - Afaan Oromoo
- **Tigrigna** (ti) - ትግርኛ

Language can be changed from Profile & Settings screen.

---

## 📱 Bottom Navigation

5 main sections accessible via bottom navigation bar:
1. **Dashboard** (Home icon)
2. **Orders** (Shopping bag icon)
3. **Products** (Inventory icon)
4. **Wallet** (Wallet icon)
5. **Profile** (Person icon)

Selected item highlighted in primary purple color.

---

## ✨ User Experience Features

- **Pull-to-Refresh**: All list screens support pull-to-refresh
- **Loading States**: Circular progress indicators during data fetch
- **Error Handling**: Error screens with retry button
- **Empty States**: Friendly messages when no data
- **Confirmation Dialogs**: For destructive actions (delete, decline)
- **Success Feedback**: Snackbars for successful operations
- **Smooth Animations**: Transitions between screens
- **Responsive Design**: Adapts to different screen sizes

---

## 🚀 Performance Optimizations

- **Image Caching**: Using cached_network_image
- **Lazy Loading**: Lists load efficiently
- **State Preservation**: Navigation maintains state
- **Optimized Rebuilds**: BLoC prevents unnecessary rebuilds
- **Mock Data**: Fast initial load for demo

---

## 📈 Future Enhancements

1. **Real-time Updates**: WebSocket for live order notifications
2. **Analytics Dashboard**: More detailed charts and insights
3. **Bulk Operations**: Select multiple products/orders
4. **Export Data**: Export reports to PDF/Excel
5. **Dark Mode**: Theme switching
6. **Biometric Auth**: Fingerprint/Face ID
7. **Multi-vendor**: Support for multiple shops
8. **Chat**: Customer communication
9. **Inventory Alerts**: Low stock notifications
10. **Sales Forecasting**: AI-powered predictions
