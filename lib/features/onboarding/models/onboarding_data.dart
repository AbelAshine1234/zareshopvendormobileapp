import 'package:equatable/equatable.dart';

/// Model to hold all onboarding data
class OnboardingData extends Equatable {
  final String fullName;
  final bool? sellsProductsOnline;
  final String? monthlyRevenue;
  final String emailAddress;

  const OnboardingData({
    this.fullName = '',
    this.sellsProductsOnline,
    this.monthlyRevenue,
    this.emailAddress = '',
  });

  OnboardingData copyWith({
    String? fullName,
    bool? sellsProductsOnline,
    String? monthlyRevenue,
    String? emailAddress,
  }) {
    return OnboardingData(
      fullName: fullName ?? this.fullName,
      sellsProductsOnline: sellsProductsOnline ?? this.sellsProductsOnline,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      emailAddress: emailAddress ?? this.emailAddress,
    );
  }

  bool isStepCompleted(int step) {
    switch (step) {
      case 0:
        return fullName.isNotEmpty;
      case 1:
        return sellsProductsOnline != null;
      case 2:
        return monthlyRevenue != null && monthlyRevenue!.isNotEmpty;
      case 3:
        return emailAddress.isNotEmpty && _isValidEmail(emailAddress);
      default:
        return false;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  List<Object?> get props => [
        fullName,
        sellsProductsOnline,
        monthlyRevenue,
        emailAddress,
      ];
}

/// Revenue options for monthly revenue selection
class RevenueOption {
  final String label;
  final String value;

  const RevenueOption(this.label, this.value);

  static const List<RevenueOption> options = [
    RevenueOption('Less than \$1,000', 'less_1k'),
    RevenueOption('\$1,000 - \$5,000', '1k_5k'),
    RevenueOption('\$5,000 - \$10,000', '5k_10k'),
    RevenueOption('\$10,000 - \$50,000', '10k_50k'),
    RevenueOption('More than \$50,000', 'more_50k'),
  ];
}
