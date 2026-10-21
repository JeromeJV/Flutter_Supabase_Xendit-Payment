class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final num price;
  final String imageUrl;

  factory Product.fromMap(Map<String, dynamic> map) {
    final rawId = map['id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId');
    if (id == null) {
      throw const FormatException('Product has an invalid or missing id.');
    }

    final rawName = map['name'];
    if (rawName is! String || rawName.trim().isEmpty) {
      throw const FormatException('Product has an invalid or missing name.');
    }

    final rawPrice = map['price'];
    final price = rawPrice is num ? rawPrice : num.tryParse('$rawPrice');
    if (price == null || !price.isFinite || price < 0) {
      throw const FormatException('Product has an invalid price.');
    }

    final rawImageUrl = map['image_url'];
    if (rawImageUrl != null && rawImageUrl is! String) {
      throw const FormatException('Product has an invalid image URL.');
    }

    return Product(
      id: id,
      name: rawName.trim(),
      price: price,
      imageUrl: (rawImageUrl as String? ?? '').trim(),
    );
  }
}
