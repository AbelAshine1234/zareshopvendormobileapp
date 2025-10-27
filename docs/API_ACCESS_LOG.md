# 📡 Address Management API Access Documentation

## Overview
This document provides comprehensive logging and documentation of how the Flutter app accesses the Address Management API endpoints. It includes request/response examples, authentication flow, and error handling.

## 🔐 Authentication Flow

### JWT Token Retrieval
```dart
// In AddressBloc._getToken() method
Future<String?> _getToken() async {
  final authState = _authBloc.state;
  String? token;
  
  // 1. Try to get token from AuthBloc state
  if (authState is AuthLoginResponse) {
    token = authState.data['token'] as String?;
  }
  
  // 2. Fallback to storage if not in state
  if (token == null) {
    token = await ApiService.getToken();
  }
  
  return token;
}
```

### Token Usage in Headers
```dart
// All API calls include this header structure
headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
}
```

## 📋 API Endpoints Documentation

### 1. **GET /api/shipping-addresses** - List All Addresses

#### Request Structure
```dart
// Method: ApiService.getShippingAddresses()
static Future<Map<String, dynamic>> getShippingAddresses({
  required String token,
  int? page,
  int? limit,
  int? vendorId,
  String? city,
  String? region,
  String? subcity,
  String? woreda,
  String? kebele,
  bool? isPrimary,
  bool? isVerified,
}) async
```

#### HTTP Request
```http
GET /api/shipping-addresses?page=1&limit=50&vendor_id=1&city=Addis%20Ababa&is_primary=true
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

#### Response Example
```json
{
  "page": 1,
  "limit": 50,
  "total": 100,
  "addresses": [
    {
      "id": 1,
      "address_line1": "123 Main Street",
      "address_line2": "Apt 4B",
      "city": "Addis Ababa",
      "state": "Addis Ababa",
      "region": "Central",
      "subcity": "Bole",
      "woreda": "Woreda 03",
      "kebele": "Kebele 01",
      "postal_code": "1000",
      "country": "Ethiopia",
      "latitude": 9.0192,
      "longitude": 38.7525,
      "place_id": "ChIJ...",
      "formatted_address": "123 Main Street, Apt 4B, Bole, Addis Ababa, Ethiopia",
      "is_primary": true,
      "is_verified": true,
      "created_at": "2024-01-01T00:00:00.000Z",
      "vendor_id": 1,
      "vendor": {
        "id": 1,
        "name": "ABC Store",
        "user_id": 123
      }
    }
  ]
}
```

#### Console Logs
```
🔄 [API_SERVICE] Getting shipping addresses...
✅ [API_SERVICE] Shipping addresses retrieved successfully
```

---

### 2. **GET /api/vendors/{vendorId}/shipping-addresses** - Get Vendor Addresses

#### Request Structure
```dart
// Method: ApiService.getVendorShippingAddresses()
static Future<Map<String, dynamic>> getVendorShippingAddresses({
  required String token,
  required int vendorId,
}) async
```

#### HTTP Request
```http
GET /api/vendors/1/shipping-addresses
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

