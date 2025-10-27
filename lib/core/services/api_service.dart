import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'dart:io' as io if (dart.library.io) 'dart:io';
import 'dart:html' as html if (dart.library.html) 'dart:html';
import 'user_service.dart';

class ApiService {
  // Backend API URL
  // Note: For Android Emulator, use 10.0.2.2 instead of localhost
  // For iOS Simulator, localhost works fine
  // For real device on same network, use your computer's IP address
  static const String baseUrl = 'http://localhost:4000/api';
  
  // Auth endpoints
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String registerClientEndpoint = '$baseUrl/auth/register-client';
  static const String registerVendorOwnerEndpoint = '$baseUrl/auth/register-vendor-owner';
  static const String verifyOtpEndpoint = '$baseUrl/auth/verify-otp';
  static const String resendOtpEndpoint = '$baseUrl/auth/resend-otp';
  static const String forgotPasswordEndpoint = '$baseUrl/auth/forgot-password';
  static const String verifyResetOtpEndpoint = '$baseUrl/auth/verify-reset-otp';
  static const String resetPasswordEndpoint = '$baseUrl/auth/reset-password';
  static const String meEndpoint = '$baseUrl/auth/me';
  
  // Vendor endpoints
  static const String createIndividualVendorEndpoint = '$baseUrl/vendor/individual';
  static const String registerBusinessVendorEndpoint = '$baseUrl/vendors/register-business';
  static const String vendorCompleteInfoEndpoint = '$baseUrl/vendors/my-complete-info';
  static const String vendorUpdateEndpoint = '$baseUrl/vendors/update';
  
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

