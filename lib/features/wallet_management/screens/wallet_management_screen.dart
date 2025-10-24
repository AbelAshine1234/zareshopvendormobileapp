import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../shared/shared.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../models/cashout_request.dart';
import '../widgets/widgets.dart';
import '../widgets/transaction_detail_bottom_sheet.dart';

class WalletManagementScreen extends StatefulWidget {
  final bool isVendor;

  const WalletManagementScreen({
    Key? key,
    this.isVendor = true,
  }) : super(key: key);

  @override
  State<WalletManagementScreen> createState() => _WalletManagementScreenState();
}

class _WalletManagementScreenState extends State<WalletManagementScreen> {
  bool _isBalanceVisible = true;

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    if (mounted) {
      // Bloc will get vendor ID from user data automatically
      context.read<WalletBloc>().add(
        FetchWalletBalance(
          isVendor: widget.isVendor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;

        return Scaffold(
          backgroundColor: theme.background,
          appBar: AppBar(
            backgroundColor: theme.surface,
            elevation: 0,
            title: Text(
              'Wallet',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: IconThemeData(color: theme.textPrimary),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceSection(theme),
                  const SizedBox(height: 24),
                  _buildActionButtons(theme),
                  const SizedBox(height: 32),
                  _buildActiveCardsSection(theme),
                  const SizedBox(height: 32),
                  _buildRecentTransactionsSection(theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Cache the last known balance to show during intermediate states
  double? _lastKnownBalance;

  Widget _buildBalanceSection(AppThemeData theme) {
    return BlocBuilder<WalletBloc, WalletState>(
      buildWhen: (previous, current) {
        print('🔄 [WalletScreen._buildBalanceSection.buildWhen] Previous: ${previous.runtimeType}, Current: ${current.runtimeType}');
        
        // Don't rebuild for intermediate states like CashoutRequestCreated, CashoutStatusUpdated, FundsAddedSuccess, PaymentMethod states
        if (current is CashoutRequestCreated || 
            current is CashoutStatusUpdated || 
            current is FundsAddedSuccess ||
            current is WalletFundsAddedReceived ||
            current is WalletFundsDeductedReceived ||
            current is PaymentMethodCreated ||
            current is PaymentMethodDeleted ||
            current is PaymentMethodsLoaded) {
          print('   ⏭️ Skipping rebuild for intermediate state: ${current.runtimeType}');
          return false;
        }
        
        // Always rebuild for these states
        if (current is WalletLoading || current is WalletError || current is WalletInitial) {
          print('   ✅ Rebuilding for: ${current.runtimeType}');
          return true;
        }
        
        // Rebuild if balance changed
        if (previous is WalletBalanceLoaded && current is WalletBalanceLoaded) {
          final balanceChanged = previous.walletData.balance != current.walletData.balance;
          print('   Balance: ${previous.walletData.balance} → ${current.walletData.balance}');
          print('   ${balanceChanged ? "✅ Balance changed - rebuilding" : "⚠️ Balance same - skipping rebuild"}');
          return balanceChanged;
        }
        
        print('   ✅ Different state types - rebuilding');
        return true;
      },
      builder: (context, state) {
        print('💰 [WalletScreen._buildBalanceSection.builder] State: ${state.runtimeType}');
        
        String balanceText = '••••••';
        String currencySymbol = 'Br';

        if (state is WalletBalanceLoaded) {
          final balance = state.walletData.balance;
          _lastKnownBalance = balance; // Cache the balance
          print('💰 [WalletScreen._buildBalanceSection.builder] Balance: $balance Br (cached)');
          balanceText = _isBalanceVisible 
              ? '$currencySymbol${balance.toStringAsFixed(2)}' 
              : '••••••';
        } else if (state is WalletLoading) {
          print('🔄 [WalletScreen._buildBalanceSection.builder] Loading...');
          // Show last known balance during loading if available
          if (_lastKnownBalance != null && _isBalanceVisible) {
            balanceText = '$currencySymbol${_lastKnownBalance!.toStringAsFixed(2)}';
            print('   Using cached balance: $balanceText');
          } else {
            balanceText = 'Loading...';
          }
        } else if (state is WalletError) {
          print('❌ [WalletScreen._buildBalanceSection.builder] Error: ${state.message}');
          balanceText = 'Error';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Total Balance',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isBalanceVisible = !_isBalanceVisible;
                    });
                  },
                  child: Icon(
                    _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                    color: theme.textSecondary,
                    size: 20,
                  ),
                ),
                if (state is WalletBalanceLoaded) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: _loadWalletBalance,
                    child: Icon(
                      Icons.refresh,
                      color: theme.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if (state is WalletLoading)
              SizedBox(
                height: 48,
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.primary,
                  ),
                ),
              )
            else if (state is WalletError)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error loading balance',
                    style: TextStyle(
                      color: theme.error,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _loadWalletBalance,
                    icon: Icon(Icons.refresh, color: theme.primary),
                    label: Text(
                      'Retry',
                      style: TextStyle(color: theme.primary),
                    ),
                  ),
                ],
              )
            else
              Text(
                balanceText,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        );
      },
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'ETB':
        return 'Br';
      default:
        return currency;
    }
  }

  Widget _buildActionButtons(AppThemeData theme) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        double currentBalance = 0.0;

        if (state is WalletBalanceLoaded) {
          currentBalance = state.walletData.balance;
        }

        return Row(
          children: [
            _buildActionButton(
              theme: theme,
              icon: Icons.add,
              label: 'Add funds',
              isPrimary: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => PaymentServiceSelectionDialog(
                    currentBalance: currentBalance,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              theme: theme,
              icon: Icons.request_quote,
              label: 'Cashout',
              isPrimary: false,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => CashoutRequestDialog(
                    currentBalance: currentBalance,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required AppThemeData theme,
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isPrimary ? theme.textPrimary : theme.surface,
                borderRadius: BorderRadius.circular(32),
                border: isPrimary
                    ? null
                    : Border.all(color: theme.divider, width: 1),
              ),
              child: Icon(
                icon,
                color: isPrimary ? theme.surface : theme.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCardsSection(AppThemeData theme) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        List<dynamic> paymentMethods = [];
        
        if (state is WalletBalanceLoaded) {
          paymentMethods = state.walletData.paymentMethods;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Methods',
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'These are the accounts we will transfer your cashout payments to',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showAddPaymentMethodDialog(context, theme),
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: theme.primary,
                    size: 28,
                  ),
                  tooltip: 'Add Payment Method',
                ),
              ],
            ),
            const SizedBox(height: 16),
            paymentMethods.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.credit_card_off,
                          size: 64,
                          color: theme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No payment methods added yet',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _showAddPaymentMethodDialog(context, theme),
                          icon: Icon(Icons.add, color: theme.primary),
                          label: Text(
                            'Add Payment Method',
                            style: TextStyle(color: theme.primary),
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: paymentMethods.map((method) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: _buildPaymentMethodCard(
                            theme: theme,
                            paymentMethod: method,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentMethodCard({
    required AppThemeData theme,
    required dynamic paymentMethod,
  }) {
    // Get payment method type icon and color
    IconData methodIcon = Icons.account_balance_wallet;
    Color cardColor = const Color(0xFFFFF4D9);
    Color iconColor = const Color(0xFFD9A441);

    if (paymentMethod.type == 'wallet') {
      methodIcon = Icons.account_balance_wallet;
      cardColor = const Color(0xFFFFF4D9);
      iconColor = const Color(0xFFD9A441);
    } else if (paymentMethod.type == 'bank') {
      methodIcon = Icons.account_balance;
      cardColor = const Color(0xFFD9F2FF);
      iconColor = const Color(0xFF3B9FD9);
    } else if (paymentMethod.type == 'card') {
      methodIcon = Icons.credit_card;
      cardColor = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF4CAF50);
    }

    return Column(
      children: [
        Container(
          width: 260,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    methodIcon,
                    color: iconColor,
                    size: 28,
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: theme.textSecondary,
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeletePaymentMethodDialog(context, theme, paymentMethod.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                paymentMethod.name ?? 'Payment Method',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                paymentMethod.accountHolder ?? '',
                style: TextStyle(
                  color: theme.textPrimary.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                paymentMethod.accountNumber ?? '',
                style: TextStyle(
                  color: theme.textPrimary.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsSection(AppThemeData theme) {
    return BlocBuilder<WalletBloc, WalletState>(
      buildWhen: (previous, current) {
        // Skip rebuilding for payment method intermediate states to keep showing cached data
        if (current is PaymentMethodCreated ||
            current is PaymentMethodDeleted ||
            current is PaymentMethodsLoaded) {
          print('⏭️ [TransactionSection] Skipping rebuild for: ${current.runtimeType}');
          return false;
        }
        return true;
      },
      builder: (context, state) {
        print('📱 [WalletScreen] Building transaction section - State: ${state.runtimeType}');
        
        if (state is WalletLoading) {
          return Center(
            child: CircularProgressIndicator(color: theme.primary),
          );
        }

        if (state is WalletError) {
          print('❌ [WalletScreen] Error state: ${state.message}');
          return Center(
            child: Text(
              'Failed to load transactions',
              style: TextStyle(color: theme.textSecondary),
            ),
          );
        }

        if (state is! WalletBalanceLoaded) {
          print('⚠️ [WalletScreen] State is not WalletBalanceLoaded: ${state.runtimeType}');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'No transactions yet',
                  style: TextStyle(color: theme.textSecondary),
                ),
              ),
            ],
          );
        }

        // Combine transactions and cashout requests
        final transactions = state.walletData.transactions;
        final cashoutRequests = state is WalletBalanceLoadedWithCashouts 
            ? state.cashoutRequests 
            : <dynamic>[];
        
        print('📋 [WalletScreen] Transactions: ${transactions.length}, Cashout requests: ${cashoutRequests.length}');
        if (state is WalletBalanceLoadedWithCashouts) {
          print('✅ [WalletScreen] Has cashout requests state');
          for (var req in cashoutRequests) {
            print('   💳 Cashout: ID=${req.id}, Amount=${req.amount}, Status=${req.status}');
          }
        } else {
          print('⚠️ [WalletScreen] No cashout requests state (just WalletBalanceLoaded)');
        }
        
        // Check if both lists are empty
        if (transactions.isEmpty && cashoutRequests.isEmpty) {
          print('⚠️ [WalletScreen] Both lists empty - showing no transactions message');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'No transactions yet',
                  style: TextStyle(color: theme.textSecondary),
                ),
              ),
            ],
          );
        }

        // Combine and sort by date (newest first), then limit to 10 items
        final allItems = [...transactions, ...cashoutRequests];
        allItems.sort((a, b) {
          final aDate = a.createdAt as DateTime;
          final bDate = b.createdAt as DateTime;
          return bDate.compareTo(aDate); // Newest first
        });
        final displayItems = allItems.take(10).toList();
        
        print('📊 [WalletScreen] Combined & sorted ${allItems.length} items, showing ${displayItems.length}');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.walletData.transactions.length > 10)
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to all transactions
                    },
                    child: Text(
                      'See all',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...displayItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTransactionItem(
                  theme: theme,
                  item: item,
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem({
    required AppThemeData theme,
    required dynamic item,
  }) {
    print('🔍 [WalletScreen._buildTransactionItem] Item type: ${item.runtimeType}');
    print('   Item toString: ${item.toString()}');
    
    // Check if item is a CashoutRequest or Transaction
    final isCashoutRequest = item.runtimeType.toString().contains('CashoutRequest');
    print('   Is cashout request: $isCashoutRequest');
    
    late final bool isCredit;
    late final Color iconColor;
    late final IconData icon;
    late final String reason;
    late final DateTime date;
    late final double amount;
    late final String? status;
    
    if (isCashoutRequest) {
      // It's a cashout request
      print('   💳 Cashout: amount=${item.amount}, status=${item.status}');
      isCredit = false;
      iconColor = const Color(0xFFF59E0B); // Orange for pending
      icon = Icons.request_quote;
      reason = item.reason ?? 'Cashout Request';
      date = item.createdAt;
      amount = item.amount;
      status = item.status; // pending, approved, rejected
    } else {
      // It's a regular transaction
      isCredit = item.type.toLowerCase() == 'credit';
      iconColor = isCredit ? const Color(0xFF27AE60) : const Color(0xFFE74C3C);
      icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
      reason = item.reason;
      date = item.createdAt;
      amount = item.amount;
      status = null;
    }
    
    // Format date
    final dateFormat = DateFormat('MMM dd, yyyy');
    final formattedDate = dateFormat.format(date);
    
    // Format amount
    final amountPrefix = isCredit ? '+' : '-';
    final formattedAmount = '${amountPrefix}Br${amount.toStringAsFixed(2)}';
    
    return GestureDetector(
      onTap: () => _showTransactionDetail(context, theme, item, isCashoutRequest),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: isCashoutRequest 
              ? Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reason,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (status != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(status).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formattedAmount,
            style: TextStyle(
              color: iconColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, AppThemeData theme, dynamic item, bool isCashoutRequest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailBottomSheet(
        transaction: item,
        isCashoutRequest: isCashoutRequest,
        theme: theme,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B); // Orange
      case 'approved':
        return const Color(0xFF27AE60); // Green
      case 'rejected':
        return const Color(0xFFE74C3C); // Red
      default:
        return const Color(0xFF9CA3AF); // Gray
    }
  }

  void _showAddPaymentMethodDialog(BuildContext context, AppThemeData theme) {
    final nameController = TextEditingController();
    final accountNumberController = TextEditingController();
    final accountHolderController = TextEditingController();
    String selectedType = 'wallet';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: theme.surface,
          title: Text(
            'Add Payment Method',
            style: TextStyle(color: theme.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Type',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    fillColor: theme.inputBackground,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.divider),
                    ),
                  ),
                  dropdownColor: theme.surface,
                  items: [
                    DropdownMenuItem(
                      value: 'wallet',
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: theme.textPrimary, size: 20),
                          const SizedBox(width: 8),
                          Text('Mobile Wallet', style: TextStyle(color: theme.textPrimary)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'bank',
                      child: Row(
                        children: [
                          Icon(Icons.account_balance, color: theme.textPrimary, size: 20),
                          const SizedBox(width: 8),
                          Text('Bank Account', style: TextStyle(color: theme.textPrimary)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'card',
                      child: Row(
                        children: [
                          Icon(Icons.credit_card, color: theme.textPrimary, size: 20),
                          const SizedBox(width: 8),
                          Text('Card', style: TextStyle(color: theme.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Name',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  style: TextStyle(color: theme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'e.g., My Telebirr',
                    hintStyle: TextStyle(color: theme.textHint),
                    fillColor: theme.inputBackground,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Account Holder Name',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: accountHolderController,
                  style: TextStyle(color: theme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Full name',
                    hintStyle: TextStyle(color: theme.textHint),
                    fillColor: theme.inputBackground,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  selectedType == 'wallet' ? 'Phone Number' : selectedType == 'bank' ? 'Account Number' : 'Card Number',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: accountNumberController,
                  style: TextStyle(color: theme.textPrimary),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: selectedType == 'wallet' ? '+251912345678' : '1234567890',
                    hintStyle: TextStyle(color: theme.textHint),
                    fillColor: theme.inputBackground,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.primary, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    accountNumberController.text.isEmpty ||
                    accountHolderController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please fill all fields'),
                      backgroundColor: theme.error,
                    ),
                  );
                  return;
                }

                // Get vendorId from current state
                final walletState = context.read<WalletBloc>().state;
                String vendorId = '1'; // Default fallback
                
                if (walletState is WalletBalanceLoaded) {
                  vendorId = walletState.walletData.vendorId?.toString() ?? '1';
                }

                // Create payment method
                context.read<WalletBloc>().add(CreatePaymentMethod(
                  vendorId: vendorId,
                  name: nameController.text,
                  accountNumber: accountNumberController.text,
                  accountHolder: accountHolderController.text,
                  type: selectedType,
                  details: {},
                ));

                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Payment method added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeletePaymentMethodDialog(BuildContext context, AppThemeData theme, int paymentMethodId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text(
          'Delete Payment Method',
          style: TextStyle(color: theme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete this payment method? This action cannot be undone.',
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Get vendorId from current state
              final walletState = context.read<WalletBloc>().state;
              String vendorId = '1'; // Default fallback
              
              if (walletState is WalletBalanceLoaded) {
                vendorId = walletState.walletData.vendorId?.toString() ?? '1';
              }

              context.read<WalletBloc>().add(DeletePaymentMethod(
                paymentMethodId: paymentMethodId,
                vendorId: vendorId,
              ));

              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Payment method deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
