    # 🔄 API Access Flow - Address Management

## How the App Accesses the Address API

### 1. **User Action → BLoC Event**
```dart
// User taps "Add Address" button
context.read<AddressBloc>().add(CreateAddress(
  vendorId: 1,
  addressLine1: "123 Main Street",
  city: "Addis Ababa",
  country: "Ethiopia",
  isPrimary: true,
));
```

### 2. **BLoC Processes Event**
```dart
// In AddressBloc._onCreateAddress()
Future<void> _onCreateAddress(CreateAddress event, Emitter<AddressState> emit) async {
  // Step 1: Show loading
  emit(AddressCreating());
  
  // Step 2: Get JWT token
  final token = await _getToken();
  if (token == null) {
    emit(AddressCreateError(message: 'No authentication token found'));
    return;
  }
  
  // Step 3: Prepare data
  final addressData = {
    'address_line1': event.addressLine1,
    'city': event.city,
    'country': event.country,
    'is_primary': event.isPrimary,
  };
  
  // Step 4: Call API
  final result = await ApiService.createShippingAddress(
    token: token,
    vendorId: event.vendorId,
    addressData: addressData,
  );
  
  // Step 5: Handle response
  if (result['success'] == true) {
    emit(AddressCreated(address: AddressModel.fromJson(result['address'])));
  } else {
    emit(AddressCreateError(message: result['error'] ?? 'Failed to create address'));
  }
}
```

### 3. **API Service Makes HTTP Request**
```dart
// In ApiService.createShippingAddress()
static Future<Map<String, dynamic>> createShippingAddress({
  required String token,
  required int vendorId,
  required Map<String, dynamic> addressData,
}) async {
  try {
    print('🔄 [API_SERVICE] Creating shipping address for vendor: $vendorId...');
    
    // HTTP POST request
    final response = await http.post(
      Uri.parse('$baseUrl/vendors/$vendorId/shipping-addresses'),
      headers: {
        'Authorization': 'Bearer $token',  // ← JWT token here
        'Content-Type': 'application/json',
      },
      body: json.encode(addressData),  // ← JSON payload
    );
    
    // Parse response
    final responseBody = response.body;
    final data = json.decode(responseBody);
    
    // Handle response
    if (response.statusCode == 201) {
      print('✅ [API_SERVICE] Shipping address created successfully');
      return data;
    } else {
      print('❌ [API_SERVICE] Failed to create shipping address');
      return {'success': false, 'error': data['error'] ?? 'Failed to create shipping address'};
    }
  } catch (e) {
    print('❌ [API_SERVICE] Error creating shipping address: $e');
    return {'success': false, 'error': 'Network error: ${e.toString()}'};
  }
}
```

### 4. **Actual HTTP Request Sent**
```http
POST /api/vendors/1/shipping-addresses HTTP/1.1
Host: your-api-domain.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
Content-Type: application/json
Content-Length: 156

{
  "address_line1": "123 Main Street",
  "city": "Addis Ababa",
  "country": "Ethiopia",
  "is_primary": true
}
```

### 5. **Backend Response**
```http
HTTP/1.1 201 Created
Content-Type: application/json
Content-Length: 512

{
  "address": {
    "id": 1,
    "address_line1": "123 Main Street",
    "city": "Addis Ababa",
    "country": "Ethiopia",
    "latitude": 9.0192,
    "longitude": 38.7525,
    "place_id": "ChIJ...",
    "formatted_address": "123 Main Street, Addis Ababa, Ethiopia",
    "is_primary": true,
    "is_verified": true,
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

### 6. **UI Updates**
```dart
// BLoC emits success state
emit(AddressCreated(address: AddressModel.fromJson(result['address'])));

// UI listens and shows success message
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

## 🔍 Complete API Access Log

### **GET My Addresses Flow**
```
1. User Action: LoadAddresses()
2. BLoC: emit(AddressLoading())
3. BLoC: Get JWT token from AuthBloc or storage
4. API: GET /api/vendor/shipping-addresses
5. Headers: Authorization: Bearer <token>
6. Response: 200 OK with addresses array
7. BLoC: emit(AddressesLoaded(addresses: [...])
8. UI: Display address cards
```

### **POST Create My Address Flow**
```
1. User Action: CreateAddress(...)
2. BLoC: emit(AddressCreating())
3. BLoC: Get JWT token
4. API: POST /api/vendor/shipping-addresses
5. Headers: Authorization: Bearer <token>
6. Body: JSON with address data
7. Response: 201 Created with new address
8. BLoC: emit(AddressCreated(address: ...))
9. UI: Show success message + refresh list
```

