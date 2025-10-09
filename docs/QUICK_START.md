# 🚀 Quick Start Guide

## Get Started in 3 Steps!

### Step 1: Install Dependencies
Open your terminal in the project directory and run:

```bash
flutter pub get
```

This will download all required packages.

### Step 2: Run the App
```bash
flutter run
```

Choose your target device (Android emulator, iOS simulator, or Chrome).

### Step 3: Explore!
The app will launch with 5 main screens accessible via bottom navigation:
- 📊 **Dashboard** - Sales overview and statistics
- 📦 **Orders** - Manage incoming orders
- 🛍️ **Products** - Manage your product inventory
- 💰 **Wallet** - View earnings and transactions
- 👤 **Profile** - Settings and vendor information

---

## 📱 What You'll See

### On Launch
- The app opens to the **Dashboard** screen
- Bottom navigation bar with 5 tabs
- Mock data pre-loaded for demonstration

### Dashboard Features
- View daily, weekly, and monthly sales
- See order statistics (pending, fulfilled, canceled)
- Interactive sales chart
- Quick action buttons

### Orders Features
- List of orders with product images
- Accept or decline pending orders
- Update order status
- Filter orders by status
- Pull down to refresh

### Products Features
- Grid view of products
- Add, edit, or delete products
- Add discounts to products
- Toggle product active/inactive
- Low stock indicators
- Floating "Add Product" button

### Wallet Features
- Beautiful balance card with green gradient
- View total earnings and withdrawals
- Transaction history
- Request withdrawal
- Pie chart visualization

### Profile Features
- Vendor profile with banner image
- Contact information
- Change language (4 Ethiopian languages)
- Settings and preferences
- Logout option

---

## 🎮 Try These Actions

### In Dashboard:
1. Pull down to refresh data
2. Tap quick action buttons
3. View the sales chart

### In Orders:
1. Tap the filter icon (top-right)
2. Select "Pending" to see pending orders
3. Tap "Accept" on an order
4. Watch the status change to "Processing"

### In Products:
1. Tap the 3-dot menu on any product
2. Select "Add Discount"
3. Enter a discount price
4. See the discount badge appear

### In Wallet:
1. Tap the "Withdraw" button
2. Enter an amount
3. Confirm withdrawal
4. See the balance update

### In Profile:
1. Tap "Language"
2. Select a different language
3. See the language update
4. Explore settings options

---

## 🎨 Color Scheme

The app uses a beautiful modern green color palette:
- **Emerald Green** (#10B981) - Primary brand color
- **Teal** (#14B8A6) - Secondary accent
- **Cyan** (#06B6D4) - Highlights
- **Success Green** (#22C55E) - Success states
- **Amber** (#F59E0B) - Warnings

---

## 🌍 Language Support

Switch between 4 Ethiopian languages:
- **English** (Default)
- **አማርኛ** (Amharic)
- **Afaan Oromoo** (Oromo)
- **ትግርኛ** (Tigrigna)

Change language from: Profile → Language

---

## 💡 Tips

1. **Pull to Refresh**: All list screens support pull-to-refresh
2. **Mock Data**: The app uses sample data for demonstration
3. **Navigation**: Use bottom nav bar to switch between screens
4. **Dialogs**: Confirmation dialogs appear for important actions
5. **Snackbars**: Success messages appear at the bottom

---

## 🔧 Troubleshooting

### App won't run?
```bash
flutter clean
flutter pub get
flutter run
```

### Dependencies error?
Make sure you have Flutter SDK installed:
```bash
flutter doctor
```

### Build error?
Check that all dependencies are compatible:
```bash
flutter pub upgrade
```

---

## 📚 Learn More

- **Project Structure**: See `PROJECT_STRUCTURE.md`
- **Features**: See `FEATURES_OVERVIEW.md`
- **Architecture**: See `APP_ARCHITECTURE.md`
- **Setup**: See `SETUP_GUIDE.md`
- **Summary**: See `BUILD_SUMMARY.md`

---

## 🎉 Enjoy!

You now have a fully functional vendor management app with:
- ✅ BLoC state management
- ✅ Modern green UI
- ✅ 5 complete features
- ✅ Ethiopian localization
- ✅ Mock data for testing
- ✅ Production-ready structure

**Happy coding! 🚀**
