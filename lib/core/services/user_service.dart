import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _userDataKey = 'user_data';
  static const String _phoneNumberKey = 'user_phone_number';
  
  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._();
  
  UserService._();
  
  String? _phoneNumber;
  Map<String, dynamic>? _userData;
  
  // Get current phone number
  String? get phoneNumber => _phoneNumber;
  
  // Get current user data
  Map<String, dynamic>? get userData => _userData;
  
  // Set phone number
  Future<void> setPhoneNumber(String phoneNumber) async {
    _phoneNumber = phoneNumber;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneNumberKey, phoneNumber);
  }
  
  // Get phone number from storage
  Future<String?> getPhoneNumber() async {
    if (_phoneNumber != null) {
      return _phoneNumber;
    }
    
    final prefs = await SharedPreferences.getInstance();
    _phoneNumber = prefs.getString(_phoneNumberKey);
    return _phoneNumber;
  }
  
  // Set user data
  Future<void> setUserData(Map<String, dynamic> userData) async {
    _userData = userData;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, userData.toString()); // In real app, use JSON encoding
  }
  
  // Get user data from storage
  Future<Map<String, dynamic>?> getUserData() async {
    if (_userData != null) return _userData;
    
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      // In real app, use JSON decoding
      _userData = <String, dynamic>{};
    }
    return _userData;
  }
  
  // Clear all user data
  Future<void> clearUserData() async {
    _phoneNumber = null;
    _userData = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneNumberKey);
    await prefs.remove(_userDataKey);
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final phone = await getPhoneNumber();
    return phone != null && phone.isNotEmpty;
  }
}
