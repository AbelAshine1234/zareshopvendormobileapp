import 'package:flutter/material.dart';
import '../../../shared/utils/theme/app_themes.dart';
import 'order_detail_screen.dart';

class OrdersTab extends StatelessWidget {
  final AppThemeData theme;

  const OrdersTab({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Fake orders data
    final orders = [
      {
        'orderId': '#ORD-12345',
        'supplier': 'Ethiopian Coffee Co.',
        'status': 'Shipped',
        'amount': 'ETB 15,000.00',
        'date': 'Nov 5, 2025',
        'items': '50 units',
        'statusColor': Colors.blue,
      },
      {
        'orderId': '#ORD-12344',
        'supplier': 'Tech Solutions Ltd',
        'status': 'Processing',
        'amount': 'ETB 8,500.00',
        'date': 'Nov 4, 2025',
        'items': '25 units',
        'statusColor': Colors.orange,
      },
      {
        'orderId': '#ORD-12343',
        'supplier': 'Eco Fashion Hub',
        'status': 'Delivered',
        'amount': 'ETB 22,300.00',
        'date': 'Nov 2, 2025',
        'items': '100 units',
        'statusColor': Colors.green,
      },
      {
        'orderId': '#ORD-12342',
        'supplier': 'Office Solutions Pro',
        'status': 'Cancelled',
        'amount': 'ETB 5,200.00',
        'date': 'Nov 1, 2025',
        'items': '15 units',
        'statusColor': Colors.red,
      },
    ];

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: theme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, theme);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, AppThemeData theme) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => OrderDetailScreen(order: order),
          );
        },
        child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border(
            bottom: BorderSide(color: theme.divider.withOpacity(0.5), width: 1),
          ),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order['orderId'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: (order['statusColor'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order['status'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: order['statusColor'] as Color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.store, size: 16, color: theme.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order['supplier'],
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, size: 16, color: theme.textSecondary),
              const SizedBox(width: 6),
              Text(
                order['items'],
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                order['amount'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: theme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: theme.textSecondary),
              const SizedBox(width: 6),
              Text(
                order['date'],
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
        ),
      ),
    );
  }
}