  // Convert image path to bytes
  static Future<Uint8List> _convertImageToBytes(String imagePath) async {
    try {
      print('🔄 [API_SERVICE] Converting image to bytes...');
      print('   Path: $imagePath');
      print('   Platform: ${kIsWeb ? "Web" : "Mobile/Desktop"}');
      
      if (kIsWeb) {
        if (imagePath.startsWith('blob:')) {
          print('📦 [API_SERVICE] Handling blob URL...');
          // Handle blob URLs from file picker - fetch the blob data
          try {
            final response = await http.get(Uri.parse(imagePath));
            if (response.statusCode == 200) {
              print('✅ [API_SERVICE] Blob fetched successfully (${response.bodyBytes.length} bytes)');
              return response.bodyBytes;
            }
            throw Exception('Failed to fetch blob: ${response.statusCode}');
          } catch (e) {
            print('❌ [API_SERVICE] Error fetching blob: $e');
            rethrow;
          }
        } 
        else if (imagePath.startsWith('data:image')) {
          print('📦 [API_SERVICE] Handling data URL...');
          // Handle data URLs
          final bytes = base64Decode(imagePath.split(',').last);
          print('✅ [API_SERVICE] Data URL decoded (${bytes.length} bytes)');
          return Uint8List.fromList(bytes);
        }
        else if (imagePath.startsWith('http')) {
          print('📦 [API_SERVICE] Handling HTTP URL...');
          // Handle direct URLs
          final response = await http.get(Uri.parse(imagePath));
          if (response.statusCode == 200) {
            print('✅ [API_SERVICE] HTTP image fetched (${response.bodyBytes.length} bytes)');
            return response.bodyBytes;
          }
          throw Exception('Failed to fetch image: ${response.statusCode}');
        }
        print('❌ [API_SERVICE] Unsupported image source format');
        throw Exception('Unsupported image source: $imagePath');
      } else {
        print('📦 [API_SERVICE] Handling file path...');
        // For mobile/desktop, read file directly
        final file = io.File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          print('✅ [API_SERVICE] File read successfully (${bytes.length} bytes)');
          return bytes;
        }
        throw Exception('Image file not found: $imagePath');
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error converting image to bytes: $e');
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
        print('⚠️ [API_SERVICE] Error using mime package: $e');
      }

      // Default fallback
      print('⚠️ [API_SERVICE] Could not determine MIME type, defaulting to octet-stream');
      return 'application/octet-stream';
    } catch (e) {
      print('❌ [API_SERVICE] Error detecting MIME type: $e');
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

      // Log raw backend response for testing/debugging
      print('🔍 [API_SERVICE] Raw Login Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');

      final data = jsonDecode(response.body);
      try {
        print('📦 [API_SERVICE] Parsed Login Data Keys: ${data is Map ? data.keys.toList() : data.runtimeType}');
        if (data is Map && data['user'] is Map) {
          final user = data['user'] as Map<String, dynamic>;
          print('👤 [API_SERVICE] User keys: ${user.keys.toList()}');
          if (user['vendor'] is Map) {
            final vendor = user['vendor'] as Map<String, dynamic>;
            print('🏪 [API_SERVICE] Vendor keys: ${vendor.keys.toList()}');
            print('🏪 [API_SERVICE] Vendor status fields: approved=${vendor['approved']}, is_verified=${vendor['is_verified']}, status=${vendor['status']}');
          }
        }
      } catch (_) {}

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

      // Log raw backend response
      print('🔍 Raw Backend Response (register-vendor-owner):');
      print('   Status Code: ${response.statusCode}');
      print('   Headers: ${response.headers}');
      print('   Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Save token if returned for new users
        if (data['token'] != null) {
          print('💾 Saving token from registration...');
          await saveToken(data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        // Check if user already has a vendor account
        if (data['has_vendor'] == false) {
          // User exists but doesn't have vendor account - allow to proceed
          bool isOtpVerified = data['is_otp_verified'] ?? false;
          print('✅ User exists but no vendor account.');
          print('   OTP Verified: $isOtpVerified');
          print('   Token in response: ${data['token'] != null}');
          
          // Save token if present (for already verified users)
          if (data['token'] != null) {
            print('💾 Saving token for existing user...');
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

      // Log raw backend response
      print('🔍 Raw Backend Response (verify-otp):');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ OTP Verified!');
        print('   Token present: ${data['token'] != null}');
        print('   User present: ${data['user'] != null}');
        
        // Save token and user data if present (implicit login)
        if (data['token'] != null) {
          print('💾 Saving token from OTP verification...');
          await saveToken(data['token']);
          print('   Token saved successfully!');
        } else {
          print('⚠️  WARNING: No token returned from OTP verification!');
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
      print('🔄 [API_SERVICE] Verifying reset OTP for $phoneNumber');
      print('🔢 [API_SERVICE] OTP Code: $code');
      
      final response = await http.post(
        Uri.parse(verifyResetOtpEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'code': code,
        }),
      );

      print('📡 [API_SERVICE] Response Status: ${response.statusCode}');
      print('📡 [API_SERVICE] Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ [API_SERVICE] OTP verification successful');
        return {'success': true, 'data': data};
      } else {
        print('❌ [API_SERVICE] OTP verification failed');
        final errorMessage = data['error'] ?? data['message'] ?? 'OTP verification failed';
        print('❌ [API_SERVICE] Error: $errorMessage');
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Network error during OTP verification: $e');
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

  // Logout
  static Future<void> logout() async {
    await removeToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    // Clear global user data
    await UserService.instance.clearUserData();
  }

  // Fetch Categories
  static Future<Map<String, dynamic>> fetchCategories() async {
    try {
      print('📂 Fetching categories from backend...');
      
      final response = await http.get(
        Uri.parse(categoriesEndpoint),
        headers: {'Content-Type': 'application/json'},
      );

      print('🔍 Categories Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ Categories fetched successfully!');
        return {'success': true, 'categories': data};
      } else {
        print('❌ Failed to fetch categories');
        return {'success': false, 'error': 'Failed to fetch categories'};
      }
    } catch (e) {
      print('💥 Exception fetching categories: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Fetch Subscriptions (Public - no auth required)
  static Future<Map<String, dynamic>> fetchSubscriptions() async {
    try {
      print('📋 [API_SERVICE] Fetching subscriptions from backend...');
      print('🌐 [API_SERVICE] Endpoint: $subscriptionsEndpoint');
      print('🌐 [API_SERVICE] Base URL: $baseUrl');
      
      final uri = Uri.parse(subscriptionsEndpoint);
      print('🔗 [API_SERVICE] Parsed URI: $uri');
      print('🔗 [API_SERVICE] URI Host: ${uri.host}');
      print('🔗 [API_SERVICE] URI Port: ${uri.port}');
      print('🔗 [API_SERVICE] URI Path: ${uri.path}');
      
      final headers = {'Content-Type': 'application/json'};
      print('📤 [API_SERVICE] Request headers: $headers');
      
      print('⏳ [API_SERVICE] Making HTTP GET request...');
      final response = await http.get(uri, headers: headers);
      
      print('📥 [API_SERVICE] Response received!');
      print('🔍 [API_SERVICE] Status Code: ${response.statusCode}');
      print('🔍 [API_SERVICE] Response Headers: ${response.headers}');
      print('🔍 [API_SERVICE] Response Body Length: ${response.body.length}');
      print('🔍 [API_SERVICE] Response Body: ${response.body}');

      if (response.body.isEmpty) {
        print('⚠️ [API_SERVICE] Response body is empty!');
        return {'success': false, 'error': 'Empty response from server'};
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
        print('✅ [API_SERVICE] JSON decoded successfully');
        print('📊 [API_SERVICE] Decoded data type: ${data.runtimeType}');
        print('📊 [API_SERVICE] Decoded data: $data');
      } catch (jsonError) {
        print('💥 [API_SERVICE] JSON decode error: $jsonError');
        print('📄 [API_SERVICE] Raw response body: ${response.body}');
        return {'success': false, 'error': 'Invalid JSON response: $jsonError'};
      }

      if (response.statusCode == 200) {
        print('✅ [API_SERVICE] Subscriptions fetched successfully!');
        
        // Check if response has plans array or is direct array
        dynamic plans;
        if (data is List) {
          plans = data;
          print('📦 [API_SERVICE] Response is direct array');
        } else if (data is Map && data.containsKey('plans')) {
          plans = data['plans'] as List<dynamic>;
          print('📦 [API_SERVICE] Response has plans key');
        } else if (data is Map && data.containsKey('subscriptions')) {
          plans = data['subscriptions'] as List<dynamic>;
          print('📦 [API_SERVICE] Response has subscriptions key');
        } else {
          plans = data;
          print('📦 [API_SERVICE] Using data as-is');
        }
        
        print('📦 [API_SERVICE] Plans type: ${plans.runtimeType}');
        print('📦 [API_SERVICE] Plans count: ${plans is List ? plans.length : 'Not a list'}');
        print('📦 [API_SERVICE] Plans data: $plans');
        
        if (plans is! List) {
          print('⚠️ [API_SERVICE] Plans is not a list, converting...');
          plans = [plans];
        }
        
        return {'success': true, 'subscriptions': plans};
      } else {
        print('❌ [API_SERVICE] Failed to fetch subscriptions');
        print('❌ [API_SERVICE] Status code: ${response.statusCode}');
        final error = (data is Map && data.containsKey('error')) 
            ? data['error'] 
            : 'Failed to fetch subscriptions (Status: ${response.statusCode})';
        print('❌ [API_SERVICE] Error message: $error');
        return {'success': false, 'error': error};
      }
    } catch (e, stackTrace) {
      print('💥 [API_SERVICE] Exception fetching subscriptions: $e');
      print('💥 [API_SERVICE] Stack trace: $stackTrace');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }


  // Helper method to convert image URLs to bytes (legacy method - kept for backward compatibility)
  static Future<List<int>> _convertImageToBytesLegacy(String imagePath) async {
    final bytes = await _convertImageToBytes(imagePath);
    return bytes.toList();
  }

  // Helper method to determine MIME type from image bytes (legacy method - kept for backward compatibility)
  static String _getMimeTypeFromBytesLegacy(List<int> bytes) {
    return _getMimeTypeFromBytes(Uint8List.fromList(bytes));
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
    print('\n');
    print('═══════════════════════════════════════════════════════════');
    print('🚀 [API_SERVICE] STARTING BUSINESS VENDOR REGISTRATION');
    print('═══════════════════════════════════════════════════════════');
    
    try {
      print('\n📍 [API_SERVICE] STAGE 1: Authentication Check');
      print('─────────────────────────────────────────────────────────');
      final token = await getToken();
      if (token == null) {
        print('❌ [API_SERVICE] CLIENT ERROR: No auth token found');
        print('❌ [API_SERVICE] Error Source: CLIENT SIDE');
        return {'success': false, 'error': 'Authentication required', 'error_source': 'client'};
      }
      print('✅ [API_SERVICE] Auth token found: ${token.substring(0, 20)}...');

      print('\n📍 [API_SERVICE] STAGE 2: Request Preparation');
      print('─────────────────────────────────────────────────────────');
      print('🏢 [API_SERVICE] Registering business vendor (unified)...');
      print('🌐 [API_SERVICE] Endpoint: $registerBusinessVendorEndpoint');
      print('📊 [API_SERVICE] Request Data:');
      print('   • Business Name: $name');
      print('   • Description: ${description.length > 50 ? description.substring(0, 50) + "..." : description}');
      print('   • Full Name: $fullName');
      print('   • Email: $email');
      print('   • Phone: $phoneNumber');
      print('   • Categories: $categoryIds');
      print('   • Payment Method Type: $paymentMethodType');
      print('   • Account Holder: $accountHolderName');
      print('   • Subscription ID: $subscriptionId');

      final uri = Uri.parse(registerBusinessVendorEndpoint);
      print('🔗 [API_SERVICE] Parsed URI: $uri');

      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      print('📤 [API_SERVICE] Request headers: ${request.headers}');

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
      print('🏷️ [API_SERVICE] Category IDs to send: $categoryIds');
      print('🏷️ [API_SERVICE] Category IDs JSON: ${jsonEncode(categoryIds)}');
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

      print('📝 [API_SERVICE] Request fields: ${request.fields}');

      // ===== FILES =====
      print('\n📍 [API_SERVICE] STAGE 3: Image Processing');
      print('─────────────────────────────────────────────────────────');
      if (kIsWeb) {
        print('📱 [API_SERVICE] Platform: WEB');
        print('🖼️ [API_SERVICE] Cover image path: $coverImagePath');
        print('📄 [API_SERVICE] License image path: $businessLicenseImagePath');
        
        try {
          // Convert blob URLs to bytes and add as files
          print('\n🔄 [API_SERVICE] Processing cover image...');
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
          print('✅ [API_SERVICE] Cover image processed successfully ($coverMimeType)');
          
          print('📄 [API_SERVICE] Processing license image...');
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
          print('✅ [API_SERVICE] License image processed successfully ($licenseMimeType)');
          
        } catch (e, stackTrace) {
          print('\n💥 [API_SERVICE] ========================================');
          print('💥 [API_SERVICE] CLIENT ERROR: Image Processing Failed');
          print('💥 [API_SERVICE] ========================================');
          print('💥 [API_SERVICE] Error Source: CLIENT SIDE (Web Image Processing)');
          print('💥 [API_SERVICE] Platform: WEB');
          print('💥 [API_SERVICE] Exception: $e');
          print('💥 [API_SERVICE] Stack Trace: $stackTrace');
          print('💥 [API_SERVICE] ========================================');
          return {'success': false, 'error': 'Failed to process images: $e', 'error_source': 'client'};
        }
      } else {
        // Mobile/Desktop platform: Use file path
        print('📱 [API_SERVICE] Platform: MOBILE/DESKTOP');
        print('🖼️ [API_SERVICE] Cover image path: $coverImagePath');
        print('📄 [API_SERVICE] License image path: $businessLicenseImagePath');
        
        try {
          print('\n🔄 [API_SERVICE] Validating file paths...');
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
          
          print('✅ [API_SERVICE] Files added successfully');
          print('   - Cover: $coverMimeType');
          print('   - License: $licenseMimeType');
          
        } catch (e, stackTrace) {
          print('\n💥 [API_SERVICE] ========================================');
          print('💥 [API_SERVICE] CLIENT ERROR: File Processing Failed');
          print('💥 [API_SERVICE] ========================================');
          print('💥 [API_SERVICE] Error Source: CLIENT SIDE (Mobile File Processing)');
          print('💥 [API_SERVICE] Platform: MOBILE/DESKTOP');
          print('💥 [API_SERVICE] Exception: $e');
          print('💥 [API_SERVICE] Stack Trace: $stackTrace');
          print('💥 [API_SERVICE] ========================================');
          return {'success': false, 'error': 'Failed to process files: $e', 'error_source': 'client'};
        }
      }

      print('\n✅ [API_SERVICE] Image processing completed');
      print('📦 [API_SERVICE] Total files attached: ${request.files.length}');
      
      print('\n📍 [API_SERVICE] STAGE 4: Sending HTTP Request');
      print('─────────────────────────────────────────────────────────');
      print('⏳ [API_SERVICE] Sending multipart request to API...');
      print('🌐 [API_SERVICE] Target: $registerBusinessVendorEndpoint');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('\n📍 [API_SERVICE] STAGE 5: Processing API Response');
      print('─────────────────────────────────────────────────────────');
      print('📥 [API_SERVICE] Response received from API');
      print('🔍 [API_SERVICE] Status Code: ${response.statusCode}');
      print('🔍 [API_SERVICE] Response Headers: ${response.headers}');
      print('🔍 [API_SERVICE] Response Body Length: ${response.body.length} bytes');
      print('🔍 [API_SERVICE] Response Body: ${response.body}');

      if (response.body.isEmpty) {
        print('\n⚠️ [API_SERVICE] ========================================');
        print('⚠️ [API_SERVICE] API ERROR: Empty Response');
        print('⚠️ [API_SERVICE] ========================================');
        print('⚠️ [API_SERVICE] Error Source: BACKEND API');
        print('⚠️ [API_SERVICE] Status Code: ${response.statusCode}');
        print('⚠️ [API_SERVICE] Issue: Server returned empty response body');
        print('⚠️ [API_SERVICE] ========================================');
        return {'success': false, 'error': 'Empty response from server', 'error_source': 'api'};
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
        print('✅ [API_SERVICE] JSON decoded successfully');
        print('📊 [API_SERVICE] Decoded data type: ${data.runtimeType}');
        print('📊 [API_SERVICE] Decoded data: $data');
      } catch (jsonError, stackTrace) {
        print('\n💥 [API_SERVICE] ========================================');
        print('💥 [API_SERVICE] API ERROR: Invalid JSON Response');
        print('💥 [API_SERVICE] ========================================');
        print('💥 [API_SERVICE] Error Source: BACKEND API (Invalid Response Format)');
        print('💥 [API_SERVICE] Status Code: ${response.statusCode}');
        print('💥 [API_SERVICE] JSON Error: $jsonError');
        print('💥 [API_SERVICE] Raw Response Body: ${response.body}');
        print('💥 [API_SERVICE] Stack Trace: $stackTrace');
        print('💥 [API_SERVICE] ========================================');
        return {'success': false, 'error': 'Invalid JSON response: $jsonError', 'error_source': 'api'};
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('\n✅ [API_SERVICE] ========================================');
        print('✅ [API_SERVICE] SUCCESS: Business Vendor Registered');
        print('✅ [API_SERVICE] ========================================');
        print('✅ [API_SERVICE] Status Code: ${response.statusCode}');
        print('✅ [API_SERVICE] Vendor ID: ${data['vendor']?['id'] ?? 'N/A'}');
        print('✅ [API_SERVICE] Vendor Name: ${data['vendor']?['name'] ?? name}');
        print('✅ [API_SERVICE] Payment Status: ${data['payment']?['status'] ?? 'N/A'}');
        print('✅ [API_SERVICE] ========================================');
        print('\n');
        return {
          'success': true,
          'vendor': data['vendor'] ?? data,
          'payment': data['payment'],
          'message': data['message'] ?? 'Business vendor registered successfully'
        };
      } else {
        print('\n');
        print('❌ [API_SERVICE] ========================================');
        print('❌ [API_SERVICE] API ERROR - Business vendor registration failed');
        print('❌ [API_SERVICE] ========================================');
        print('❌ [API_SERVICE] Error Source: BACKEND API');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Headers: ${response.headers}');
        print('❌ [API_SERVICE] Response Body: ${response.body}');
        
        final error = (data is Map && data.containsKey('error'))
            ? data['error']
            : (data is Map && data.containsKey('message'))
                ? data['message']
                : 'Failed to register business vendor (Status: ${response.statusCode})';
        
        print('❌ [API_SERVICE] Error Message: $error');
        
        // Log detailed error information if available
        if (data is Map) {
          if (data.containsKey('details')) {
            print('❌ [API_SERVICE] Error Details: ${data['details']}');
          }
          if (data.containsKey('validation_errors')) {
            print('❌ [API_SERVICE] Validation Errors: ${data['validation_errors']}');
          }
          if (data.containsKey('field_errors')) {
            print('❌ [API_SERVICE] Field Errors: ${data['field_errors']}');
          }
        }
        
        print('❌ [API_SERVICE] ========================================');
        print('\n');
        return {'success': false, 'error': error, 'error_source': 'api', 'status_code': response.statusCode};
      }
    } catch (e, stackTrace) {
      print('\n');
      print('💥 [API_SERVICE] ========================================');
      print('💥 [API_SERVICE] CLIENT ERROR - Exception During Registration');
      print('💥 [API_SERVICE] ========================================');
      print('💥 [API_SERVICE] Error Source: CLIENT SIDE');
      print('💥 [API_SERVICE] Exception Type: ${e.runtimeType}');
      print('💥 [API_SERVICE] Exception Message: $e');
      print('💥 [API_SERVICE] Possible Causes:');
      print('   • Network connectivity issues');
      print('   • Timeout during request');
      print('   • Invalid file paths or permissions');
      print('   • Memory issues with large files');
      print('💥 [API_SERVICE] Stack Trace:');
      print('$stackTrace');
      print('💥 [API_SERVICE] ========================================');
      print('\n');
      return {'success': false, 'error': 'Network error: ${e.toString()}', 'error_source': 'client'};
    }
  }

  // Get vendor complete info
  Future<Map<String, dynamic>> getVendorCompleteInfo() async {
    try {
      print('\n');
      print('🔄 [API_SERVICE] ========================================');
      print('🔄 [API_SERVICE] GETTING VENDOR COMPLETE INFO');
      print('🔄 [API_SERVICE] ========================================');
      print('🔄 [API_SERVICE] Endpoint: $vendorCompleteInfoEndpoint');
      
      // Get JWT token from SharedPreferences
      final token = await getToken();
      
      if (token == null) {
        print('❌ [API_SERVICE] No JWT token found');
        return {'success': false, 'error': 'No authentication token found'};
      }
      
      print('🔄 [API_SERVICE] Token found: ${token.substring(0, 20)}...');
      print('🔄 [API_SERVICE] Full JWT Token: $token');
      
      // Make the API request
      final response = await http.get(
        Uri.parse(vendorCompleteInfoEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('🔄 [API_SERVICE] Response Status: ${response.statusCode}');
      print('🔄 [API_SERVICE] Response Headers: ${response.headers}');
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        print('✅ [API_SERVICE] Vendor info retrieved successfully');
        print('✅ [API_SERVICE] Response Data: $data');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to get vendor info');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: ${response.body}');
        
        final error = (data is Map && data.containsKey('error'))
            ? data['error']
            : (data is Map && data.containsKey('message'))
                ? data['message']
                : 'Failed to get vendor info (Status: ${response.statusCode})';
        
        return {'success': false, 'error': error};
      }
    } catch (e, stackTrace) {
      print('\n');
      print('💥 [API_SERVICE] ========================================');
      print('💥 [API_SERVICE] ERROR GETTING VENDOR INFO');
      print('💥 [API_SERVICE] ========================================');
      print('💥 [API_SERVICE] Exception: $e');
      print('💥 [API_SERVICE] Stack Trace: $stackTrace');
      print('💥 [API_SERVICE] ========================================');
      print('\n');
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
      print('\n');
      print('🔄 [API_SERVICE] ========================================');
      print('🔄 [API_SERVICE] UPDATING VENDOR INFO');
      print('🔄 [API_SERVICE] ========================================');
      print('🔄 [API_SERVICE] Endpoint: $vendorUpdateEndpoint');
      print('🔄 [API_SERVICE] Token: ${token.substring(0, 20)}...');
      
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
        print('🔄 [API_SERVICE] Adding name: $name');
      }
      
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
        print('🔄 [API_SERVICE] Adding description: $description');
      }
      
      // Add image files if provided
      if (coverImagePath != null && coverImagePath.isNotEmpty) {
        print('🔄 [API_SERVICE] Adding cover image: $coverImagePath');
        print('🔄 [API_SERVICE] Platform: ${kIsWeb ? "Web" : "Mobile"}');
        
        if (kIsWeb) {
          // For web, convert image to bytes first
          try {
            final imageBytes = await _convertImageToBytes(coverImagePath);
            print('🔄 [API_SERVICE] Image converted to bytes: ${imageBytes.length} bytes');
            final coverImageFile = http.MultipartFile.fromBytes(
              'cover_image',
              imageBytes,
              filename: 'cover_image.jpg',
              contentType: MediaType('image', 'jpeg'),
            );
            request.files.add(coverImageFile);
            print('✅ [API_SERVICE] Cover image file added to request');
          } catch (e) {
            print('❌ [API_SERVICE] Error converting cover image to bytes: $e');
            return {'success': false, 'error': 'Failed to process cover image: $e'};
          }
        } else {
          // For mobile, use file path directly
          try {
            final coverImageFile = await http.MultipartFile.fromPath('cover_image', coverImagePath);
            request.files.add(coverImageFile);
            print('✅ [API_SERVICE] Cover image file added to request');
          } catch (e) {
            print('❌ [API_SERVICE] Error creating cover image file: $e');
            return {'success': false, 'error': 'Failed to process cover image: $e'};
          }
        }
      }
      
      if (faydaImagePath != null && faydaImagePath.isNotEmpty) {
        print('🔄 [API_SERVICE] Adding fayda image: $faydaImagePath');
        
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
        print('🔄 [API_SERVICE] Adding business license image: $businessLicenseImagePath');
        
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
        print('❌ [API_SERVICE] No fields provided for update');
        return {'success': false, 'error': 'No valid fields provided for update'};
      }
      
      print('🔄 [API_SERVICE] Sending request...');
      print('🔄 [API_SERVICE] Request fields: ${request.fields}');
      print('🔄 [API_SERVICE] Request files count: ${request.files.length}');
      
      final response = await request.send();
      
      print('🔄 [API_SERVICE] Response Status: ${response.statusCode}');
      print('🔄 [API_SERVICE] Response Headers: ${response.headers}');
      
      final responseBody = await response.stream.bytesToString();
      print('🔄 [API_SERVICE] Response Body: $responseBody');
      
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        print('✅ [API_SERVICE] Vendor updated successfully');
        print('✅ [API_SERVICE] Response Data: $data');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to update vendor');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        
        final error = (data is Map && data.containsKey('error'))
            ? data['error']
            : (data is Map && data.containsKey('message'))
                ? data['message']
                : 'Failed to update vendor (Status: ${response.statusCode})';
        
        return {'success': false, 'error': error};
      }
    } catch (e, stackTrace) {
      print('\n');
      print('💥 [API_SERVICE] ========================================');
      print('💥 [API_SERVICE] ERROR UPDATING VENDOR');
      print('💥 [API_SERVICE] ========================================');
      print('💥 [API_SERVICE] Exception: $e');
      print('💥 [API_SERVICE] Stack Trace: $stackTrace');
      print('💥 [API_SERVICE] ========================================');
      print('\n');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // ========================================
  // VENDOR CONTACTS API METHODS
  // ========================================

  // Get all vendor contacts
  static Future<Map<String, dynamic>> getVendorContacts({required String token}) async {
    try {
      print('🔄 [API_SERVICE] Getting vendor contacts...');
      
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
        print('✅ [API_SERVICE] Vendor contacts retrieved successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to get vendor contacts');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to get vendor contacts'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error getting vendor contacts: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get vendor contacts by type
  static Future<Map<String, dynamic>> getVendorContactsByType({
    required String token,
    required String type,
  }) async {
    try {
      print('🔄 [API_SERVICE] Getting vendor contacts by type: $type...');
      
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
        print('✅ [API_SERVICE] Vendor contacts by type retrieved successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to get vendor contacts by type');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to get vendor contacts by type'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error getting vendor contacts by type: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Create a single vendor contact
  static Future<Map<String, dynamic>> createVendorContact({
    required String token,
    required Map<String, dynamic> contactData,
  }) async {
    try {
      print('🔄 [API_SERVICE] Creating vendor contact...');
      print('🔄 [API_SERVICE] Contact data: $contactData');
      
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
        print('✅ [API_SERVICE] Vendor contact created successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to create vendor contact');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to create vendor contact'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error creating vendor contact: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Create multiple vendor contacts (bulk)
  static Future<Map<String, dynamic>> createVendorContactsBulk({
    required String token,
    required List<Map<String, dynamic>> contacts,
  }) async {
    try {
      print('🔄 [API_SERVICE] Creating vendor contacts in bulk...');
      print('🔄 [API_SERVICE] Contacts count: ${contacts.length}');
      
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
        print('✅ [API_SERVICE] Vendor contacts created in bulk successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to create vendor contacts in bulk');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to create vendor contacts in bulk'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error creating vendor contacts in bulk: $e');
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
      print('🔄 [API_SERVICE] Updating vendor contact: $contactId...');
      print('🔄 [API_SERVICE] Update data: $updateData');
      
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
        print('✅ [API_SERVICE] Vendor contact updated successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to update vendor contact');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to update vendor contact'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error updating vendor contact: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Set vendor contact as primary
  static Future<Map<String, dynamic>> setVendorContactAsPrimary({
    required String token,
    required int contactId,
  }) async {
    try {
      print('🔄 [API_SERVICE] Setting vendor contact as primary: $contactId...');
      
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
        print('✅ [API_SERVICE] Vendor contact set as primary successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to set vendor contact as primary');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to set vendor contact as primary'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error setting vendor contact as primary: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Delete a vendor contact
  static Future<Map<String, dynamic>> deleteVendorContact({
    required String token,
    required int contactId,
  }) async {
    try {
      print('🔄 [API_SERVICE] Deleting vendor contact: $contactId...');
      
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
        print('✅ [API_SERVICE] Vendor contact deleted successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to delete vendor contact');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to delete vendor contact'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error deleting vendor contact: $e');
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
      print('🔄 [API_SERVICE] Getting my shipping addresses...');
      
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
        print('✅ [API_SERVICE] My shipping addresses retrieved successfully');
        return {'success': true, 'addresses': data['addresses']};
      } else {
        print('❌ [API_SERVICE] Failed to get my shipping addresses');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to get my shipping addresses'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error getting my shipping addresses: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Create my shipping address (Vendor)
  static Future<Map<String, dynamic>> createMyShippingAddress({
    required String token,
    required Map<String, dynamic> addressData,
  }) async {
    try {
      print('🔄 [API_SERVICE] Creating my shipping address...');
      print('🔄 [API_SERVICE] Address data: $addressData');
      
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
        print('✅ [API_SERVICE] My shipping address created successfully');
        return {'success': true, 'address': data['address']};
      } else {
        print('❌ [API_SERVICE] Failed to create my shipping address');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to create my shipping address'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error creating my shipping address: $e');
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
      print('🔄 [API_SERVICE] Updating my shipping address: $addressId...');
      print('🔄 [API_SERVICE] Update data: $updateData');
      
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
        print('✅ [API_SERVICE] My shipping address updated successfully');
        return {'success': true, 'address': data['address']};
      } else {
        print('❌ [API_SERVICE] Failed to update my shipping address');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to update my shipping address'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error updating my shipping address: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Delete my shipping address (Vendor)
  static Future<Map<String, dynamic>> deleteMyShippingAddress({
    required String token,
    required int addressId,
  }) async {
    try {
      print('🔄 [API_SERVICE] Deleting my shipping address: $addressId...');
      
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
        print('✅ [API_SERVICE] My shipping address deleted successfully');
        return {'success': true, 'message': data['message'], 'id': data['id']};
      } else {
        print('❌ [API_SERVICE] Failed to delete my shipping address');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to delete my shipping address'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error deleting my shipping address: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Set primary shipping address (Vendor)
  static Future<Map<String, dynamic>> setMyPrimaryShippingAddress({
    required String token,
    required int addressId,
  }) async {
    try {
      print('🔄 [API_SERVICE] Setting my shipping address as primary: $addressId...');
      
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
        print('✅ [API_SERVICE] My shipping address set as primary successfully');
        return {'success': true, 'address': data['address']};
      } else {
        print('❌ [API_SERVICE] Failed to set my shipping address as primary');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to set my shipping address as primary'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error setting my shipping address as primary: $e');
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
      print('🔄 [API_SERVICE] Creating payment...');
      
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
        print('✅ [API_SERVICE] Payment created successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to create payment');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to create payment'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error creating payment: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get payment by ID
  static Future<Map<String, dynamic>> getPaymentById({
    required String token,
    required int paymentId,
  }) async {
    try {
      print('🔄 [API_SERVICE] Getting payment by ID: $paymentId...');
      
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
        print('✅ [API_SERVICE] Payment retrieved successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to get payment');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to get payment'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error getting payment: $e');
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
      print('🔄 [API_SERVICE] Getting my payments...');
      
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
        print('✅ [API_SERVICE] My payments retrieved successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to get my payments');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to get my payments'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error getting my payments: $e');
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
      print('🔄 [API_SERVICE] Updating payment status: $paymentId...');
      
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
        print('✅ [API_SERVICE] Payment status updated successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to update payment status');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to update payment status'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error updating payment status: $e');
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
      print('🔄 [API_SERVICE] Processing integrated payment: $paymentId...');
      
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
        print('✅ [API_SERVICE] Integrated payment processed successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to process integrated payment');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to process integrated payment'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error processing integrated payment: $e');
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
      print('🔄 [API_SERVICE] Uploading payment proof: $paymentId...');
      
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
        print('✅ [API_SERVICE] Payment proof uploaded successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to upload payment proof');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to upload payment proof'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error uploading payment proof: $e');
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
      print('🔄 [API_SERVICE] Creating mobile payment...');
      
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
        print('✅ [API_SERVICE] Mobile payment created successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to create mobile payment');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to create mobile payment'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error creating mobile payment: $e');
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
      print('🔄 [API_SERVICE] Uploading payment proof file: $paymentId...');
      
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
        print('✅ [API_SERVICE] Payment proof file uploaded successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to upload payment proof file');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to upload payment proof file'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error uploading payment proof file: $e');
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
      print('🔄 [API_SERVICE] Proceeding to next step: $paymentId...');
      
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
        print('✅ [API_SERVICE] Proceeded to next step successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to proceed to next step');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to proceed to next step'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error proceeding to next step: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Mobile app - Generate QR code
  static Future<Map<String, dynamic>> generateQRCode({
    required String token,
    required int paymentId,
  }) async {
    try {
      print('🔄 [API_SERVICE] Generating QR code: $paymentId...');
      
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
        print('✅ [API_SERVICE] QR code generated successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to generate QR code');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to generate QR code'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error generating QR code: $e');
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
      print('🔄 [API_SERVICE] Getting all payments...');
      
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
        print('✅ [API_SERVICE] All payments retrieved successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to get all payments');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to get all payments'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error getting all payments: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Admin - Get pending payments
  static Future<Map<String, dynamic>> getPendingPayments({
    required String token,
  }) async {
    try {
      print('🔄 [API_SERVICE] Getting pending payments...');
      
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
        print('✅ [API_SERVICE] Pending payments retrieved successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to get pending payments');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to get pending payments'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error getting pending payments: $e');
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
      print('🔄 [API_SERVICE] Verifying manual payment: $paymentId...');
      
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
        print('✅ [API_SERVICE] Manual payment verified successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to verify manual payment');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to verify manual payment'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error verifying manual payment: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Admin - Get payment statistics
  static Future<Map<String, dynamic>> getPaymentStatistics({
    required String token,
  }) async {
    try {
      print('🔄 [API_SERVICE] Getting payment statistics...');
      
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
        print('✅ [API_SERVICE] Payment statistics retrieved successfully');
        return data;
      } else {
        print('❌ [API_SERVICE] Failed to get payment statistics');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'error': data['error'] ?? 'Failed to get payment statistics'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error getting payment statistics: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Change Password Methods
  Future<Map<String, dynamic>> sendForgotPasswordOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      print('🔄 [API_SERVICE] Sending forgot password OTP to $phone');
      print('📱 [API_SERVICE] Phone number: $phone');
      print('🔢 [API_SERVICE] OTP: $otp');
      
      final requestBody = {
        'phone_number': phone,
        'otp': otp,
      };
      print('📦 [API_SERVICE] Request body: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(forgotPasswordEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        print('✅ [API_SERVICE] Forgot password OTP sent successfully');
        return {'success': true, 'data': data};
      } else {
        print('❌ [API_SERVICE] Failed to send forgot password OTP');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'message': data['message'] ?? 'Failed to send OTP'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error sending forgot password OTP: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String otp,
  }) async {
    try {
      print('🔄 [API_SERVICE] Changing password...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'otp': otp,
        }),
      );
      
      final responseBody = response.body;
      final data = json.decode(responseBody);
      
      if (response.statusCode == 200) {
        print('✅ [API_SERVICE] Password changed successfully');
        return {'success': true, 'data': data};
      } else {
        print('❌ [API_SERVICE] Failed to change password');
        print('❌ [API_SERVICE] Status Code: ${response.statusCode}');
        print('❌ [API_SERVICE] Response Body: $responseBody');
        return {'success': false, 'message': data['message'] ?? 'Failed to change password'};
      }
    } catch (e) {
      print('❌ [API_SERVICE] Error changing password: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }



}
