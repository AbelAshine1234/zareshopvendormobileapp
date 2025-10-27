import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _vendorDataKey = 'vendor_data';

  // Token management
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_tokenKey, token);
    } catch (e) {
      print('Error saving token: $e');
      return false;
    }
  }

  Future<bool> removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_tokenKey);
    } catch (e) {
      print('Error removing token: $e');
      return false;
    }
  }

  // User data management
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);
      if (userDataString != null) {
        return Map<String, dynamic>.from(
          Map<String, dynamic>.from(
            // This would need proper JSON decoding in a real implementation
            // For now, returning empty map as placeholder
            <String, dynamic>{}
          )
        );
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // In a real implementation, you'd JSON encode the userData
      // For now, just saving a placeholder
      return await prefs.setString(_userDataKey, 'user_data_placeholder');
    } catch (e) {
      print('Error saving user data: $e');
      return false;
    }
  }

  Future<bool> removeUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_userDataKey);
    } catch (e) {
      print('Error removing user data: $e');
      return false;
    }
  }

  // Vendor data management
  Future<Map<String, dynamic>?> getVendorData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorDataString = prefs.getString(_vendorDataKey);
      if (vendorDataString != null) {
        return Map<String, dynamic>.from(
          Map<String, dynamic>.from(
            // This would need proper JSON decoding in a real implementation
            // For now, returning empty map as placeholder
            <String, dynamic>{}
          )
        );
      }
      return null;
    } catch (e) {
      print('Error getting vendor data: $e');
      return null;
    }
  }

  Future<bool> saveVendorData(Map<String, dynamic> vendorData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // In a real implementation, you'd JSON encode the vendorData
      // For now, just saving a placeholder
      return await prefs.setString(_vendorDataKey, 'vendor_data_placeholder');
    } catch (e) {
      print('Error saving vendor data: $e');
      return false;
    }
  }

  Future<bool> removeVendorData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_vendorDataKey);
    } catch (e) {
      print('Error removing vendor data: $e');
      return false;
    }
  }

  // Clear all data
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_vendorDataKey);
      return true;
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
