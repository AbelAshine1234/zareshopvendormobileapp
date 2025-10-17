import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show File;

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
  static const String createBusinessVendorEndpoint = '$baseUrl/vendors/business';
  static const String registerBusinessVendorEndpoint = '$baseUrl/vendors/register-business';
  
  // Category endpoints
  static const String categoriesEndpoint = '$baseUrl/category';
  
  // Subscription endpoints
  static const String subscriptionsEndpoint = '$baseUrl/subscription/plans';

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
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Register Client (Individual Vendor)
  static Future<Map<String, dynamic>> registerClient({
    required String name,
    required String phoneNumber,
    required String password,
    String? email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(registerClientEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'phone_number': phoneNumber,
          'password': password,
          if (email != null && email.isNotEmpty) 'email': email,
          'type': 'client',
        }),
      );

      // Log raw backend response
      print('🔍 Raw Backend Response (register-client):');
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
        return {'success': false, 'error': data['error'] ?? 'OTP verification failed'};
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

  // Logout
  static Future<void> logout() async {
    await removeToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  // Create Individual Vendor
  static Future<Map<String, dynamic>> createIndividualVendor({
    required String name,
    required String description,
    required String addressLine1,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    required List<int> categoryIds,
    required String paymentMethod,
    required String coverImagePath,
    required String faydaImagePath,
    required int subscriptionId,
    String? addressLine2,
    String? paymentId,
  }) async {
    try {
      final token = await getToken();
      // Token should already exist from login after OTP verification
      // No need to check - just use it

      print('🏪 Creating individual vendor...');
      print('   Name: $name');
      print('   City: $city');
      print('   Categories: $categoryIds');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(createIndividualVendorEndpoint),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['name'] = name;
      request.fields['description'] = description;
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
      
      request.fields['category_ids'] = jsonEncode(categoryIds);
      request.fields['payment_method'] = paymentMethod;
      request.fields['subscription_id'] = subscriptionId.toString();
      
      if (paymentId != null && paymentId.isNotEmpty) {
        request.fields['payment_id'] = paymentId;
      }

      // Add image files
      if (kIsWeb) {
        // Web platform: Handle data URL strings ONLY
        print('📱 Web platform detected - converting data URLs to bytes');
        
        // Extract base64 data from data URL (format: data:image/jpeg;base64,...)
        final coverBase64 = coverImagePath.split(',').last;
        final coverBytes = base64Decode(coverBase64);
        
        request.files.add(http.MultipartFile.fromBytes(
          'cover_image',
          coverBytes,
          filename: 'cover_image.jpg',
        ));
        
        final faydaBase64 = faydaImagePath.split(',').last;
        final faydaBytes = base64Decode(faydaBase64);
        
        request.files.add(http.MultipartFile.fromBytes(
          'fayda_image',
          faydaBytes,
          filename: 'fayda_image.jpg',
        ));
      } else {
        // Mobile/Desktop platform: Use file path
        print('📱 Mobile platform detected - using file path for upload');
        request.files.add(await http.MultipartFile.fromPath(
          'cover_image',
          coverImagePath,
        ));
        
        request.files.add(await http.MultipartFile.fromPath(
          'fayda_image',
          faydaImagePath,
        ));
      }

      print('📤 Sending vendor creation request...');
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Log raw backend response
      print('🔍 Raw Backend Response (create-individual-vendor):');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Vendor created successfully!');
        return {'success': true, 'data': data};
      } else {
        print('❌ Vendor creation failed: ${data['error']}');
        return {'success': false, 'error': data['error'] ?? 'Failed to create vendor'};
      }
    } catch (e) {
      print('💥 Exception during vendor creation: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Create Business Vendor
  static Future<Map<String, dynamic>> createBusinessVendor({
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
    String? paymentId,
  }) async {
    try {
      final token = await getToken();
      // Token should already exist from login after OTP verification
      // No need to check - just use it

      print('🏢 [API_SERVICE] Creating business vendor...');
      print('🌐 [API_SERVICE] Endpoint: $createBusinessVendorEndpoint');
      print('📊 [API_SERVICE] Business Name: $name');
      print('📊 [API_SERVICE] Description: $description');
      print('📊 [API_SERVICE] City: $city');
      print('📊 [API_SERVICE] Categories: $categoryIds');
      print('📊 [API_SERVICE] Payment Method Type: $paymentMethodType');
      print('📊 [API_SERVICE] Account Holder: $accountHolderName');
      print('📊 [API_SERVICE] Subscription ID: $subscriptionId');
      
      if (token == null) {
        print('❌ [API_SERVICE] No auth token found');
        return {'success': false, 'error': 'Authentication required'};
      }
      
      print('🔑 [API_SERVICE] Auth token found: ${token.substring(0, 20)}...');
      
      final uri = Uri.parse(createBusinessVendorEndpoint);
      print('🔗 [API_SERVICE] Parsed URI: $uri');
      
      var request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      
      print('📤 [API_SERVICE] Request headers: ${request.headers}');

      // Add text fields
      request.fields['name'] = name;
      request.fields['description'] = description;
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
      
      print('🏷️ [API_SERVICE] Category IDs to send: $categoryIds');
      print('🏷️ [API_SERVICE] Category IDs JSON: ${jsonEncode(categoryIds)}');
      request.fields['category_ids'] = jsonEncode(categoryIds);
      
      // Construct payment_method object
      final paymentMethodObj = {
        'name': accountName, // Bank name or wallet provider
        'account_number': accountNumber,
        'account_holder': accountHolderName,
        'type': paymentMethodType, // 'bank' or 'wallet'
        'details': {},
      };
      request.fields['payment_method'] = jsonEncode(paymentMethodObj);
      
      request.fields['subscription_id'] = subscriptionId.toString();
      
      if (paymentId != null && paymentId.isNotEmpty) {
        request.fields['payment_id'] = paymentId;
      }
      
      print('📝 [API_SERVICE] Request fields: ${request.fields}');

      // Add image files
      if (kIsWeb) {
        print('📱 [API_SERVICE] Web platform detected');
        print('🖼️ [API_SERVICE] Cover image path: $coverImagePath');
        print('📄 [API_SERVICE] License image path: $businessLicenseImagePath');
        
        try {
          // Convert blob URLs to bytes and add as files
          print('🖼️ [API_SERVICE] Processing cover image...');
          final coverImageBytes = await _convertImageToBytes(coverImagePath);
          request.files.add(http.MultipartFile.fromBytes(
            'cover_image',
            coverImageBytes,
            filename: 'cover_image.jpg',
          ));
          print('✅ [API_SERVICE] Cover image processed successfully');
          
          print('📄 [API_SERVICE] Processing license image...');
          final licenseImageBytes = await _convertImageToBytes(businessLicenseImagePath);
          request.files.add(http.MultipartFile.fromBytes(
            'business_license_image',
            licenseImageBytes,
            filename: 'business_license.jpg',
          ));
          print('✅ [API_SERVICE] License image processed successfully');
          
        } catch (e) {
          print('💥 [API_SERVICE] Error processing web images: $e');
          throw Exception('Failed to process images: $e');
        }
      } else {
        // Mobile/Desktop platform: Use file path
        print('📱 [API_SERVICE] Mobile platform detected - using file path for upload');
        print('🖼️ [API_SERVICE] Cover image path: $coverImagePath');
        print('📄 [API_SERVICE] License image path: $businessLicenseImagePath');
        
        try {
          request.files.add(await http.MultipartFile.fromPath(
            'cover_image',
            coverImagePath,
          ));
          
          request.files.add(await http.MultipartFile.fromPath(
            'business_license_image',
            businessLicenseImagePath,
          ));
          print('✅ [API_SERVICE] Mobile files added successfully');
        } catch (e) {
          print('💥 [API_SERVICE] Error processing mobile files: $e');
          throw Exception('Failed to process files: $e');
        }
      }

      print('📦 [API_SERVICE] Total files attached: ${request.files.length}');
      
      print('⏳ [API_SERVICE] Sending multipart request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [API_SERVICE] Business vendor created successfully!');
        print('🏢 [API_SERVICE] Vendor data: ${data['vendor'] ?? data}');
        return {
          'success': true,
          'vendor': data['vendor'] ?? data,
          'message': data['message'] ?? 'Business vendor created successfully'
        };
      } else {
        print('❌ [API_SERVICE] Failed to create business vendor');
        print('❌ [API_SERVICE] Status code: ${response.statusCode}');
        final error = (data is Map && data.containsKey('error'))
            ? data['error']
            : (data is Map && data.containsKey('message'))
                ? data['message']
                : 'Failed to create business vendor (Status: ${response.statusCode})';
        print('❌ [API_SERVICE] Error message: $error');
        return {'success': false, 'error': error};
      }
    } catch (e, stackTrace) {
      print('💥 [API_SERVICE] Exception creating business vendor: $e');
      print('💥 [API_SERVICE] Stack trace: $stackTrace');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
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

  // Helper method to convert image URLs to bytes
  static Future<List<int>> _convertImageToBytes(String imagePath) async {
    try {
      print('🔄 [API_SERVICE] Converting image to bytes: $imagePath');
      
      if (imagePath.startsWith('data:')) {
        print('✅ [API_SERVICE] Processing data URL');
        // Extract base64 data from data URL (format: data:image/jpeg;base64,...)
        final base64Data = imagePath.split(',').last;
        final bytes = base64Decode(base64Data);
        print('✅ [API_SERVICE] Data URL converted to bytes successfully');
        return bytes;
      } else if (imagePath.startsWith('blob:')) {
        print('🔄 [API_SERVICE] Converting blob URL to bytes...');
        
        if (kIsWeb) {
          // For web, fetch the blob data
          final response = await http.get(Uri.parse(imagePath));
          if (response.statusCode == 200) {
            final bytes = response.bodyBytes;
            print('✅ [API_SERVICE] Blob converted to bytes successfully (${bytes.length} bytes)');
            return bytes;
          } else {
            throw Exception('Failed to fetch blob: ${response.statusCode}');
          }
        } else {
          throw Exception('Blob URLs not supported on this platform');
        }
      } else {
        throw Exception('Unsupported image format: $imagePath');
      }
    } catch (e) {
      print('💥 [API_SERVICE] Error converting image to bytes: $e');
      rethrow;
    }
  }

  // Helper method to determine MIME type from image bytes
  static String _getMimeTypeFromBytes(List<int> bytes) {
    if (bytes.length >= 2) {
      // Check for JPEG
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
        return 'image/jpeg';
      }
      // Check for PNG
      if (bytes.length >= 4 && 
          bytes[0] == 0x89 && bytes[1] == 0x50 && 
          bytes[2] == 0x4E && bytes[3] == 0x47) {
        return 'image/png';
      }
      // Check for GIF
      if (bytes.length >= 3 && 
          bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
        return 'image/gif';
      }
      // Check for WebP
      if (bytes.length >= 12 && 
          bytes[0] == 0x52 && bytes[1] == 0x49 && 
          bytes[2] == 0x46 && bytes[3] == 0x46 &&
          bytes[8] == 0x57 && bytes[9] == 0x45 && 
          bytes[10] == 0x42 && bytes[11] == 0x50) {
        return 'image/webp';
      }
    }
    // Default to JPEG if we can't determine
    return 'image/jpeg';
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
        print('❌ [API_SERVICE] No auth token found');
        return {'success': false, 'error': 'Authentication required'};
      }

      print('🏢 [API_SERVICE] Registering business vendor (unified)...');
      print('🌐 [API_SERVICE] Endpoint: $registerBusinessVendorEndpoint');
      print('📊 [API_SERVICE] Business Name: $name');
      print('📊 [API_SERVICE] Description: $description');
      print('📊 [API_SERVICE] Full Name: $fullName');
      print('📊 [API_SERVICE] Email: $email');
      print('📊 [API_SERVICE] Phone: $phoneNumber');
      print('📊 [API_SERVICE] Categories: $categoryIds');
      print('📊 [API_SERVICE] Payment Method Type: $paymentMethodType');
      print('📊 [API_SERVICE] Account Holder: $accountHolderName');
      print('📊 [API_SERVICE] Subscription ID: $subscriptionId');

      print('🔑 [API_SERVICE] Auth token found: ${token.substring(0, 20)}...');

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
      if (kIsWeb) {
        print('📱 [API_SERVICE] Web platform detected');
        print('🖼️ [API_SERVICE] Cover image path: $coverImagePath');
        print('📄 [API_SERVICE] License image path: $businessLicenseImagePath');
        
        try {
          // Convert blob URLs to bytes and add as files
          print('🖼️ [API_SERVICE] Processing cover image...');
          final coverImageBytes = await _convertImageToBytes(coverImagePath);
          request.files.add(http.MultipartFile.fromBytes(
            'cover_image',
            coverImageBytes,
            filename: 'cover_image.jpg',
          ));
          print('✅ [API_SERVICE] Cover image processed successfully');
          
          print('📄 [API_SERVICE] Processing license image...');
          final licenseImageBytes = await _convertImageToBytes(businessLicenseImagePath);
          request.files.add(http.MultipartFile.fromBytes(
            'business_license_image',
            licenseImageBytes,
            filename: 'business_license.jpg',
          ));
          print('✅ [API_SERVICE] License image processed successfully');
          
        } catch (e) {
          print('💥 [API_SERVICE] Error processing web images: $e');
          throw Exception('Failed to process images: $e');
        }
      } else {
        // Mobile/Desktop platform: Use file path
        print('📱 [API_SERVICE] Mobile platform detected - using file path for upload');
        print('🖼️ [API_SERVICE] Cover image path: $coverImagePath');
        print('📄 [API_SERVICE] License image path: $businessLicenseImagePath');
        
        try {
          request.files.add(await http.MultipartFile.fromPath(
            'cover_image',
            coverImagePath,
          ));
          
          request.files.add(await http.MultipartFile.fromPath(
            'business_license_image',
            businessLicenseImagePath,
          ));
          print('✅ [API_SERVICE] Mobile files added successfully');
        } catch (e) {
          print('💥 [API_SERVICE] Error processing mobile files: $e');
          throw Exception('Failed to process files: $e');
        }
      }

      print('📦 [API_SERVICE] Total files attached: ${request.files.length}');
      
      print('⏳ [API_SERVICE] Sending unified registration request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [API_SERVICE] Business vendor registered successfully!');
        print('🏢 [API_SERVICE] Vendor data: ${data['vendor'] ?? data}');
        return {
          'success': true,
          'vendor': data['vendor'] ?? data,
          'payment': data['payment'],
          'message': data['message'] ?? 'Business vendor registered successfully'
        };
      } else {
        print('❌ [API_SERVICE] Failed to register business vendor');
        print('❌ [API_SERVICE] Status code: ${response.statusCode}');
        final error = (data is Map && data.containsKey('error'))
            ? data['error']
            : (data is Map && data.containsKey('message'))
                ? data['message']
                : 'Failed to register business vendor (Status: ${response.statusCode})';
        print('❌ [API_SERVICE] Error message: $error');
        return {'success': false, 'error': error};
      }
    } catch (e, stackTrace) {
      print('💥 [API_SERVICE] Exception registering business vendor: $e');
      print('💥 [API_SERVICE] Stack trace: $stackTrace');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Create Vendor Registration Payment
  static Future<Map<String, dynamic>> createVendorRegistrationPayment({
    required int subscriptionId,
    required String paymentMethod, // 'bank' or 'mobile_wallet'
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      print('💳 [API_SERVICE] Creating vendor registration payment...');
      print('🌐 [API_SERVICE] Endpoint: $baseUrl/vendor-registration/payment');
      print('📊 [API_SERVICE] Subscription ID: $subscriptionId');
      print('📊 [API_SERVICE] Payment Method: $paymentMethod');
      print('📊 [API_SERVICE] Payment Details: $paymentDetails');
      
      final token = await getToken();
      if (token == null) {
        print('❌ [API_SERVICE] No auth token found');
        return {'success': false, 'error': 'Authentication required'};
      }
      
      print('🔑 [API_SERVICE] Auth token found: ${token.substring(0, 20)}...');
      
      final uri = Uri.parse('$baseUrl/vendor-registration/payment');
      print('🔗 [API_SERVICE] Parsed URI: $uri');
      
      final requestBody = {
        'subscription_id': subscriptionId,
        'payment_method': paymentMethod,
        if (paymentDetails != null) 'payment_details': paymentDetails,
      };
      
      print('📝 [API_SERVICE] Request body: $requestBody');
      
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      
      print('📥 [API_SERVICE] Payment creation response received!');
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
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [API_SERVICE] Payment created successfully!');
        print('💳 [API_SERVICE] Payment data: ${data['payment'] ?? data}');
        return {
          'success': true,
          'payment': data['payment'] ?? data,
          'payment_id': data['payment']?['id'] ?? data['id'],
          'message': data['message'] ?? 'Payment created successfully'
        };
      } else {
        print('❌ [API_SERVICE] Failed to create payment');
        print('❌ [API_SERVICE] Status code: ${response.statusCode}');
        final error = (data is Map && data.containsKey('error'))
            ? data['error']
            : (data is Map && data.containsKey('message'))
                ? data['message']
                : 'Failed to create payment (Status: ${response.statusCode})';
        print('❌ [API_SERVICE] Error message: $error');
        return {'success': false, 'error': error};
      }
    } catch (e, stackTrace) {
      print('💥 [API_SERVICE] Exception creating payment: $e');
      print('💥 [API_SERVICE] Stack trace: $stackTrace');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }
}
