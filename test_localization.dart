import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Test loading English localization
    final String jsonString = await rootBundle.loadString('assets/localization/en.json');
    final Map<String, dynamic> localizedStrings = json.decode(jsonString);
    
    print('✅ Successfully loaded English localization');
    print('📊 Total keys: ${localizedStrings.length}');
    
    // Test addresses section
    if (localizedStrings.containsKey('onboarding') && 
        localizedStrings['onboarding'] is Map &&
        (localizedStrings['onboarding'] as Map).containsKey('addresses')) {
      final addresses = (localizedStrings['onboarding'] as Map)['addresses'] as Map;
      print('✅ Addresses section found with ${addresses.length} keys');
      print('📝 Sample keys:');
      addresses.forEach((key, value) {
        print('  - $key: $value');
      });
    } else {
      print('❌ Addresses section not found in onboarding');
    }
    
    // Test Amharic localization
    final String amJsonString = await rootBundle.loadString('assets/localization/am.json');
    final Map<String, dynamic> amLocalizedStrings = json.decode(amJsonString);
    print('✅ Successfully loaded Amharic localization');
    print('📊 Total keys: ${amLocalizedStrings.length}');
    
  } catch (e) {
    print('❌ Error loading localization: $e');
  }
}
