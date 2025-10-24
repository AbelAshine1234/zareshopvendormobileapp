import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'dart:io' as io if (dart.library.io) 'dart:io';
// Removed dart:html import as it's not used and causes mobile compilation issues
import 'user_service.dart';
import 'storage_service.dart';

class ApiService {
  // Backend API URL
  // Note: For Android Emulator, use 10.0.2.2 instead of localhost
  // For iOS Simulator, localhost works fine
  // For real device on same network, use your computer's IP address
  static const String baseUrl = 'http://localhost:4000/api';
  
  // Auth endpoints
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String registerVendorOwnerEndpoint = '$baseUrl/auth/register-vendor-owner';
  static const String verifyOtpEndpoint = '$baseUrl/auth/verify-otp';
  static const String resendOtpEndpoint = '$baseUrl/auth/resend-otp';
  static const String forgotPasswordEndpoint = '$baseUrl/auth/forgot-password';
  static const String verifyResetOtpEndpoint = '$baseUrl/auth/verify-reset-otp';
  static const String resetPasswordEndpoint = '$baseUrl/auth/reset-password';
  static const String meEndpoint = '$baseUrl/auth/me';
  
  // Vendor endpoints
  static const String registerBusinessVendorEndpoint = '$baseUrl/vendors/register-business';
  static const String vendorCompleteInfoEndpoint = '$baseUrl/vendors/my-complete-info';
  static const String vendorUpdateEndpoint = '$baseUrl/vendors/update';
  
  // Contact endpoints
  static const String vendorContactsEndpoint = '$baseUrl/vendors/contacts';
  static const String vendorContactsByTypeEndpoint = '$baseUrl/vendors/contacts/type';
  static const String vendorContactsBulkEndpoint = '$baseUrl/vendors/contacts/bulk';
  
  // Category endpoints
  static const String categoriesEndpoint = '$baseUrl/category';
  
  // Subscription endpoints
  static const String subscriptionsEndpoint = '$baseUrl/subscription/plans';
  
  // Payment endpoints
  static const String createPaymentEndpoint = '$baseUrl/payments';
  static const String createMobilePaymentEndpoint = '$baseUrl/payments/mobile';
  static const String getPaymentByIdEndpoint = '$baseUrl/payments';
  static const String getMyPaymentsEndpoint = '$baseUrl/payments/my';
  static const String updatePaymentStatusEndpoint = '$baseUrl/payments';
  static const String processIntegratedPaymentEndpoint = '$baseUrl/payments/process-integrated';
  static const String uploadPaymentProofEndpoint = '$baseUrl/payments/upload-proof';
  static const String uploadPaymentProofFileEndpoint = '$baseUrl/payments/upload-proof-file';
  static const String proceedToNextStepEndpoint = '$baseUrl/payments/proceed-to-next-step';
  static const String generateQrCodeEndpoint = '$baseUrl/payments/generate-qr';
  static const String adminGetAllPaymentsEndpoint = '$baseUrl/admin/payments';
  
  static const String adminGetPendingPaymentsEndpoint = '$baseUrl/admin/payments/pending';
  static const String adminVerifyManualPaymentEndpoint = '$baseUrl/admin/payments/verify-manual';
  static const String adminGetPaymentStatsEndpoint = '$baseUrl/admin/payments/statistics';
  static const String adminGetVendorApplicationsEndpoint = '$baseUrl/admin/vendor-applications';
  static const String adminReviewVendorApplicationEndpoint = '$baseUrl/admin/vendor-applications';
  
  // Wallet endpoints
  static const String walletEndpoint = '$baseUrl/wallet';
  static const String vendorWalletEndpoint = '$baseUrl/vendor-wallet';

