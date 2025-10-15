import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Backend API URL
  // Note: For Android Emulator, use 10.0.2.2 instead of localhost
  // For iOS Simulator, localhost works fine
  // For real device on same network, use your computer's IP address
  static const String baseUrl = 'http://localhost:4000/api/auth';
  
  // Auth endpoints
  static const String loginEndpoint = '$baseUrl/login';
  static const String registerClientEndpoint = '$baseUrl/register-client';
  static const String registerVendorOwnerEndpoint = '$baseUrl/register-vendor-owner';
  static const String verifyOtpEndpoint = '$baseUrl/verify-otp';
  static const String resendOtpEndpoint = '$baseUrl/resend-otp';
  static const String forgotPasswordEndpoint = '$baseUrl/forgot-password';
  static const String verifyResetOtpEndpoint = '$baseUrl/verify-reset-otp';
  static const String resetPasswordEndpoint = '$baseUrl/reset-password';
  static const String meEndpoint = '$baseUrl/me';

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

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Registration failed'};
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
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Registration failed'};
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
}