### **PUT Update My Address Flow**
```
1. User Action: UpdateAddress(addressId: 1, ...)
2. BLoC: emit(AddressUpdating())
3. BLoC: Get JWT token
4. API: PUT /api/vendor/shipping-addresses/1
5. Headers: Authorization: Bearer <token>
6. Body: JSON with update data
7. Response: 200 OK with updated address
8. BLoC: emit(AddressUpdated(address: ...))
9. UI: Show success message + refresh list
```

### **DELETE My Address Flow**
```
1. User Action: DeleteAddress(addressId: 1)
2. BLoC: emit(AddressDeleting())
3. BLoC: Get JWT token
4. API: DELETE /api/vendor/shipping-addresses/1
5. Headers: Authorization: Bearer <token>
6. Response: 200 OK with success message
7. BLoC: emit(AddressDeleted(addressId: 1))
8. UI: Show success message + refresh list
```

### **POST Set Primary My Address Flow**
```
1. User Action: SetPrimaryAddress(addressId: 1)
2. BLoC: emit(AddressSettingPrimary())
3. BLoC: Get JWT token
4. API: POST /api/vendor/shipping-addresses/1/set-primary
5. Headers: Authorization: Bearer <token>
6. Response: 200 OK with updated address
7. BLoC: emit(AddressSetAsPrimary(address: ...))
8. UI: Show success message + refresh list
```

## 🚨 Error Scenarios

### **Authentication Error**
```
1. User Action: Any address operation
2. BLoC: Get JWT token → null
3. BLoC: emit(AddressError(message: 'No authentication token found'))
4. UI: Show error message
```

### **Network Error**
```
1. User Action: CreateAddress(...)
2. BLoC: emit(AddressCreating())
3. API: HTTP request fails (no internet)
4. API: catch (e) → return {'success': false, 'error': 'Network error'}
5. BLoC: emit(AddressCreateError(message: 'Network error'))
6. UI: Show error message
```

### **API Error**
```
1. User Action: CreateAddress(addressLine1: '')
2. BLoC: emit(AddressCreating())
3. API: POST request with empty address_line1
4. Backend: Returns 400 Bad Request
5. Response: {'error': 'address_line1 is required'}
6. BLoC: emit(AddressCreateError(message: 'address_line1 is required'))
7. UI: Show error message
```

## 📊 Console Output Examples

### **Successful Create Address**
```
🔄 [ADDRESS_BLOC] Creating address...
🔄 [API_SERVICE] Creating shipping address for vendor: 1...
🔄 [API_SERVICE] Address data: {address_line1: 123 Main Street, city: Addis Ababa, country: Ethiopia, is_primary: true}
✅ [API_SERVICE] Shipping address created successfully
✅ [ADDRESS_BLOC] Address created successfully
```

### **Failed Create Address**
```
🔄 [ADDRESS_BLOC] Creating address...
🔄 [API_SERVICE] Creating shipping address for vendor: 1...
🔄 [API_SERVICE] Address data: {address_line1: , city: Addis Ababa, country: Ethiopia, is_primary: true}
❌ [API_SERVICE] Failed to create shipping address
❌ [API_SERVICE] Status Code: 400
❌ [API_SERVICE] Response Body: {"error": "address_line1 is required"}
❌ [ADDRESS_BLOC] Failed to create address: address_line1 is required
```

### **Network Error**
```
🔄 [ADDRESS_BLOC] Loading addresses...
🔄 [API_SERVICE] Getting vendor shipping addresses for vendor: 1...
❌ [API_SERVICE] Error getting vendor shipping addresses: SocketException: Failed host lookup: 'api.example.com'
❌ [ADDRESS_BLOC] Error loading vendor addresses: Network error: SocketException: Failed host lookup: 'api.example.com'
```

## 🔧 Debugging Commands

### **Check Token**
```dart
// Add this to debug token issues
void debugToken() async {
  final token = await _getToken();
  print('🔍 Token: ${token?.substring(0, 20)}...');
  print('🔍 Token length: ${token?.length}');
}
```

### **Monitor API Calls**
```dart
// Add this to ApiService methods
final stopwatch = Stopwatch()..start();
final response = await http.post(uri, headers: headers, body: body);
stopwatch.stop();
print('⏱️ API call took ${stopwatch.elapsedMilliseconds}ms');
```

### **Log Request/Response**
```dart
// Add this to see full request/response
print('📤 Request: ${request.toString()}');
print('📥 Response: ${response.body}');
```

This shows exactly how the Flutter app accesses the Address Management API with complete flow documentation and debugging information.
