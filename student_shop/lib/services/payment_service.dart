import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';

class PaymentInvoice {
  const PaymentInvoice({required this.url, required this.externalId});

  final Uri url;
  final String externalId;
}

class PaymentService {
  PaymentService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<List<Product>> fetchProducts() async {
    final response = await _supabase
        .from('products')
        .select()
        .order('id', ascending: true);

    return response
        .map((item) => Product.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<PaymentInvoice> createInvoice(Product product) async {
    final response = await _supabase.functions.invoke(
      'create-invoice',
      body: {'product_name': product.name, 'amount': product.price},
    );

    if (response.status < 200 || response.status >= 300) {
      throw Exception('Failed to create invoice: ${response.data}');
    }
    if (response.data is! Map) {
      throw const FormatException(
        'The create-invoice function returned an invalid response.',
      );
    }

    final invoiceData = Map<String, dynamic>.from(response.data as Map);
    final rawUrl = invoiceData['invoice_url'];
    final rawExternalId = invoiceData['external_id'];
    final url = rawUrl is String ? Uri.tryParse(rawUrl) : null;

    if (url == null ||
        url.scheme != 'https' ||
        url.host.isEmpty ||
        rawExternalId is! String ||
        rawExternalId.isEmpty) {
      throw const FormatException(
        'The create-invoice function did not return a valid invoice URL '
        'and external ID.',
      );
    }

    return PaymentInvoice(url: url, externalId: rawExternalId);
  }

  Future<String> checkOrderStatus(String externalId) async {
    final record = await _supabase
        .from('orders')
        .select('status')
        .eq('external_id', externalId)
        .maybeSingle();

    if (record == null) {
      throw StateError('No order was found for invoice $externalId.');
    }

    final status = record['status'];
    if (status is! String || status.isEmpty) {
      throw const FormatException('The order has an invalid payment status.');
    }
    return status;
  }

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final response = await _supabase
        .from('orders')
        .select()
        .order('created_at', ascending: false);

    return response
        .map((order) => Map<String, dynamic>.from(order as Map))
        .toList();
  }
}
