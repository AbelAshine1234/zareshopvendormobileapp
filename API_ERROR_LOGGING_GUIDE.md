# API Error Logging Guide

## Overview
The `registerBusinessVendor` method now has comprehensive logging that clearly distinguishes between **API errors** (backend issues) and **CLIENT errors** (frontend/code issues).

---

## 🔍 How to Identify Error Source

### 1. **CLIENT SIDE ERRORS** 💥
These errors occur in your Flutter app code **before** or **during** the API request.

#### Error Indicators:
- **Error Source: CLIENT SIDE**
- Occurs in these stages:
  - **STAGE 1**: Authentication Check
  - **STAGE 3**: Image Processing
  - **Exception During Registration**: Network/connectivity issues

#### Common Client Errors:

**Authentication Error:**
```
❌ [API_SERVICE] CLIENT ERROR: No auth token found
❌ [API_SERVICE] Error Source: CLIENT SIDE
```
**Cause:** User not logged in or token expired
**Fix:** Ensure user completes OTP verification

**Image Processing Error (Web):**
```
💥 [API_SERVICE] CLIENT ERROR: Image Processing Failed
💥 [API_SERVICE] Error Source: CLIENT SIDE (Web Image Processing)
💥 [API_SERVICE] Platform: WEB
```
**Cause:** Invalid blob URL, unsupported image format, or file read failure
**Fix:** Validate image selection and format before upload

**File Processing Error (Mobile):**
```
💥 [API_SERVICE] CLIENT ERROR: File Processing Failed
💥 [API_SERVICE] Error Source: CLIENT SIDE (Mobile File Processing)
💥 [API_SERVICE] Platform: MOBILE/DESKTOP
```
**Cause:** File not found, invalid path, or permission issues
**Fix:** Check file paths and storage permissions

**Network Exception:**
```
💥 [API_SERVICE] CLIENT ERROR - Exception During Registration
💥 [API_SERVICE] Error Source: CLIENT SIDE
💥 [API_SERVICE] Possible Causes:
   • Network connectivity issues
   • Timeout during request
   • Invalid file paths or permissions
   • Memory issues with large files
```
**Cause:** Network disconnected, timeout, or memory issues
**Fix:** Check internet connection, reduce image sizes

---

### 2. **API/BACKEND ERRORS** ❌
These errors come from the **backend server** after receiving your request.

#### Error Indicators:
- **Error Source: BACKEND API**
- Occurs in these stages:
  - **STAGE 5**: Processing API Response

#### Common API Errors:

**Empty Response:**
```
⚠️ [API_SERVICE] API ERROR: Empty Response
⚠️ [API_SERVICE] Error Source: BACKEND API
⚠️ [API_SERVICE] Status Code: 500
```
**Cause:** Server crashed or returned nothing
**Fix:** Contact backend team, check server logs

**Invalid JSON Response:**
```
💥 [API_SERVICE] API ERROR: Invalid JSON Response
💥 [API_SERVICE] Error Source: BACKEND API (Invalid Response Format)
💥 [API_SERVICE] Status Code: 500
💥 [API_SERVICE] Raw Response Body: <html>Internal Server Error</html>
```
**Cause:** Server returned HTML error page instead of JSON
**Fix:** Backend issue - check server error logs

**Validation Errors:**
```
❌ [API_SERVICE] API ERROR - Business vendor registration failed
❌ [API_SERVICE] Error Source: BACKEND API
❌ [API_SERVICE] Status Code: 400
❌ [API_SERVICE] Error Message: Invalid category IDs
❌ [API_SERVICE] Validation Errors: {...}
```
**Cause:** Invalid data sent to API (missing fields, wrong format)
**Fix:** Check request data matches API requirements

**Authentication Errors:**
```
❌ [API_SERVICE] Status Code: 401
❌ [API_SERVICE] Error Message: Unauthorized
```
**Cause:** Invalid or expired token
**Fix:** Re-authenticate user

**Server Errors:**
```
❌ [API_SERVICE] Status Code: 500
❌ [API_SERVICE] Error Message: Internal Server Error
```
**Cause:** Backend server issue
**Fix:** Contact backend team

