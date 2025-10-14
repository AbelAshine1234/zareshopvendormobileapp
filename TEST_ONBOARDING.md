# 🚀 Quick Test Guide - Onboarding Feature

## Instant Testing (Choose One Method)

### Method 1: Test Button on Dashboard (Recommended)
Add this to your dashboard screen to quickly access onboarding:

**File**: `lib/features/dashboard/screens/dashboard_screen.dart`

Add a floating action button or test button:
```dart
FloatingActionButton.extended(
  onPressed: () => context.go('/onboarding?mock=true'),
  icon: Icon(Icons.assignment),
  label: Text('Test Onboarding'),
)
```

### Method 2: Change App Starting Point
Make onboarding the first screen users see:

**File**: `lib/core/navigation/app_router.dart`

```dart
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/onboarding', // ← Change from '/' to '/onboarding'
    routes: [
      // ... rest of routes
    ],
  );
}
```

### Method 3: Test from Any Screen
From anywhere in your app:
```dart
// Button example
ElevatedButton(
  onPressed: () {
    context.go('/onboarding?mock=true');
  },
  child: Text('Start Onboarding'),
)
```

## 🎯 Testing URLs

Navigate to these routes:

1. **Empty Form**: 
   ```dart
   context.go('/onboarding');
   ```

2. **Pre-filled Mock Data**: 
   ```dart
   context.go('/onboarding?mock=true');
   ```

## 📱 What to Test

### Step 1: Full Name
- [ ] Type your name
- [ ] See green checkmark appear
- [ ] Press "Continue" or Enter key
- [ ] Verify transition animation

### Step 2: Sell Products Online?
- [ ] Click "Yes" or "No"
- [ ] See button highlight
- [ ] Watch auto-advance after 400ms
- [ ] Verify smooth transition

### Step 3: Monthly Revenue
- [ ] Select one of 5 options
- [ ] See selection highlight
- [ ] Watch auto-advance after 400ms
- [ ] Verify animation

### Step 4: Email Address
- [ ] Type email address
- [ ] Test invalid email (see red error)
- [ ] Type valid email (see green check)
- [ ] Press "Finish"
- [ ] Verify redirect to dashboard

### Navigation Features
- [ ] Click "Back" button
- [ ] Click on completed steps in list
- [ ] Watch progress bar update
- [ ] See percentage increase

## 🎨 Design Elements to Verify

Visual Checklist:
- [ ] ZareShop header with shopping bag icon
- [ ] Green progress bar animating
- [ ] Step numbers/checkmarks
- [ ] Smooth fade transitions
- [ ] Helper text changing per step
- [ ] Form validation feedback
- [ ] Button state changes

## 🐛 Common Issues & Fixes

### Issue: "Undefined name 'context'"
**Fix**: Already resolved in the code ✅

### Issue: App doesn't navigate
**Check**: Route is added in `app_router.dart` ✅

### Issue: Mock data doesn't load
**Use**: `/onboarding?mock=true` (not just `/onboarding`)

## 📊 Expected Behavior

### With Mock Data (`?mock=true`):
```
Full Name: "Arthur Taylor" ✓
Sells Products: Yes ✓
Revenue: "$5,000 - $10,000" ✓
Email: "arthur.taylor@zareshop.com" ✓
```

### Without Mock Data:
```
All fields empty
User must fill each step
Validation enforced
Progress tracking active
```

## 🎬 Demo Flow

**Perfect Testing Sequence**:

1. Run: `flutter run`
2. Navigate: `/onboarding?mock=true`
3. Observe: Pre-filled data
4. Click: "Continue" through each step
5. Watch: Animations and transitions
6. Complete: Redirect to dashboard
7. Return: Test again without mock data

## ⚡ Quick Commands

```bash
# Run the app
flutter run

# Hot reload after changes
# Press 'r' in terminal

# Analyze for issues
flutter analyze lib/features/onboarding

# Check all files
find lib/features/onboarding -type f -name "*.dart"
```

## 🎯 Success Criteria

You'll know it's working when:
- ✅ All 4 steps display correctly
- ✅ Progress bar animates smoothly
- ✅ Validation works on each step
- ✅ Can navigate back and forth
- ✅ Auto-advance works on steps 2 & 3
- ✅ Completes and redirects to dashboard

## 📸 What You Should See

**Step 1**: Text input with "Enter your Full name" placeholder
**Step 2**: Two big buttons "Yes" and "No"
**Step 3**: 5 radio-style revenue options
**Step 4**: Email input with validation

**All Steps Include**:
- Progress bar at top
- Step list on left
- Current step highlighted
- Back/Continue buttons at bottom

## 🚀 Ready to Test!

Choose your testing method and start exploring the onboarding flow!

**Recommended**: Start with Method 1 (test button) using mock data to see all features immediately.

---

**Questions?** Check:
- `ONBOARDING_COMPLETE.md` - Full summary
- `ONBOARDING_USAGE.md` - Detailed usage
- `lib/features/onboarding/README.md` - Technical docs
