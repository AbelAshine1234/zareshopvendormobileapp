import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../models/payment_model.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  State<PaymentManagementScreen> createState() => _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Tab changed
      });
    });
    
    // Load initial data
    context.read<PaymentBloc>().add(const GetMyPayments());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Payment Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () {
              context.read<PaymentBloc>().add(const RefreshPayments());
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'All Payments', icon: Icon(Icons.payment)),
            Tab(text: 'Pending', icon: Icon(Icons.schedule)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
            Tab(text: 'Create Payment', icon: Icon(Icons.add)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllPaymentsTab(),
          _buildPendingPaymentsTab(),
          _buildCompletedPaymentsTab(),
          _buildCreatePaymentTab(),
        ],
      ),
    );
  }

  Widget _buildAllPaymentsTab() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        if (state is PaymentListLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PaymentListLoaded) {
          return _buildPaymentsList(state.payments);
        } else if (state is PaymentListError) {
          return _buildErrorWidget(state.message);
        } else {
          return const Center(child: Text('No payments found'));
        }
      },
    );
  }

  Widget _buildPendingPaymentsTab() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        if (state is PaymentListLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PaymentListLoaded) {
          final pendingPayments = state.payments
              .where((payment) => payment.status == PaymentStatus.pending)
              .toList();
          return _buildPaymentsList(pendingPayments);
        } else if (state is PaymentListError) {
          return _buildErrorWidget(state.message);
        } else {
          return const Center(child: Text('No pending payments'));
        }
      },
    );
  }

  Widget _buildCompletedPaymentsTab() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        if (state is PaymentListLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PaymentListLoaded) {
          final completedPayments = state.payments
              .where((payment) => payment.status == PaymentStatus.completed)
              .toList();
          return _buildPaymentsList(completedPayments);
        } else if (state is PaymentListError) {
          return _buildErrorWidget(state.message);
        } else {
          return const Center(child: Text('No completed payments'));
        }
      },
    );
  }

  Widget _buildCreatePaymentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCreatePaymentForm(),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(List<Payment> payments) {
    if (payments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No payments found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _buildPaymentCard(payment);
      },
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Payment #${payment.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(payment.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  payment.statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(payment.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                '${payment.currency} ${payment.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.payment, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                payment.methodText,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (payment.paymentReference != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  payment.paymentReference!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                _formatDate(payment.createdAt),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showPaymentDetails(payment),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ),
              if (payment.isPending && payment.isManual) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showUploadProofDialog(payment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Upload Proof'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePaymentForm() {
    return BlocConsumer<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Switch to all payments tab
          _tabController.animateTo(0);
          // Refresh payments
          context.read<PaymentBloc>().add(const RefreshPayments());
        } else if (state is PaymentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return _CreatePaymentForm();
      },
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<PaymentBloc>().add(const RefreshPayments());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
      case PaymentStatus.verified:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showUploadProofDialog(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Payment Proof'),
        content: const Text('This feature will allow you to upload payment proof images.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement image picker and upload
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment proof upload feature coming soon'),
                ),
              );
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetails(Payment payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Payment Details',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Payment ID', '#${payment.id}'),
                _buildDetailRow('Amount', '${payment.currency} ${payment.amount.toStringAsFixed(2)}'),
                _buildDetailRow('Status', payment.statusText),
                _buildDetailRow('Method', payment.methodText),
                if (payment.paymentReference != null)
                  _buildDetailRow('Reference', payment.paymentReference!),
                if (payment.paymentProvider != null)
                  _buildDetailRow('Provider', payment.paymentProvider!),
                _buildDetailRow('Created', _formatDate(payment.createdAt)),
                if (payment.completedAt != null)
                  _buildDetailRow('Completed', _formatDate(payment.completedAt!)),
                const SizedBox(height: 20),
                if (payment.isPending && payment.isManual)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showUploadProofDialog(payment);
                      },
                      child: const Text('Upload Payment Proof'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatePaymentForm extends StatefulWidget {
  @override
  State<_CreatePaymentForm> createState() => _CreatePaymentFormState();
}

class _CreatePaymentFormState extends State<_CreatePaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  PaymentMethod _selectedMethod = PaymentMethod.manual;
  PaymentProvider _selectedProvider = PaymentProvider.bankTransfer;
  final String _currency = 'ETB';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Payment',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Amount Input
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: 'Enter payment amount',
              border: OutlineInputBorder(),
              prefixText: 'ETB ',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          // Payment Method
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<PaymentMethod>(
            initialValue: _selectedMethod,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: PaymentMethod.values.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(method.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMethod = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          
          // Payment Provider
          const Text(
            'Payment Provider',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<PaymentProvider>(
            initialValue: _selectedProvider,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: PaymentProvider.values.map((provider) {
              return DropdownMenuItem(
                value: provider,
                child: Text(provider.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProvider = value!;
              });
            },
          ),
          const SizedBox(height: 30),
          
          // Create Button
          BlocBuilder<PaymentBloc, PaymentState>(
            builder: (context, state) {
              final isLoading = state is PaymentLoading;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _createPayment,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Payment'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _createPayment() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      
      context.read<PaymentBloc>().add(CreatePayment(
        amount: amount,
        paymentMethod: _selectedMethod,
        paymentProvider: _selectedProvider,
        currency: _currency,
      ));
    }
  }
}
