# API Integration Guide

## ✅ Backend Integration Complete!

Your Flutter app is now fully integrated with your Express.js backend API.

## 🔑 Key Changes

### 1. **Vendor Type Mapping**
- **Individual Vendor** → Creates **CLIENT** account (`/register-client`)
- **Business Vendor** → Creates **VENDOR_OWNER** account (`/register-vendor-owner`)

### 2. **API Service** (`lib/core/services/api_service.dart`)
Centralized service for all backend calls:
- Login
- Register Client
- Register Vendor Owner
- Verify OTP
- Resend OTP
- Forgot Password
- Verify Reset OTP
- Reset Password
- Get Current User
- Token Management

### 3. **Updated Flows**

#### **Onboarding Flow** (Sign Up)
```
Step 0 (Phone + Vendor Type) 
  → API: POST /register-client OR /register-vendor-owner
  → OTP sent to phone

Step 1 (Enter OTP)
  → API: POST /verify-otp
  → User verified

Steps 2-5 (Complete Profile)
  → Local data collection
  → Submit to backend when ready
```

#### **Login Flow**
```
Login Screen
  → API: POST /login
  → Token + User data saved
  → Navigate to Dashboard
```

#### **Forgot Password Flow**
```
Step 1: Enter Phone
  → API: POST /forgot-password
  → OTP sent

Step 2: Enter OTP + New Password
  → API: POST /verify-reset-otp (get reset token)
  → API: POST /reset-password (with token)
  → Password reset successful
```

## 🔧 Configuration Required

### **Update Backend URL**

Edit `/lib/core/services/api_service.dart` line 7:

```dart
static const String baseUrl = 'http://YOUR_BACKEND_URL/api/auth';
```

Replace `YOUR_BACKEND_URL` with:
- **Local development**: `http://10.0.2.2:3000` (Android Emulator)
- **Local development**: `http://localhost:3000` (iOS Simulator)
- **Production**: `https://your-domain.com` (Deployed backend)

### **For Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api/auth';
```

### **For iOS Simulator:**
```dart
static const String baseUrl = 'http://localhost:3000/api/auth';
```

### **For Real Device (same network):**
```dart
// Replace with your computer's IP address
static const String baseUrl = 'http://192.168.1.XXX:3000/api/auth';
```

## 📝 Registration Password

Since the onboarding flow doesn't ask for a password initially, a temporary password is generated:

```dart
final tempPassword = 'Temp@${phoneNumber.replaceAll('+', '')}123';
```

Example: For phone `+251912345678` → Password: `Temp@251912345678123`

### **Options:**
1. **Communicate password to user via SMS** after registration
2. **Add password field** in onboarding Step 3 (Basic Info)
3. **Force password reset** on first login

## 🔐 Token Management

Tokens are automatically saved to SharedPreferences:

```dart
// Save token
await ApiService.saveToken(token);

// Get token
final token = await ApiService.getToken();

// Logout
await ApiService.logout(); // Clears token and user data
```

## 📱 API Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/login` | POST | User login with phone & password |
| `/register-client` | POST | Register individual vendor (CLIENT) |
| `/register-vendor-owner` | POST | Register business vendor (VENDOR_OWNER) |
| `/verify-otp` | POST | Verify OTP code |
| `/resend-otp` | POST | Resend OTP |
| `/forgot-password` | POST | Send password reset OTP |
| `/verify-reset-otp` | POST | Verify reset OTP, get reset token |
| `/reset-password` | POST | Reset password with token |
| `/me` | GET | Get current authenticated user |

## 🧪 Testing

### **1. Install Dependencies**
```bash
flutter pub get
```

### **2. Run the App**
```bash
flutter run
```

### **3. Test Individual Vendor (CLIENT)**
1. Open app → Login screen
2. Click "Sign Up"
3. Enter phone: `+251912345678`
4. Select: **Individual Vendor**
5. Click "Continue"
6. Backend creates **CLIENT** account
7. Enter OTP received
8. Complete profile

### **4. Test Business Vendor (VENDOR_OWNER)**
Same as above, but select **Business Vendor** in step 4
- Backend creates **VENDOR_OWNER** account

### **5. Test Login**
1. Open app → Login screen
2. Enter registered phone + password
3. Click "Login"
4. Should navigate to Dashboard

### **6. Test Forgot Password**
1. Click "Forgot Password?"
2. Enter phone number
3. Enter OTP received
4. Enter new password
5. Submit → Password reset successful

## ⚠️ Important Notes

### **Error Handling**
All API calls return:
```dart
{
  'success': true/false,
  'data': {...},  // on success
  'error': '...'  // on failure
}
```

### **OTP Verification Required**
- **CLIENT** accounts need OTP verification
- **VENDOR_OWNER** accounts need OTP verification
- **ADMIN** accounts skip OTP verification (backend logic)

### **User Type Field**
Backend expects `type` field:
- `'client'` for individual vendors
- `'vendor_owner'` for business vendors

### **Phone Number Format**
Always send with country code: `+251912345678`

## 🐛 Common Issues

### **Network Error on Android Emulator**
Make sure to use `http://10.0.2.2:3000` instead of `localhost`

### **CORS Issues**
Ensure your backend has CORS enabled for the frontend domain

### **OTP Not Received**
Check Twilio configuration in your backend

### **Login Failed After Registration**
Remember the temporary password format or check backend logs

## 🚀 Next Steps

1. **Update baseUrl** in `api_service.dart`
2. **Add password field** to onboarding (recommended)
3. **Test all flows** with your backend
4. **Handle vendor approval** status from `/me` endpoint
5. **Add profile image upload** support
6. **Implement session management** (token refresh)

## 📦 New Dependencies Added

```yaml
http: ^1.1.0  # For API calls
```

Run `flutter pub get` to install!

## 🎉 Summary

✅ Individual vendors → CLIENT accounts
✅ Business vendors → VENDOR_OWNER accounts  
✅ OTP sent and verified via backend
✅ Login integrated with backend
✅ Forgot password flow complete
✅ Token management implemented
✅ Error handling for all API calls

The app is ready to communicate with your backend! Just update the `baseUrl` and test!
