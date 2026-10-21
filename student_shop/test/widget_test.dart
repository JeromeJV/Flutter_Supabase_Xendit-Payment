import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_shop/main.dart';
import 'package:student_shop/models/product_model.dart';
import 'package:student_shop/screens/demo_store_screen.dart';

void main() {
  testWidgets('shows a working sample catalog without credentials', (
    tester,
  ) async {
    await tester.pumpWidget(const StudentShopApp());

    expect(find.byType(DemoStoreScreen), findsOneWidget);
    expect(find.text('Mechanical Gaming Keyboard'), findsOneWidget);
    expect(find.text('₱1500.00'), findsOneWidget);
    expect(
      find.textContaining('DEMO MODE — sample products only'),
      findsOneWidget,
    );
  });

  testWidgets('does not claim to place an order in demo mode', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DemoStoreScreen()));

    await tester.tap(find.text('Buy Now').first);
    await tester.pumpAndSettle();

    expect(find.text('Demo mode'), findsOneWidget);
    expect(find.textContaining('no order was placed'), findsOneWidget);
  });

  test('parses a Supabase product row', () {
    final product = Product.fromMap({
      'id': 1,
      'name': 'Notebook',
      'price': 25.5,
      'image_url': 'https://example.com/notebook.png',
    });

    expect(product.id, 1);
    expect(product.name, 'Notebook');
    expect(product.price, 25.5);
    expect(product.imageUrl, 'https://example.com/notebook.png');
  });

  test('rejects products with invalid prices', () {
    expect(
      () => Product.fromMap({
        'id': 1,
        'name': 'Notebook',
        'price': 'not-a-price',
        'image_url': '',
      }),
      throwsFormatException,
    );
  });
}