  // Convert image path to bytes
  static Future<Uint8List> _convertImageToBytes(String imagePath) async {
    try {
      if (kIsWeb) {
        if (imagePath.startsWith('blob:')) {
          // Handle blob URLs from file picker - fetch the blob data
          try {
            final response = await http.get(Uri.parse(imagePath));
            if (response.statusCode == 200) {
              return response.bodyBytes;
            }
            throw Exception('Failed to fetch blob: ${response.statusCode}');
          } catch (e) {
            rethrow;
          }
        } 
        else if (imagePath.startsWith('data:image')) {
          // Handle data URLs
          final bytes = base64Decode(imagePath.split(',').last);
          return Uint8List.fromList(bytes);
        }
        else if (imagePath.startsWith('http')) {
          // Handle direct URLs
          final response = await http.get(Uri.parse(imagePath));
          if (response.statusCode == 200) {
            return response.bodyBytes;
          }
          throw Exception('Failed to fetch image: ${response.statusCode}');
        }
        throw Exception('Unsupported image source: $imagePath');
      } else {
        // For mobile/desktop, read file directly
        final file = io.File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          return bytes;
        }
        throw Exception('Image file not found: $imagePath');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get MIME type from bytes with better web support
  static String _getMimeTypeFromBytes(Uint8List bytes) {
    try {
      if (bytes.isEmpty) {
        throw Exception('Empty byte array provided');
      }

      // Check for common image signatures
      if (bytes.length >= 3) {
        // Check for JPEG
        if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
          return 'image/jpeg';
        }
        
        // Check for PNG
        if (bytes.length >= 8 &&
            bytes[0] == 0x89 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x4E &&
            bytes[3] == 0x47 &&
            bytes[4] == 0x0D &&
            bytes[5] == 0x0A &&
            bytes[6] == 0x1A &&
            bytes[7] == 0x0A) {
          return 'image/png';
        }
        
        // Check for WebP
        if (bytes.length >= 12 &&
            bytes[0] == 0x52 && // 'R'
            bytes[1] == 0x49 && // 'I'
            bytes[2] == 0x46 && // 'F'
            bytes[3] == 0x46 && // 'F'
            bytes[8] == 0x57 && // 'W'
            bytes[9] == 0x45 && // 'E'
            bytes[10] == 0x42 && // 'B'
            bytes[11] == 0x50) { // 'P'
          return 'image/webp';
        }
      }
      
      // Try using the mime package as a fallback
      try {
        final mimeType = lookupMimeType('', headerBytes: bytes);
        if (mimeType != null) {
          return mimeType;
        }
      } catch (e) {
        // Error using mime package
      }

      // Default fallback
      return 'application/octet-stream';
    } catch (e) {
      return 'application/octet-stream';
    }
  }

  // Token management
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token and user data
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        if (data['user'] != null) {
          await saveUserData(data['user']);
          // Save phone number globally for OTP purposes
          final user = data['user'] as Map<String, dynamic>;
          final phoneNumber = user['phone_number'] ?? user['name'];
          if (phoneNumber != null) {
            await UserService.instance.setPhoneNumber(phoneNumber);
            await UserService.instance.setUserData(user);
          }
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }
 

  // Register Vendor Owner (Business Vendor)
  static Future<Map<String, dynamic>> registerVendorOwner({
    required String name,
    required String phoneNumber,
    required String password,
    String? email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(registerVendorOwnerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'phone_number': phoneNumber,
          'password': password,
          if (email != null && email.isNotEmpty) 'email': email,
          'type': 'vendor_owner',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Save token if returned for new users
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        // Check if user already has a vendor account
        if (data['has_vendor'] == false) {
          // User exists but doesn't have vendor account - allow to proceed
          bool isOtpVerified = data['is_otp_verified'] ?? false;
          
          // Save token if present (for already verified users)
          if (data['token'] != null) {
            await saveToken(data['token']);
          }
          
          return {
            'success': true, 
            'data': data,
            'is_otp_verified': isOtpVerified,
          };
        } else if (data['has_vendor'] == true) {
          // User already has a vendor account - block registration
          return {'success': false, 'error': 'User already exists. Please try to login.'};
        } else {
          // Other registration errors
          return {'success': false, 'error': data['error'] ?? 'Registration failed'};
        }
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(verifyOtpEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'code': code,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token and user data if present (implicit login)
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        if (data['user'] != null) {
          await saveUserData(data['user']);
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'OTP verification failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Resend OTP
  static Future<Map<String, dynamic>> resendOtp({
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(resendOtpEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'channel': 'sms',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to resend OTP'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Forgot Password - Send OTP
  static Future<Map<String, dynamic>> forgotPassword({
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(forgotPasswordEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to send OTP'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Verify Reset OTP
  static Future<Map<String, dynamic>> verifyResetOtp({
required String phoneNumber,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(verifyResetOtpEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'code': code,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        final errorMessage = data['error'] ?? data['message'] ?? 'OTP verification failed';
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Reset Password
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(resetPasswordEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Password reset failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get current user
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }

      final response = await http.get(
        Uri.parse(meEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await saveUserData(data);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get user'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Logout - Clear ALL user data but preserve theme and language preferences
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save theme and language preferences before clearing
      final savedTheme = prefs.getInt('selected_theme');
      final savedLanguage = prefs.getString('selected_language');
      
      // Clear ALL SharedPreferences data
      await prefs.clear();
      
      // Restore theme and language preferences
      if (savedTheme != null) {
        await prefs.setInt('selected_theme', savedTheme);
      }
      if (savedLanguage != null) {
        await prefs.setString('selected_language', savedLanguage);
      }
      
      // Clear global user data
      await UserService.instance.clearUserData();
      
      // Clear storage service data
      final storageService = StorageService();
      await storageService.clearAll();
      
      print('🚪 LOGOUT: All user data cleared successfully');
    } catch (e) {
      print('❌ LOGOUT ERROR: ${e.toString()}');
      // Even if there's an error, try to clear critical data
      await removeToken();
      await UserService.instance.clearUserData();
    }
  }

  // Fetch Categories
  static Future<Map<String, dynamic>> fetchCategories() async {
    try {
      
      final response = await http.get(
        Uri.parse(categoriesEndpoint),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'categories': data};
      } else {
        return {'success': false, 'error': 'Failed to fetch categories'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Fetch Subscriptions (Public - no auth required)
  static Future<Map<String, dynamic>> fetchSubscriptions() async {
    try {
      final uri = Uri.parse(subscriptionsEndpoint);
      final headers = {'Content-Type': 'application/json'};
      
      final response = await http.get(uri, headers: headers);

      if (response.body.isEmpty) {
        return {'success': false, 'error': 'Empty response from server'};
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (jsonError) {
        return {'success': false, 'error': 'Invalid JSON response: $jsonError'};
      }

      if (response.statusCode == 200) {
        // Check if response has plans array or is direct array
        dynamic plans;
        if (data is List) {
          plans = data;
        } else if (data is Map && data.containsKey('plans')) {
          plans = data['plans'] as List<dynamic>;
        } else if (data is Map && data.containsKey('subscriptions')) {
          plans = data['subscriptions'] as List<dynamic>;
        } else {
          plans = data;
        }
        
        if (plans is! List) {
          plans = [plans];
        }
        
        return {'success': true, 'subscriptions': plans};
      } else {
        final error = (data is Map && data.containsKey('error')) 
            ? data['error'] 
            : 'Failed to fetch subscriptions (Status: ${response.statusCode})';
        return {'success': false, 'error': error};
      }
    } catch (e, stackTrace) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }


  // Register Business Vendor (Unified - handles payment + vendor creation)
  static Future<Map<String, dynamic>> registerBusinessVendor({
    required String name,
    required String description,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? region,
    String? subcity,
    String? woreda,
    String? kebele,
    String? postalCode,
    String? country,
    required List<int> categoryIds,
    required String paymentMethodType, // 'bank' or 'wallet'
    required String accountHolderName,
    required String accountNumber,
    required String accountName, // bank name or wallet provider
    required String coverImagePath,
    required String businessLicenseImagePath,
    required int subscriptionId,
    double? paymentAmount,
    String? paymentMethod,
    String? paymentProvider,
    String? currency,
  }) async {
    
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Authentication required', 'error_source': 'client'};
      }


      final uri = Uri.parse(registerBusinessVendorEndpoint);

      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });


      // ===== REGISTRATION PAYMENT FIELDS =====
      request.fields['payment_amount'] = (paymentAmount ?? 150.0).toString();
      request.fields['payment_method'] = paymentMethod ?? 'manual'; // "manual" or "integrated"
      request.fields['payment_provider'] = paymentProvider ?? 'bank_transfer';
      request.fields['currency'] = currency ?? 'ETB';

      // ===== VENDOR FIELDS =====
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['full_name'] = fullName;
      request.fields['email'] = email;
      request.fields['phone_number'] = phoneNumber;
      request.fields['address_line1'] = addressLine1;
      
      if (addressLine2 != null && addressLine2.isNotEmpty) {
        request.fields['address_line2'] = addressLine2;
      }
      if (city != null && city.isNotEmpty) {
        request.fields['city'] = city;
      }
      if (state != null && state.isNotEmpty) {
        request.fields['state'] = state;
      }
      if (postalCode != null && postalCode.isNotEmpty) {
        request.fields['postal_code'] = postalCode;
      }
      if (country != null && country.isNotEmpty) {
        request.fields['country'] = country;
      }
      if (region != null && region.isNotEmpty) {
        request.fields['region'] = region;
      }
      if (subcity != null && subcity.isNotEmpty) {
        request.fields['subcity'] = subcity;
      }
      if (woreda != null && woreda.isNotEmpty) {
        request.fields['woreda'] = woreda;
      }
      if (kebele != null && kebele.isNotEmpty) {
        request.fields['kebele'] = kebele;
      }
      
      // ===== CATEGORY FIELDS =====
      request.fields['category_ids'] = jsonEncode(categoryIds);
      
      // ===== VENDOR PAYMENT METHOD (separate field) =====
      final vendorPaymentMethodObj = {
        'name': accountName, // Bank name or wallet provider
        'account_number': accountNumber,
        'account_holder': accountHolderName,
        'type': paymentMethodType, // 'bank' or 'wallet'
        'details': {},
      };
      request.fields['vendor_payment_method'] = jsonEncode(vendorPaymentMethodObj);
      
      // ===== ADDITIONAL FIELDS =====
      // keepImages field removed from backend - no longer needed


      // ===== FILES =====
      if (kIsWeb) {
        
        try {
          // Convert blob URLs to bytes and add as files
          final coverImageBytes = await _convertImageToBytes(coverImagePath);
          final coverMimeType = _getMimeTypeFromBytes(coverImageBytes);
          
          if (!['image/jpeg', 'image/png', 'image/jpg'].contains(coverMimeType)) {
            throw Exception('Unsupported cover image format: $coverMimeType. Please upload a JPG or PNG image.');
          }
          
          request.files.add(http.MultipartFile.fromBytes(
            'cover_image',
            coverImageBytes,
            filename: 'cover_image.${coverMimeType.split('/').last}',
            contentType: MediaType.parse(coverMimeType),
          ));
          
          final licenseImageBytes = await _convertImageToBytes(businessLicenseImagePath);
          final licenseMimeType = _getMimeTypeFromBytes(licenseImageBytes);
          
          if (!['image/jpeg', 'image/png', 'image/jpg', 'application/pdf'].contains(licenseMimeType)) {
            throw Exception('Unsupported license image format: $licenseMimeType. Please upload a JPG, PNG, or PDF file.');
          }
          
          request.files.add(http.MultipartFile.fromBytes(
            'business_license_image',
            licenseImageBytes,
            filename: 'business_license.${licenseMimeType.split('/').last}',
            contentType: MediaType.parse(licenseMimeType),
          ));
          
        } catch (e, stackTrace) {
          return {'success': false, 'error': 'Failed to process images: $e', 'error_source': 'client'};
        }
      } else {
        // Mobile/Desktop platform: Use file path
        
        try {
          // Check cover image
          final coverFile = io.File(coverImagePath);
          if (!await coverFile.exists()) {
            throw Exception('Cover image file not found');
          }
          
          // Check license image
          final licenseFile = io.File(businessLicenseImagePath);
          if (!await licenseFile.exists()) {
            throw Exception('License image file not found');
          }
          
          // Get MIME types
          final coverBytes = await coverFile.readAsBytes();
          final coverMimeType = _getMimeTypeFromBytes(coverBytes);
          
          if (!['image/jpeg', 'image/png', 'image/jpg'].contains(coverMimeType)) {
            throw Exception('Unsupported cover image format: $coverMimeType. Please upload a JPG or PNG image.');
          }
          
          final licenseBytes = await licenseFile.readAsBytes();
          final licenseMimeType = _getMimeTypeFromBytes(licenseBytes);
          
          if (!['image/jpeg', 'image/png', 'image/jpg', 'application/pdf'].contains(licenseMimeType)) {
            throw Exception('Unsupported license image format: $licenseMimeType. Please upload a JPG, PNG, or PDF file.');
          }
          
          // Add files to request with proper MIME types
          request.files.add(await http.MultipartFile.fromPath(
            'cover_image',
            coverImagePath,
            contentType: MediaType.parse(coverMimeType),
          ));
          
          request.files.add(await http.MultipartFile.fromPath(
            'business_license_image',
            businessLicenseImagePath,
            contentType: MediaType.parse(licenseMimeType),
          ));
          
          
        } catch (e, stackTrace) {
          return {'success': false, 'error': 'Failed to process files: $e', 'error_source': 'client'};
        }
      }

      
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      

      if (response.body.isEmpty) {
        return {'success': false, 'error': 'Empty response from server', 'error_source': 'api'};
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (jsonError, stackTrace) {
        return {'success': false, 'error': 'Invalid JSON response: $jsonError', 'error_source': 'api'};
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'vendor': data['vendor'] ?? data,
          'payment': data['payment'],
          'message': data['message'] ?? 'Business vendor registered successfully'
        };
      } else {
        
        final error = (data is Map && data.containsKey('error'))
            ? data['error']
            : (data is Map && data.containsKey('message'))
                ? data['message']
                : 'Failed to register business vendor (Status: ${response.statusCode})';
        
        
        // Log detailed error information if available
        if (data is Map) {
          if (data.containsKey('details')) {
          }
          if (data.containsKey('validation_errors')) {
          }
          if (data.containsKey('field_errors')) {
          }
        }
        
        return {'success': false, 'error': error, 'error_source': 'api', 'status_code': response.statusCode};
      }
    } catch (e, stackTrace) {
      return {'success': false, 'error': 'Network error: ${e.toString()}', 'error_source': 'client'};
    }
  }

  // Get vendor complete info
  Future<Map<String, dynamic>> getVendorCompleteInfo() async {
    try {
      
      // Get JWT token from SharedPreferences
      final token = await getToken();
      
      if (token == null) {
        return {'success': false, 'error': 'No authentication token found'};
      }
      
      
      // Make the API request
      final response = await http.get(
        Uri.parse(vendorCompleteInfoEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        
        final error = (data is Map && data.containsKey('error'))
            ? data['error']
            : (data is Map && data.containsKey('message'))
                ? data['message']
                : 'Failed to get vendor info (Status: ${response.statusCode})';
        
        return {'success': false, 'error': error};
      }
    } catch (e, stackTrace) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Update vendor information
  Future<Map<String, dynamic>> updateVendorInfo({
    required String token,
    String? name,
    String? description,
    String? coverImagePath,
    String? faydaImagePath,
    String? businessLicenseImagePath,
  }) async {
    try {
      
      // Create multipart request
      final request = http.MultipartRequest('PUT', Uri.parse(vendorUpdateEndpoint));
      
      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      
      // Add text fields if provided
      if (name != null && name.isNotEmpty) {
        request.fields['name'] = name;
      }
      
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }
      
      // Add image files if provided
      if (coverImagePath != null && coverImagePath.isNotEmpty) {
        
        if (kIsWeb) {
          // For web, convert image to bytes first
          try {
            final imageBytes = await _convertImageToBytes(coverImagePath);
            final coverImageFile = http.MultipartFile.fromBytes(
              'cover_image',
              imageBytes,
              filename: 'cover_image.jpg',
              contentType: MediaType('image', 'jpeg'),
            );
            request.files.add(coverImageFile);
          } catch (e) {
            return {'success': false, 'error': 'Failed to process cover image: $e'};
          }
        } else {
          // For mobile, use file path directly
          try {
            final coverImageFile = await http.MultipartFile.fromPath('cover_image', coverImagePath);
            request.files.add(coverImageFile);
          } catch (e) {
            return {'success': false, 'error': 'Failed to process cover image: $e'};
          }
        }
      }
      
      if (faydaImagePath != null && faydaImagePath.isNotEmpty) {
        
        if (kIsWeb) {
          final imageBytes = await _convertImageToBytes(faydaImagePath);
          final faydaImageFile = http.MultipartFile.fromBytes(
            'fayda_image',
            imageBytes,
            filename: 'fayda_image.jpg',
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(faydaImageFile);
        } else {
          final faydaImageFile = await http.MultipartFile.fromPath('fayda_image', faydaImagePath);
          request.files.add(faydaImageFile);
        }
      }
      
      if (businessLicenseImagePath != null && businessLicenseImagePath.isNotEmpty) {
        
        if (kIsWeb) {
          final imageBytes = await _convertImageToBytes(businessLicenseImagePath);
          final businessLicenseImageFile = http.MultipartFile.fromBytes(
            'business_license_image',
            imageBytes,
            filename: 'business_license_image.jpg',
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(businessLicenseImageFile);
        } else {
          final businessLicenseImageFile = await http.MultipartFile.fromPath('business_license_image', businessLicenseImagePath);
          request.files.add(businessLicenseImageFile);
        }
      }
      
      // Check if at least one field is provided
      if (request.fields.isEmpty && request.files.isEmpty) {
        return {'success': false, 'error': 'No valid fields provided for update'};
      }
      
      
      final response = await request.send();
      
      
      final responseBody = await response.stream.bytesToString();
      
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        
        final error = (data is Map && data.containsKey('error'))
            ? data['error']
            : (data is Map && data.containsKey('message'))
                ? data['message']
                : 'Failed to update vendor (Status: ${response.statusCode})';
        
        return {'success': false, 'error': error};
      }
    } catch (e, stackTrace) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // ========================================
  // VENDOR CONTACTS API METHODS
  // ========================================

  // Get all vendor contacts
  static Future<Map<String, dynamic>> getVendorContacts({required String token}) async {
    try {
      
      final response = await http.get(
        Uri.parse('$baseUrl/vendors/contacts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      final responseBody = response.body;
      
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get vendor contacts'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get vendor contacts by type
  static Future<Map<String, dynamic>> getVendorContactsByType({
    required String token,
    required String type,
  }) async {
    try {
      
      final response = await http.get(
        Uri.parse('$baseUrl/vendors/contacts/type/$type'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get vendor contacts by type'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Create a single vendor contact
  static Future<Map<String, dynamic>> createVendorContact({
    required String token,
    required Map<String, dynamic> contactData,
  }) async {
    try {
      
      final response = await http.post(
        Uri.parse('$baseUrl/vendors/contacts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(contactData),
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 201) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to create vendor contact'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Create multiple vendor contacts (bulk)
  static Future<Map<String, dynamic>> createVendorContactsBulk({
    required String token,
    required List<Map<String, dynamic>> contacts,
  }) async {
    try {
      
      final response = await http.post(
        Uri.parse('$baseUrl/vendors/contacts/bulk'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'contacts': contacts}),
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 201) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to create vendor contacts in bulk'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Update a vendor contact
  static Future<Map<String, dynamic>> updateVendorContact({
    required String token,
    required int contactId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      
      final response = await http.put(
        Uri.parse('$baseUrl/vendors/contacts/$contactId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to update vendor contact'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Set vendor contact as primary
  static Future<Map<String, dynamic>> setVendorContactAsPrimary({
    required String token,
    required int contactId,
  }) async {
    try {
      
      final response = await http.patch(
        Uri.parse('$baseUrl/vendors/contacts/$contactId/set-primary'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'contact_id': contactId}),
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to set vendor contact as primary'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Delete a vendor contact
  static Future<Map<String, dynamic>> deleteVendorContact({
    required String token,
    required int contactId,
  }) async {
    try {
      
      final response = await http.delete(
        Uri.parse('$baseUrl/vendors/contacts/$contactId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to delete vendor contact'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // ========================================
  // VENDOR SHIPPING ADDRESSES API METHODS
  // ========================================

  // Get my shipping addresses (Vendor)
  static Future<Map<String, dynamic>> getMyShippingAddresses({
    required String token,
  }) async {
    try {
      
      final response = await http.get(
        Uri.parse('$baseUrl/vendor/shipping-addresses'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return {'success': true, 'addresses': data['addresses']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get my shipping addresses'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Create my shipping address (Vendor)
  static Future<Map<String, dynamic>> createMyShippingAddress({
    required String token,
    required Map<String, dynamic> addressData,
  }) async {
    try {
      
      final response = await http.post(
        Uri.parse('$baseUrl/vendor/shipping-addresses'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(addressData),
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 201) {
        return {'success': true, 'address': data['address']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to create my shipping address'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Update my shipping address (Vendor)
  static Future<Map<String, dynamic>> updateMyShippingAddress({
    required String token,
    required int addressId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      
      final response = await http.put(
        Uri.parse('$baseUrl/vendor/shipping-addresses/$addressId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return {'success': true, 'address': data['address']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to update my shipping address'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Delete my shipping address (Vendor)
  static Future<Map<String, dynamic>> deleteMyShippingAddress({
    required String token,
    required int addressId,
  }) async {
    try {
      
      final response = await http.delete(
        Uri.parse('$baseUrl/vendor/shipping-addresses/$addressId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'], 'id': data['id']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to delete my shipping address'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Set primary shipping address (Vendor)
  static Future<Map<String, dynamic>> setMyPrimaryShippingAddress({
    required String token,
    required int addressId,
  }) async {
    try {
      
      final response = await http.post(
        Uri.parse('$baseUrl/vendor/shipping-addresses/$addressId/set-primary'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return {'success': true, 'address': data['address']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to set my shipping address as primary'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // ========================================
  // VENDOR PAYMENT API METHODS
  // ========================================

  // Create payment
  static Future<Map<String, dynamic>> createPayment({
    required String token,
    required double amount,
    required String paymentMethod,
    required String paymentProvider,
    String currency = 'ETB',
  }) async {
    try {
      
      final paymentData = {
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_provider': paymentProvider,
        'currency': currency,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/vendor-registration/payment'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(paymentData),
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 201) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to create payment'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get payment by ID
  static Future<Map<String, dynamic>> getPaymentById({
    required String token,
    required int paymentId,
  }) async {
    try {
      
      final response = await http.get(
        Uri.parse('$baseUrl/vendor-registration/payment/$paymentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get payment'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get my payments
  static Future<Map<String, dynamic>> getMyPayments({
    required String token,
    String? status,
    String? paymentMethod,
    int? page,
    int? limit,
  }) async {
    try {
      
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (paymentMethod != null) queryParams['payment_method'] = paymentMethod;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
      final uri = Uri.parse('$baseUrl/vendor-registration/my-payments').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get my payments'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Update payment status
  static Future<Map<String, dynamic>> updatePaymentStatus({
    required String token,
    required int paymentId,
    required String status,
    String? externalPaymentId,
    String? paymentReference,
  }) async {
    try {
      
      final updateData = {
        'status': status,
        if (externalPaymentId != null) 'external_payment_id': externalPaymentId,
        if (paymentReference != null) 'payment_reference': paymentReference,
      };
      
      final response = await http.put(
        Uri.parse('$baseUrl/vendor-registration/payment/$paymentId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to update payment status'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Process integrated payment
  static Future<Map<String, dynamic>> processIntegratedPayment({
    required String token,
    required int paymentId,
    required String externalPaymentId,
    required String paymentReference,
  }) async {
    try {
      
      final processData = {
        'external_payment_id': externalPaymentId,
        'payment_reference': paymentReference,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/vendor-registration/payment/$paymentId/process'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(processData),
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to process integrated payment'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Upload payment proof
  static Future<Map<String, dynamic>> uploadPaymentProof({
    required String token,
    required int paymentId,
    required int imageId,
  }) async {
    try {
      
      final proofData = {
        'image_id': imageId,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/vendor-registration/payment/$paymentId/proof'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(proofData),
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to upload payment proof'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Mobile app - Create payment
  static Future<Map<String, dynamic>> createMobilePayment({
    required String token,
    required double amount,
    required String paymentMethod,
    required String paymentProvider,
    String currency = 'ETB',
  }) async {
    try {
      
      final paymentData = {
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_provider': paymentProvider,
        'currency': currency,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/mobile/vendor-registration/payment'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(paymentData),
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 201) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to create mobile payment'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Mobile app - Upload payment proof file
  static Future<Map<String, dynamic>> uploadPaymentProofFile({
    required String token,
    required int paymentId,
    required String filePath,
  }) async {
    try {
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/mobile/vendor-registration/payment/$paymentId/upload-proof'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('proof_image', filePath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to upload payment proof file'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Mobile app - Proceed to next step
  static Future<Map<String, dynamic>> proceedToNextStep({
    required String token,
    required int paymentId,
    bool forceProceed = false,
  }) async {
    try {
      
      final proceedData = {
        'force_proceed': forceProceed,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/mobile/vendor-registration/payment/$paymentId/proceed'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(proceedData),
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to proceed to next step'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Mobile app - Generate QR code
  static Future<Map<String, dynamic>> generateQRCode({
    required String token,
    required int paymentId,
  }) async {
    try {
      
      final response = await http.get(
        Uri.parse('$baseUrl/mobile/vendor-registration/payment/$paymentId/qr'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to generate QR code'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Admin - Get all payments
  static Future<Map<String, dynamic>> getAllPayments({
    required String token,
    String? status,
    String? paymentMethod,
    String? paymentProvider,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
  }) async {
    try {
      
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (paymentMethod != null) queryParams['payment_method'] = paymentMethod;
      if (paymentProvider != null) queryParams['payment_provider'] = paymentProvider;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
      final uri = Uri.parse('$baseUrl/admin/vendor-payments').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get all payments'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Admin - Get pending payments
  static Future<Map<String, dynamic>> getPendingPayments({
    required String token,
  }) async {
    try {
      
      final response = await http.get(
        Uri.parse('$baseUrl/admin/vendor-payments/pending'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get pending payments'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Admin - Verify manual payment
  static Future<Map<String, dynamic>> verifyManualPayment({
    required String token,
    required int paymentId,
    required bool approved,
    String? adminNotes,
  }) async {
    try {
      
      final verifyData = {
        'approved': approved,
        if (adminNotes != null) 'admin_notes': adminNotes,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/admin/vendor-payments/$paymentId/verify'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(verifyData),
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to verify manual payment'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Admin - Get payment statistics
  static Future<Map<String, dynamic>> getPaymentStatistics({
    required String token,
  }) async {
    try {
      
      final response = await http.get(
        Uri.parse('$baseUrl/admin/vendor-payments/statistics'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get payment statistics'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // ============================================
  // WALLET METHODS
  // ============================================

  /// Get wallet data including balance and transaction history
  /// 
  /// [vendorId] - The vendor ID
  /// 
  /// Returns wallet data with balance and transactions
  static Future<Map<String, dynamic>> getWalletData({
    required String vendorId,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Authentication required. Please login again.',
        };
      }
      
      final url = Uri.parse('$vendorWalletEndpoint/$vendorId');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timeout - please check your connection');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Session expired. Please login again.',
          'status_code': response.statusCode,
        };
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 
                           errorData['error'] ?? 
                           'Failed to load wallet data';
        
        return {
          'success': false,
          'error': errorMessage,
          'status_code': response.statusCode,
        };
      }
    } on TimeoutException catch (e) {
      return {
        'success': false,
        'error': 'Request timeout - please check your connection',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to load wallet data: ${e.toString()}',
      };
    }
  }

  /// Get vendor wallet balance
  static Future<Map<String, dynamic>> getVendorWalletBalance({
    required String vendorId,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Authentication required'};
      }
      
      final response = await http.get(
        Uri.parse('$vendorWalletEndpoint/$vendorId/balance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to fetch balance',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Add funds to vendor wallet
  static Future<Map<String, dynamic>> addFundsToWallet({
    required String vendorId,
    required double amount,
    String? reason,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Authentication required'};
      }
      
      final url = Uri.parse('$vendorWalletEndpoint/$vendorId/add-funds');
      final requestBody = {
        'amount': amount,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      };
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'error': errorData['error'] ?? errorData['message'] ?? 'Failed to add funds (Status: ${response.statusCode})',
            'status_code': response.statusCode,
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Server error (${response.statusCode}): ${response.body}',
            'status_code': response.statusCode,
          };
        }
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get payment methods
  static Future<Map<String, dynamic>> getPaymentMethods({
    required String vendorId,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Authentication required'};
      }
      
      final response = await http.get(
        Uri.parse('$vendorWalletEndpoint/payment-methods/$vendorId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to fetch payment methods',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Create payment method
  static Future<Map<String, dynamic>> createPaymentMethod({
    required String vendorId,
    required String name,
    required String accountNumber,
    required String accountHolder,
    String? type,
    Map<String, dynamic>? details,
  }) async {
    try {
      debugPrint('🔄 [ApiService] Creating payment method');
      
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Authentication required'};
      }
      
      final body = {
        'name': name,
        'account_number': accountNumber,
        'account_holder': accountHolder,
        if (type != null) 'type': type,
        if (details != null) 'details': details,
      };

      final response = await http.post(
        Uri.parse('$vendorWalletEndpoint/payment-methods/$vendorId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to create payment method',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Update payment method
  static Future<Map<String, dynamic>> updatePaymentMethod({
    required int paymentMethodId,
    String? name,
    String? accountNumber,
    String? accountHolder,
    String? type,
    Map<String, dynamic>? details,
  }) async {
    try {
      debugPrint('🔄 [ApiService] Updating payment method: $paymentMethodId');
      
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Authentication required'};
      }
      
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (accountNumber != null) body['account_number'] = accountNumber;
      if (accountHolder != null) body['account_holder'] = accountHolder;
      if (type != null) body['type'] = type;
      if (details != null) body['details'] = details;

      final response = await http.patch(
        Uri.parse('$vendorWalletEndpoint/payment-methods/update/$paymentMethodId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to update payment method',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Delete payment method
  static Future<Map<String, dynamic>> deletePaymentMethod({
    required int paymentMethodId,
  }) async {
    try {
      debugPrint('🔄 [ApiService] Deleting payment method: $paymentMethodId');
      
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Authentication required'};
      }

      final response = await http.delete(
        Uri.parse('$vendorWalletEndpoint/payment-methods/delete/$paymentMethodId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to delete payment method',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Create cashout request
  static Future<Map<String, dynamic>> createCashoutRequest({
    required String vendorId,
    required double amount,
    String? reason,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Authentication required'};
      }
      
      final body = {
        'amount': amount,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      };

      final response = await http.post(
        Uri.parse('$vendorWalletEndpoint/cashout-request/$vendorId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to create cashout request',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get cashout requests
  static Future<Map<String, dynamic>> getCashoutRequests({
    required String vendorId,
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Authentication required'};
      }
      
      var url = '$vendorWalletEndpoint/cashout-request/$vendorId?page=$page&limit=$limit';
      if (status != null) {
        url += '&status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to fetch cashout requests',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get cashout request details
  static Future<Map<String, dynamic>> getCashoutRequestDetails({
    required int requestId,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Authentication required'};
      }

      final response = await http.get(
        Uri.parse('$vendorWalletEndpoint/cashout-request/details/$requestId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to fetch request details',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get transaction history
  static Future<Map<String, dynamic>> getTransactionHistory({
    required String vendorId,
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      debugPrint('🔄 [ApiService] Fetching transaction history');
      
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Authentication required'};
      }
      
      var url = '$vendorWalletEndpoint/$vendorId/transactions?page=$page&limit=$limit';
      if (status != null) {
        url += '&status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to fetch transactions',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Export transactions as CSV
  static Future<Map<String, dynamic>> exportTransactions({
    required String vendorId,
  }) async {
    try {
      debugPrint('🔄 [ApiService] Exporting transactions');
      
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Authentication required'};
      }

      final response = await http.get(
        Uri.parse('$vendorWalletEndpoint/$vendorId/export/csv'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.bodyBytes,
          'filename': 'transactions_${DateTime.now().millisecondsSinceEpoch}.csv',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to export transactions',
        };
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

}
