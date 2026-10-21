import 'package:flutter/material.dart';

import '../models/product_model.dart';

class DemoStoreScreen extends StatelessWidget {
  const DemoStoreScreen({super.key});

  static const _products = [
    Product(
      id: 1,
      name: 'Mechanical Gaming Keyboard',
      price: 1500,
      imageUrl: '',
    ),
    Product(id: 2, name: 'Campus Notebook', price: 85, imageUrl: ''),
    Product(id: 3, name: 'Student Backpack', price: 750, imageUrl: ''),
  ];

  void _showCheckoutNotice(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.info_outline),
        title: const Text('Demo mode'),
        content: const Text(
          'This is a sample product catalog. Checkout and payments are '
          'disabled, and no order was placed. To enable real checkout, '
          'connect your Supabase project and deploy the Xendit invoice '
          'function and payment webhook.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Store'),
        actions: [
          IconButton(
            tooltip: 'About demo mode',
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showCheckoutNotice(context),
          ),
        ],
      ),
      body: Column(
        children: [
          MaterialBanner(
            leading: const Icon(Icons.science_outlined),
            content: const Text(
              'DEMO MODE — sample products only; checkout is not connected.',
            ),
            actions: [
              TextButton(
                onPressed: () => _showCheckoutNotice(context),
                child: const Text('Details'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Icon(
                      Icons.shopping_bag_outlined,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('₱${product.price.toStringAsFixed(2)}'),
                    trailing: FilledButton(
                      onPressed: () => _showCheckoutNotice(context),
                      child: const Text('Buy Now'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
