import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/theme_provider.dart';
import '../../../shared/theme/app_themes.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/widgets/language_selector/language_switcher_button.dart';
import '../../../core/services/api_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  bool _setAsDefault = false;
  String? _userPhoneNumber;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'type': 'bank',
      'name': 'CBE Bank',
      'detail': 'Bank Account ending in 1234',
      'status': 'Verified',
      'isVerified': true,
    },
    {
      'type': 'mobile',
      'name': 'Telebirr',
      'detail': '+251 90*****78',
      'status': 'Active',
      'isVerified': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserPhoneNumber();
  }

  Future<void> _loadUserPhoneNumber() async {
    final userData = await ApiService.getUserData();
    if (userData != null && userData['phone_number'] != null) {
      setState(() {
        _userPhoneNumber = userData['phone_number'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'paymentMethods.title'.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ..._paymentMethods.map((method) => _buildPaymentMethodCard(method)).toList(),
            const SizedBox(height: 24),
            _buildSetAsDefaultToggle(),
            const SizedBox(height: 24),
            _buildAddPaymentButton(),
            const SizedBox(height: 16),
            _buildAddPaymentDescription(),
            const SizedBox(height: 32),
            _buildAddPaymentMethodSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  method['type'] == 'bank' ? Icons.account_balance : Icons.phone_android,
                  color: Colors.grey[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: method['isVerified'] 
                                ? AppTheme.successColor.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            method['status'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: method['isVerified'] 
                                  ? AppTheme.successColor
                                  : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method['detail'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue[600]!, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red[600]!, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[600],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetAsDefaultToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'paymentMethods.setDefault'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Switch(
            value: _setAsDefault,
            onChanged: (value) {
              setState(() {
                _setAsDefault = value;
              });
            },
            activeColor: AppTheme.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAddPaymentButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _showAddPaymentMethodDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            'paymentMethods.add'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddPaymentDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'paymentMethods.addDesc'.tr(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildAddPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'paymentMethods.add'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildPaymentOption(
          icon: Icons.account_balance,
          title: 'paymentMethods.bankTransfer'.tr(),
          onTap: () => _showAddPaymentMethodDialog(),
        ),
        _buildPaymentOption(
          icon: Icons.phone_android,
          title: 'paymentMethods.mobileWallet'.tr(),
          onTap: () => _showAddPaymentMethodDialog(),
        ),
        _buildPaymentOption(
          icon: Icons.credit_card,
          title: 'paymentMethods.debitCreditCard'.tr(),
          onTap: () => _showAddPaymentMethodDialog(),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.black87, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddPaymentMethodDialog(
        userPhoneNumber: _userPhoneNumber,
      ),
    );
  }
}

class _AddPaymentMethodDialog extends StatefulWidget {
  final String? userPhoneNumber;

  const _AddPaymentMethodDialog({
    required this.userPhoneNumber,
  });

  @override
  State<_AddPaymentMethodDialog> createState() => _AddPaymentMethodDialogState();
}

class _AddPaymentMethodDialogState extends State<_AddPaymentMethodDialog> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _accountHolderController = TextEditingController();
  String _selectedPaymentMethod = 'telebirr';
  bool _useRegistrationPhone = false;

  @override
  void initState() {
    super.initState();
    if (widget.userPhoneNumber != null) {
      _phoneController.text = widget.userPhoneNumber!;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('paymentMethods.dialogTitle'.tr()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Method Selection
            Text(
              'paymentMethods.methodLabel'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            // Telebirr Option
            _buildPaymentMethodOption(
              'telebirr',
              'paymentMethods.telebirr'.tr(),
              Icons.phone_android,
              const Color(0xFF1976D2),
            ),
            const SizedBox(height: 8),
            
            // CBE Birr Option
            _buildPaymentMethodOption(
              'cbe_birr',
              'paymentMethods.cbeBirr'.tr(),
              Icons.account_balance,
              const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 8),
            
            // Bank Account Option
            _buildPaymentMethodOption(
              'bank_account',
              'paymentMethods.bankAccount'.tr(),
              Icons.account_balance_wallet,
              const Color(0xFF7B1FA2),
            ),
            
            const SizedBox(height: 20),
            
            // Account Holder Name
            Text(
              'paymentMethods.accountHolderName'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _accountHolderController,
              decoration: InputDecoration(
                hintText: 'paymentMethods.accountHolderNameHint'.tr(),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Phone Number Section (for mobile wallets)
            if (_selectedPaymentMethod == 'telebirr' || _selectedPaymentMethod == 'cbe_birr') ...[
              Text(
                'paymentMethods.phoneNumber'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              
              // Use Registration Phone Toggle
              if (widget.userPhoneNumber != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.successColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.successColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'paymentMethods.useRegistrationPhone'.tr(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.successColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'paymentMethods.useRegistrationPhoneDesc'.tr(),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.successColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _useRegistrationPhone,
                        onChanged: (value) {
                          setState(() {
                            _useRegistrationPhone = value;
                            if (value) {
                              _phoneController.text = widget.userPhoneNumber!;
                            } else {
                              _phoneController.clear();
                            }
                          });
                        },
                        activeColor: AppTheme.successColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Phone Number Input with +251 constant
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    // +251 constant prefix
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12, right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24,
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Image.network(
                                'https://flagcdn.com/w40/et.png',
                                width: 24,
                                height: 16,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'ET',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '+251',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Divider
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                    // Phone number input
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        enabled: !_useRegistrationPhone,
                        keyboardType: TextInputType.number,
                        maxLength: 9,
                    decoration: InputDecoration(
                      hintText: 'onboarding.phoneNumber.phoneHint'.tr(),
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Bank Account Number (for bank account)
            if (_selectedPaymentMethod == 'bank_account') ...[
              Text(
                'paymentMethods.bankAccountNumber'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'paymentMethods.bankAccountNumberHint'.tr(),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('paymentMethods.cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement save payment method logic
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('paymentMethods.addSuccess'.tr()),
                backgroundColor: AppTheme.successColor,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successColor,
          ),
          child: Text(
            'paymentMethods.confirmAdd'.tr(),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption(
    String method,
    String title,
    IconData icon,
    Color color,
  ) {
    final bool isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? color : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
