import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class LocalizationService extends ChangeNotifier {
  static LocalizationService? _instance;
  static LocalizationService get instance => _instance ??= LocalizationService._();
  
  LocalizationService._();
  
  Map<String, dynamic> _localizedStrings = {};
  String _currentLanguage = 'en';
  
  String get currentLanguage => _currentLanguage;
  
  Future<void> loadLanguage(String languageCode) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/localization/$languageCode.json');
      _localizedStrings = json.decode(jsonString);
      _currentLanguage = languageCode;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language $languageCode: $e');
      // Fallback to English if loading fails
      if (languageCode != 'en') {
        await loadLanguage('en');
      }
    }
  }
  
  String translate(String key, {Map<String, dynamic>? params}) {
    final keys = key.split('.');
    dynamic value = _localizedStrings;
    
    for (final k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        debugPrint('Translation key not found: $key');
        return key; // Return the key itself if translation not found
      }
    }
    
    if (value is String) {
      String result = value;
      
      // Replace parameters if provided
      if (params != null) {
        params.forEach((key, value) {
          result = result.replaceAll('{$key}', value.toString());
        });
      }
      
      return result;
    }
    
    debugPrint('Translation value is not a string: $key');
    return key;
  }
  
  // Convenience method for common translations
  String get(String key, {Map<String, dynamic>? params}) => translate(key, params: params);
  
  // Get supported languages
  List<Map<String, String>> get supportedLanguages => [
    {'code': 'en', 'name': get('languages.en')},
    {'code': 'am', 'name': get('languages.am')},
    {'code': 'om', 'name': get('languages.om')},
  ];
}

// Extension for easy access
extension LocalizationExtension on String {
  String tr({Map<String, dynamic>? params}) => LocalizationService.instance.translate(this, params: params);
}

// Widget for easy localization
class LocalizedText extends StatelessWidget {
  final String translationKey;
  final Map<String, dynamic>? params;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  
  const LocalizedText(
    this.translationKey, {
    super.key,
    this.params,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });
  
  @override
  Widget build(BuildContext context) {
    return Text(
      LocalizationService.instance.translate(translationKey, params: params),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