---

## 📊 Registration Stages

The registration process is divided into 5 stages:

### **STAGE 1: Authentication Check** 🔐
- Validates auth token exists
- **CLIENT ERROR** if token missing

### **STAGE 2: Request Preparation** 📝
- Builds multipart request
- Adds form fields and headers

### **STAGE 3: Image Processing** 🖼️
- Converts images to bytes
- Validates MIME types
- **CLIENT ERROR** if image processing fails

### **STAGE 4: Sending HTTP Request** 🌐
- Sends request to backend
- Waits for response

### **STAGE 5: Processing API Response** 📥
- Parses response
- **API ERROR** if backend returns error
- **CLIENT ERROR** if network fails

---

## 🎯 Quick Troubleshooting

### If you see "Error Source: CLIENT SIDE"
1. Check your Flutter app code
2. Verify file paths and permissions
3. Check network connectivity
4. Validate image formats
5. Ensure user is authenticated

### If you see "Error Source: BACKEND API"
1. Check the status code
2. Read the error message from API
3. Check backend server logs
4. Verify API endpoint is correct
5. Contact backend team if needed

---

## 📋 Response Format

All error responses now include:
```dart
{
  'success': false,
  'error': 'Error message',
  'error_source': 'client' | 'api',  // NEW: Identifies error source
  'status_code': 400  // Only for API errors
}
```

Success responses:
```dart
{
  'success': true,
  'vendor': {...},
  'payment': {...},
  'message': 'Success message'
}
```

---

## 🔧 Using Error Source in Your Code

```dart
final result = await ApiService.registerBusinessVendor(...);

if (!result['success']) {
  final errorSource = result['error_source'];
  
  if (errorSource == 'client') {
    // Handle client-side errors
    // Show user-friendly message about connectivity, files, etc.
    showSnackBar('Please check your internet connection and try again');
  } else if (errorSource == 'api') {
    // Handle API errors
    // Show specific error from backend
    final statusCode = result['status_code'];
    if (statusCode == 400) {
      showSnackBar('Invalid data: ${result['error']}');
    } else if (statusCode == 401) {
      // Redirect to login
      navigateToLogin();
    } else {
      showSnackBar('Server error: ${result['error']}');
    }
  }
}
```

---

## 📝 Log Format

All logs follow this pattern:

**Success:**
```
═══════════════════════════════════════════════════════════
🚀 [API_SERVICE] STARTING BUSINESS VENDOR REGISTRATION
═══════════════════════════════════════════════════════════

📍 [API_SERVICE] STAGE 1: Authentication Check
─────────────────────────────────────────────────────────
✅ [API_SERVICE] Auth token found

...

✅ [API_SERVICE] ========================================
✅ [API_SERVICE] SUCCESS: Business Vendor Registered
✅ [API_SERVICE] ========================================
```

**Client Error:**
```
💥 [API_SERVICE] ========================================
💥 [API_SERVICE] CLIENT ERROR: [Description]
💥 [API_SERVICE] ========================================
💥 [API_SERVICE] Error Source: CLIENT SIDE
💥 [API_SERVICE] Exception: [Details]
💥 [API_SERVICE] Stack Trace: [Stack trace]
💥 [API_SERVICE] ========================================
```

**API Error:**
```
❌ [API_SERVICE] ========================================
❌ [API_SERVICE] API ERROR - [Description]
❌ [API_SERVICE] ========================================
❌ [API_SERVICE] Error Source: BACKEND API
❌ [API_SERVICE] Status Code: [Code]
❌ [API_SERVICE] Error Message: [Message]
❌ [API_SERVICE] ========================================
```

---

## ✅ Benefits

1. **Clear Error Attribution**: Instantly know if error is client or server side
2. **Faster Debugging**: Logs show exact stage where error occurred
3. **Better User Experience**: Can show appropriate error messages
4. **Detailed Context**: Stack traces, request data, and response details
5. **Production Ready**: Comprehensive logging for troubleshooting live issues
