class ValidationUtils {
  // Email validation
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password validation
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;
    
    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    
    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    
    // Check for at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    
    return true;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  // Ethiopian address validation
  static bool isEthiopianAddress({
    String? country,
    String? region,
    String? city,
  }) {
    // Check if country is Ethiopia
    if (country != null && country.isNotEmpty) {
      final normalizedCountry = country.toLowerCase().trim();
      if (normalizedCountry != 'ethiopia' && normalizedCountry != 'eth') {
        return false;
      }
    }
    
    // Check for Ethiopian regions
    if (region != null && region.isNotEmpty) {
      final ethiopianRegions = [
        'addis ababa',
        'afar',
        'amhara',
        'benishangul-gumuz',
        'dire dawa',
        'gambela',
        'harari',
        'oromia',
        'sidama',
        'somali',
        'southern nations, nationalities, and peoples',
        'snnp',
        'tigray',
      ];
      
      final normalizedRegion = region.toLowerCase().trim();
      if (!ethiopianRegions.any((r) => normalizedRegion.contains(r) || r.contains(normalizedRegion))) {
        return false;
      }
    }
    
    // Check for Ethiopian cities (major ones)
    if (city != null && city.isNotEmpty) {
      final ethiopianCities = [
        'addis ababa',
        'dire dawa',
        'mekelle',
        'gondar',
        'adama',
        'nazret',
        'hawassa',
        'bahir dar',
        'dessie',
        'jimma',
        'jijiga',
        'shashamane',
        'arba minch',
        'hosaena',
        'harar',
        'debre markos',
        'nekemte',
        'debre berhan',
        'asella',
        'kombolcha',
      ];
      
      final normalizedCity = city.toLowerCase().trim();
      // Allow if city matches any Ethiopian city or if no specific city validation needed
      return ethiopianCities.any((c) => normalizedCity.contains(c) || c.contains(normalizedCity));
    }
    
    return true; // Default to valid if no specific checks fail
  }

  static String? validateEthiopianAddress({
    String? country,
    String? region,
    String? city,
    String? addressLine1,
  }) {
    if (addressLine1 == null || addressLine1.isEmpty) {
      return 'Address Line 1 is required';
    }
    
    if (country != null && country.isNotEmpty) {
      final normalizedCountry = country.toLowerCase().trim();
      if (normalizedCountry != 'ethiopia' && normalizedCountry != 'eth' && normalizedCountry != '') {
        return 'Only Ethiopian addresses are supported';
      }
    }
    
    if (!isEthiopianAddress(country: country, region: region, city: city)) {
      return 'Please enter a valid Ethiopian address';
    }
    
    return null;
  }

  // Phone number validation (Ethiopian format)
  static bool isValidEthiopianPhone(String phone) {
    if (phone.isEmpty) return false;
    
    // Remove spaces, dashes, and plus signs
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\+]'), '');
    
    // Ethiopian phone patterns:
    // - Starting with 251 (country code): 251912345678
    // - Starting with 0: 0912345678
    // - Without prefix: 912345678
    final ethiopianPhoneRegex = RegExp(r'^(251|0)?[79]\d{8}$');
    
    return ethiopianPhoneRegex.hasMatch(cleanPhone);
  }

  static String? validateEthiopianPhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }
    
    if (!isValidEthiopianPhone(phone)) {
      return 'Please enter a valid Ethiopian phone number (e.g., 0912345678)';
    }
    
    return null;
  }

  // Full name validation
  static String? validateFullName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Full name is required';
    }
    
    if (name.trim().length < 2) {
      return 'Full name must be at least 2 characters long';
    }
    
    // Check if name contains at least one space (first + last name)
    if (!name.trim().contains(' ')) {
      return 'Please enter your full name (first and last name)';
    }
    
    return null;
  }

  // Business name validation
  static String? validateBusinessName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Business name is required';
    }
    
    if (name.trim().length < 2) {
      return 'Business name must be at least 2 characters long';
    }
    
    return null;
  }

  // Business description validation
  static String? validateBusinessDescription(String? description) {
    if (description == null || description.isEmpty) {
      return 'Business description is required';
    }
    
    if (description.trim().length < 10) {
      return 'Business description must be at least 10 characters long';
    }
    
    return null;
  }
}