#### Response Example
```json
{
  "addresses": [
    {
      "id": 1,
      "address_line1": "123 Main Street",
      "address_line2": "Apt 4B",
      "city": "Addis Ababa",
      "state": "Addis Ababa",
      "region": "Central",
      "subcity": "Bole",
      "woreda": "Woreda 03",
      "kebele": "Kebele 01",
      "postal_code": "1000",
      "country": "Ethiopia",
      "latitude": 9.0192,
      "longitude": 38.7525,
      "place_id": "ChIJ...",
      "formatted_address": "123 Main Street, Apt 4B, Bole, Addis Ababa, Ethiopia",
      "is_primary": true,
      "is_verified": true,
      "created_at": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

#### Console Logs
```
🔄 [API_SERVICE] Getting vendor shipping addresses for vendor: 1...
✅ [API_SERVICE] Vendor shipping addresses retrieved successfully
```

---

### 3. **POST /api/vendors/{vendorId}/shipping-addresses** - Create Address

#### Request Structure
```dart
// Method: ApiService.createShippingAddress()
static Future<Map<String, dynamic>> createShippingAddress({
  required String token,
  required int vendorId,
  required Map<String, dynamic> addressData,
}) async
```

#### HTTP Request
```http
POST /api/vendors/1/shipping-addresses
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "address_line1": "123 Main Street",
  "address_line2": "Apt 4B",
  "city": "Addis Ababa",
  "state": "Addis Ababa",
  "region": "Central",
  "subcity": "Bole",
  "woreda": "Woreda 03",
  "kebele": "Kebele 01",
  "postal_code": "1000",
  "country": "Ethiopia",
  "is_primary": true
}
```

#### Response Example
```json
{
  "address": {
    "id": 1,
    "address_line1": "123 Main Street",
    "address_line2": "Apt 4B",
    "city": "Addis Ababa",
    "state": "Addis Ababa",
    "region": "Central",
    "subcity": "Bole",
    "woreda": "Woreda 03",
    "kebele": "Kebele 01",
    "postal_code": "1000",
    "country": "Ethiopia",
    "latitude": 9.0192,
    "longitude": 38.7525,
    "place_id": "ChIJ...",
    "formatted_address": "123 Main Street, Apt 4B, Bole, Addis Ababa, Ethiopia",
    "is_primary": true,
    "is_verified": true,
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

#### Console Logs
```
🔄 [API_SERVICE] Creating shipping address for vendor: 1...
🔄 [API_SERVICE] Address data: {address_line1: 123 Main Street, city: Addis Ababa, country: Ethiopia, is_primary: true}
✅ [API_SERVICE] Shipping address created successfully
```

---

### 4. **PATCH /api/shipping-addresses/{id}** - Update Address

#### Request Structure
```dart
// Method: ApiService.updateShippingAddress()
static Future<Map<String, dynamic>> updateShippingAddress({
  required String token,
  required int addressId,
  required Map<String, dynamic> updateData,
}) async
```

#### HTTP Request
```http
PATCH /api/shipping-addresses/1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "address_line1": "456 Updated Street",
  "city": "Addis Ababa",
  "is_primary": false
}
```

#### Response Example
```json
{
  "address": {
    "id": 1,
    "address_line1": "456 Updated Street",
    "address_line2": "Apt 4B",
    "city": "Addis Ababa",
    "state": "Addis Ababa",
    "region": "Central",
    "subcity": "Bole",
    "woreda": "Woreda 03",
    "kebele": "Kebele 01",
    "postal_code": "1000",
    "country": "Ethiopia",
    "latitude": 9.0192,
    "longitude": 38.7525,
    "place_id": "ChIJ...",
    "formatted_address": "456 Updated Street, Apt 4B, Bole, Addis Ababa, Ethiopia",
    "is_primary": false,
    "is_verified": true,
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

#### Console Logs
```
🔄 [API_SERVICE] Updating shipping address: 1...
🔄 [API_SERVICE] Update data: {address_line1: 456 Updated Street, city: Addis Ababa, is_primary: false}
✅ [API_SERVICE] Shipping address updated successfully
```

---

### 5. **DELETE /api/shipping-addresses/{id}** - Delete Address

#### Request Structure
```dart
// Method: ApiService.deleteShippingAddress()
static Future<Map<String, dynamic>> deleteShippingAddress({
  required String token,
  required int addressId,
}) async
```

#### HTTP Request
```http
DELETE /api/shipping-addresses/1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

#### Response Example
```json
{
  "message": "Address deleted successfully"
}
```

#### Console Logs
```
🔄 [API_SERVICE] Deleting shipping address: 1...
✅ [API_SERVICE] Shipping address deleted successfully
```

---

### 6. **POST /api/shipping-addresses/{id}/set-primary** - Set Primary Address

#### Request Structure
```dart
// Method: ApiService.setPrimaryShippingAddress()
static Future<Map<String, dynamic>> setPrimaryShippingAddress({
  required String token,
  required int addressId,
}) async
```

#### HTTP Request
```http
POST /api/shipping-addresses/1/set-primary
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

#### Response Example
```json
{
  "address": {
    "id": 1,
    "address_line1": "123 Main Street",
    "address_line2": "Apt 4B",
    "city": "Addis Ababa",
    "state": "Addis Ababa",
    "region": "Central",
    "subcity": "Bole",
    "woreda": "Woreda 03",
    "kebele": "Kebele 01",
    "postal_code": "1000",
    "country": "Ethiopia",
    "latitude": 9.0192,
    "longitude": 38.7525,
    "place_id": "ChIJ...",
    "formatted_address": "123 Main Street, Apt 4B, Bole, Addis Ababa, Ethiopia",
    "is_primary": true,
    "is_verified": true,
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

#### Console Logs
```
🔄 [API_SERVICE] Setting shipping address as primary: 1...
✅ [API_SERVICE] Shipping address set as primary successfully
```

## 🔄 BLoC Event Flow

### 1. **Load Addresses Flow**
```dart
// User triggers: LoadVendorAddresses(vendorId: 1)
// BLoC processes: _onLoadVendorAddresses()

// 1. Emit loading state
emit(AddressLoading());

// 2. Get JWT token
final token = await _getToken();
if (token == null) {
  emit(AddressError(message: 'No authentication token found'));
  return;
}

// 3. Call API
final result = await ApiService.getVendorShippingAddresses(
  token: token,
  vendorId: event.vendorId,
);

// 4. Handle response
if (result['success'] == true) {
  final addresses = (result['addresses'] as List)
      .map((json) => AddressModel.fromJson(json))
      .toList();
  
  emit(AddressesLoaded(
    addresses: addresses,
    page: 1,
    limit: addresses.length,
    total: addresses.length,
    vendorAddresses: addresses,
  ));
} else {
  emit(AddressError(message: result['error'] ?? 'Failed to load addresses'));
}
```

### 2. **Create Address Flow**
```dart
// User triggers: CreateAddress(...)
// BLoC processes: _onCreateAddress()

// 1. Emit creating state
emit(AddressCreating());

// 2. Get JWT token
final token = await _getToken();
if (token == null) {
  emit(AddressCreateError(message: 'No authentication token found'));
  return;
}

// 3. Prepare address data
final addressData = {
  'address_line1': event.addressLine1,
  'address_line2': event.addressLine2,
  'city': event.city,
  'state': event.state,
  'region': event.region,
  'subcity': event.subcity,
  'woreda': event.woreda,
  'kebele': event.kebele,
  'postal_code': event.postalCode,
  'country': event.country,
  'is_primary': event.isPrimary,
};

// 4. Call API
final result = await ApiService.createShippingAddress(
  token: token,
  vendorId: event.vendorId,
  addressData: addressData,
);

// 5. Handle response
if (result['success'] == true) {
  emit(AddressCreated(address: AddressModel.fromJson(result['address'])));
} else {
  emit(AddressCreateError(message: result['error'] ?? 'Failed to create address'));
}
```

## 🚨 Error Handling

### 1. **Network Errors**
```dart
// In ApiService methods
try {
  final response = await http.get(uri, headers: headers);
  // ... process response
} catch (e) {
  print('❌ [API_SERVICE] Error getting shipping addresses: $e');
  return {'success': false, 'error': 'Network error: ${e.toString()}'};
}
```

### 2. **HTTP Status Code Errors**
```dart
if (response.statusCode == 200) {
  print('✅ [API_SERVICE] Shipping addresses retrieved successfully');
  return data;
} else {
  print('❌ [API_SERVICE] Failed to get shipping addresses');
  print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
  print('❌ [API_SERVICE] Response Body: $responseBody');
  return {'success': false, 'error': data['error'] ?? 'Failed to get shipping addresses'};
}
```

### 3. **Authentication Errors**
```dart
// In BLoC methods
final token = await _getToken();
if (token == null) {
  emit(AddressError(message: 'No authentication token found'));
  return;
}
```

### 4. **Validation Errors**
```dart
// In AddressFormDialog
if (_formKey.currentState!.validate()) {
  // Proceed with save
} else {
  // Show validation errors
}
```

## 📊 Console Logging Examples

### Successful API Call
```
🔄 [API_SERVICE] Getting vendor shipping addresses for vendor: 1...
✅ [API_SERVICE] Vendor shipping addresses retrieved successfully
🔄 [ADDRESS_BLOC] Loading vendor addresses for vendor: 1
✅ [ADDRESS_BLOC] Vendor addresses loaded successfully
```

### Failed API Call
```
🔄 [API_SERVICE] Creating shipping address for vendor: 1...
❌ [API_SERVICE] Failed to create shipping address
❌ [API_SERVICE] Status Code: 400
❌ [API_SERVICE] Response Body: {"error": "address_line1 is required"}
🔄 [ADDRESS_BLOC] Creating address...
❌ [ADDRESS_BLOC] Failed to create address: address_line1 is required
```

### Network Error
```
🔄 [API_SERVICE] Getting shipping addresses...
❌ [API_SERVICE] Error getting shipping addresses: SocketException: Failed host lookup: 'api.example.com'
🔄 [ADDRESS_BLOC] Loading addresses...
❌ [ADDRESS_BLOC] Error loading addresses: Network error: SocketException: Failed host lookup: 'api.example.com'
```

## 🔧 Debugging Tips

### 1. **Enable Detailed Logging**
```dart
// Add this to your main.dart for more detailed HTTP logging
import 'package:http/http.dart' as http;

// Enable HTTP logging
http.Client().interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
  logPrint: (object) => print(object),
));
```

### 2. **Check Token Validity**
```dart
// Add this method to debug token issues
void _debugToken() async {
  final token = await _getToken();
  print('🔍 [DEBUG] Token: ${token?.substring(0, 20)}...');
  print('🔍 [DEBUG] Token length: ${token?.length}');
}
```

### 3. **Monitor API Response Times**
```dart
// Add timing to API calls
final stopwatch = Stopwatch()..start();
final result = await ApiService.getShippingAddresses(token: token);
stopwatch.stop();
print('⏱️ [API_SERVICE] Request took ${stopwatch.elapsedMilliseconds}ms');
```

## 📱 UI State Management

### 1. **Loading States**
```dart
BlocBuilder<AddressBloc, AddressState>(
  builder: (context, state) {
    if (state is AddressLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // ... other states
  },
)
```

### 2. **Error States**
```dart
BlocListener<AddressBloc, AddressState>(
  listener: (context, state) {
    if (state is AddressError) {
      GlobalSnackBar.showError(
        context: context,
        message: 'Failed to load addresses: ${state.message}',
      );
    }
  },
  child: // ... UI
)
```

### 3. **Success States**
```dart
BlocListener<AddressBloc, AddressState>(
  listener: (context, state) {
    if (state is AddressCreated) {
      GlobalSnackBar.showSuccess(
        context: context,
        message: 'Address created successfully!',
      );
    }
  },
  child: // ... UI
)
```

## 🎯 Best Practices

### 1. **Always Check Token**
```dart
final token = await _getToken();
if (token == null) {
  emit(AddressError(message: 'No authentication token found'));
  return;
}
```

### 2. **Handle All Response Cases**
```dart
if (result['success'] == true) {
  // Handle success
} else {
  // Handle API error
  emit(AddressError(message: result['error'] ?? 'Unknown error'));
}
```

### 3. **Provide User Feedback**
```dart
// Show loading
emit(AddressLoading());

// Show success
GlobalSnackBar.showSuccess(context: context, message: 'Success!');

// Show error
GlobalSnackBar.showError(context: context, message: 'Error occurred');
```

### 4. **Validate Input Data**
```dart
// In form validation
if (value == null || value.isEmpty) {
  return 'Please enter address line 1';
}
```

This documentation provides complete visibility into how the address management system accesses the API, including all request/response examples, error handling, and debugging information.
