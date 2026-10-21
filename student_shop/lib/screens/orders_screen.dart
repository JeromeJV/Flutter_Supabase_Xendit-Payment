import 'package:flutter/material.dart';

import '../services/payment_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final PaymentService _paymentService = PaymentService();
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _paymentService.fetchOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = _paymentService.fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh orders',
            onPressed: _refreshOrders,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _OrdersMessage(
              message: 'Could not load orders.\n${snapshot.error}',
              actionLabel: 'Try again',
              onPressed: _refreshOrders,
            );
          }

          final orders = snapshot.data ?? const <Map<String, dynamic>>[];
          if (orders.isEmpty) {
            return _OrdersMessage(
              message: 'No orders yet.',
              actionLabel: 'Refresh',
              onPressed: _refreshOrders,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final status = order['status'] is String
                  ? order['status'] as String
                  : 'UNKNOWN';
              final isPaid = status.toUpperCase() == 'PAID';
              final amount = order['amount'];
              final amountText = amount is num
                  ? '₱${amount.toStringAsFixed(2)}'
                  : 'Amount unavailable';
              final productName = order['product_name'] is String
                  ? order['product_name'] as String
                  : 'Item';
              final externalId = order['external_id'] is String
                  ? order['external_id'] as String
                  : 'Unavailable';

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(
                    isPaid ? Icons.check_circle : Icons.schedule,
                    color: isPaid ? Colors.green : Colors.orange,
                    size: 36,
                  ),
                  title: Text(
                    productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Ref: $externalId'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        amountText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isPaid
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _OrdersMessage extends StatelessWidget {
  const _OrdersMessage({
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
