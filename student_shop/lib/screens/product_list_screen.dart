import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/payment_service.dart';
import 'orders_screen.dart';
import 'xendit_webview_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final PaymentService _paymentService = PaymentService();
  late Future<List<Product>> _productsFuture;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _productsFuture = _paymentService.fetchProducts();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = _paymentService.fetchProducts();
    });
  }

  Future<void> _openOrderHistory() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (context) => const OrdersScreen()),
    );
    if (mounted) _refreshProducts();
  }

  Future<void> _handleBuyProduct(Product product) async {
    setState(() => _isProcessing = true);

    try {
      final invoice = await _paymentService.createInvoice(product);
      if (!mounted) return;

      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => XenditWebViewScreen(invoiceUrl: invoice.url),
        ),
      );

      final status = await _paymentService.checkOrderStatus(invoice.externalId);
      if (!mounted) return;

      final isPaid = status.toUpperCase() == 'PAID';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPaid
                ? 'Payment verified! ${product.name} is paid.'
                : 'Order status is currently: $status',
          ),
          backgroundColor: isPaid ? Colors.green : Colors.orange,
        ),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not complete the purchase: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh products',
            onPressed: _isProcessing ? null : _refreshProducts,
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Order history',
            onPressed: _isProcessing ? null : _openOrderHistory,
          ),
        ],
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Connecting to Supabase and Xendit...'),
                ],
              ),
            )
          : FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _MessageState(
                    icon: Icons.error_outline,
                    message: 'Could not load products.\n${snapshot.error}',
                    actionLabel: 'Try again',
                    onPressed: _refreshProducts,
                  );
                }

                final products = snapshot.data ?? const <Product>[];
                if (products.isEmpty) {
                  return _MessageState(
                    icon: Icons.storefront_outlined,
                    message: 'No products found.',
                    actionLabel: 'Refresh',
                    onPressed: _refreshProducts,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _refreshProducts(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: _ProductImage(imageUrl: product.imageUrl),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '₱${product.price.toStringAsFixed(2)}',
                          ),
                          trailing: FilledButton(
                            onPressed: () => _handleBuyProduct(product),
                            child: const Text('Buy Now'),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      Icons.shopping_bag_outlined,
      size: 40,
      color: Theme.of(context).colorScheme.primary,
    );

    if (imageUrl.isEmpty) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
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
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
