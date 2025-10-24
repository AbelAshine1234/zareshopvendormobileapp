import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chapasdk/chapasdk.dart';
import '../../../shared/shared.dart';
import 'add_funds_dialog.dart';
import 'chapa_checkout_dialog.dart';

enum PaymentService {
  cbe,
  chapa,
}

class PaymentServiceSelectionDialog extends StatelessWidget {
  final double currentBalance;

  const PaymentServiceSelectionDialog({
    super.key,
    required this.currentBalance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;

    return Dialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.payment,
                    color: theme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Payment Service',
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose how you want to add funds',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: theme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Current Balance Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: theme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Current Balance: ${currentBalance.toStringAsFixed(2)} Br',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Service Options
            Text(
              'Payment Services',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // CBE Option
            _buildPaymentServiceOption(
              theme: theme,
              service: PaymentService.cbe,
              title: 'Commercial Bank of Ethiopia (CBE)',
              subtitle: 'Bank transfer via CBE mobile banking',
              icon: Icons.account_balance,
              isAvailable: false,
              onTap: () => _showComingSoonMessage(context, theme, 'CBE'),
            ),
            const SizedBox(height: 12),

            // Chapa Option
            _buildPaymentServiceOption(
              theme: theme,
              service: PaymentService.chapa,
              title: 'Chapa Payment',
              subtitle: 'Pay with mobile money, cards & bank transfer',
              icon: Icons.credit_card,
              isAvailable: true,
              onTap: () => _openChapaCheckout(context),
            ),
            const SizedBox(height: 24),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Funds will be added to your wallet after successful payment',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentServiceOption({
    required AppThemeData theme,
    required PaymentService service,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isAvailable,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isAvailable 
                ? theme.primary.withValues(alpha: 0.3)
                : theme.textSecondary.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
          color: isAvailable 
              ? theme.primary.withValues(alpha: 0.05)
              : theme.textSecondary.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAvailable 
                    ? theme.primary.withValues(alpha: 0.1)
                    : theme.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isAvailable ? theme.primary : theme.textSecondary,
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
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isAvailable ? theme.textPrimary : theme.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.textSecondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Coming Soon',
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isAvailable ? theme.primary : theme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonMessage(BuildContext context, AppThemeData theme, String service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$service payment integration is coming soon!'),
        backgroundColor: theme.textSecondary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openChapaCheckout(BuildContext context) {
    Navigator.of(context).pop(); // Close service selection dialog
    _startChapaPayment(context);
  }

  Future<void> _startChapaPayment(BuildContext context) async {
    try {
      // Generate unique transaction reference
      final txRef = 'zareshop_${DateTime.now().millisecondsSinceEpoch}';
      
      print('🔄 Opening Chapa payment page...');
      print('   Transaction Reference: $txRef');
      
      // Open Chapa payment page directly - user enters amount there
      await Chapa.paymentParameters(
        context: context,
        publicKey: 'CHAPUBK_TEST-LUXcfuTl4WlCCWX3vOHKb3lx57Rz3KTa',
        currency: 'ETB',
        amount: '0', // Let user enter amount on Chapa's page
        email: 'vendor@zareshop.com',
        phone: '0911234567',
        firstName: 'Zareshop',
        lastName: 'Vendor',
        txRef: txRef,
        title: 'ZareShop Wallet Top-up',
        desc: 'Add funds to your ZareShop vendor wallet',
        nativeCheckout: true,
        namedRouteFallBack: '/',
        showPaymentMethodsOnGridView: true,
        availablePaymentMethods: ['telebirr', 'cbebirr', 'mpesa', 'ebirr'],
      );
      
      // If payment completes without error, add funds
      print('✅ Chapa payment completed successfully');
      _handlePaymentSuccess(context);
      
    } catch (e) {
      print('❌ Chapa Payment Error: $e');
      _handlePaymentFailure(context);
    }
  }

  void _handlePaymentSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful! Funds will be added to your wallet.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _handlePaymentFailure(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment was cancelled or failed. Please try again.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
