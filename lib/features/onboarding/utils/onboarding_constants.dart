import 'package:flutter/material.dart';

class OnboardingConstants {
  // Colors
  static const Color primaryGreen = Color(0xFF22C55E);
  static const Color darkGreen = Color(0xFF16A34A);
  static const Color lightGreen = Color(0xFFBBF7D0);
  static const Color successGreen = Color(0xFF10B981);
  static const Color textDark = Color(0xFF111827);
  static const Color textGray = Color(0xFF6B7280);
  static const Color borderGray = Color(0xFFD1D5DB);
  static const Color backgroundGray = Color(0xFFF9FAFB);

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 600);
  static const Duration elasticAnimation = Duration(milliseconds: 800);

  // Border Radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double pillRadius = 100.0;

  // Spacing
  static const double tinySpace = 4.0;
  static const double smallSpace = 8.0;
  static const double mediumSpace = 16.0;
  static const double largeSpace = 24.0;
  static const double extraLargeSpace = 32.0;

  // Categories
  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'Electronics',
      'icon': Icons.devices,
      'color': Color(0xFF6366F1)
    },
    {
      'name': 'Fashion',
      'icon': Icons.checkroom,
      'color': Color(0xFFEC4899)
    },
    {
      'name': 'Food & Beverage',
      'icon': Icons.restaurant,
      'color': Color(0xFFF59E0B)
    },
    {
      'name': 'Beauty & Health',
      'icon': Icons.spa,
      'color': Color(0xFF8B5CF6)
    },
    {
      'name': 'Home & Garden',
      'icon': Icons.home,
      'color': Color(0xFF10B981)
    },
    {
      'name': 'Sports & Outdoor',
      'icon': Icons.sports_soccer,
      'color': Color(0xFF3B82F6)
    },
    {
      'name': 'Books & Media',
      'icon': Icons.menu_book,
      'color': Color(0xFFF97316)
    },
    {'name': 'Toys & Kids', 'icon': Icons.toys, 'color': Color(0xFFEF4444)},
  ];

  // Terms and Conditions Content
  static const String termsTitle = 'Zareshop Payout Terms';
  
  static const List<Map<String, String>> termsContent = [
    {
      'title': 'Payment Processing',
      'content':
          'Zareshop will process your payouts according to the selected payment method. Payouts are typically processed within 2-5 business days.',
    },
    {
      'title': 'Fees and Charges',
      'content':
          'A standard processing fee of 2.5% applies to all transactions. Additional fees may apply based on your payment method.',
    },
    {
      'title': 'Verification',
      'content':
          'Payment details must be verified before payouts can be processed. Please ensure all information is accurate.',
    },
  ];
}
