class Product {
  String id; // product_id (kỹ thuật, dùng update/delete)
  String name;

  // hiển thị
  String category;

  // ✅ lấy id category trong DB
  int? categoryId;

  double price;

  // ✅ giá nhập
  double? priceIn;

  // Mã SP nghiệp vụ (vd: P101)
  String productCode;

  // ✅ TÁCH 2 loại số lượng theo BE
  int stock; // tồn kho
  int available; // đang bán

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.productCode,
    required this.stock,
    required this.available,
    this.priceIn,
    this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final cat = json['category'];

    String _toString(dynamic v) => (v ?? '').toString();

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    double _toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    double? _toDoubleOrNull(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    // ✅ categoryName + categoryId
    final String categoryName = (cat is Map)
        ? _toString(cat['categoryName'])
        : _toString(json['categoryName']);

    final int? categoryId = (cat is Map)
        ? (cat['id'] ?? cat['categoryId'] ?? cat['category_id']) is num
              ? (cat['id'] ?? cat['categoryId'] ?? cat['category_id'] as num)
                    .toInt()
              : int.tryParse(
                  _toString(
                    cat['id'] ?? cat['categoryId'] ?? cat['category_id'],
                  ),
                )
        : (json['categoryId'] is num
              ? (json['categoryId'] as num).toInt()
              : int.tryParse(_toString(json['categoryId'])));

    return Product(
      id: _toString(json['id'] ?? json['productId'] ?? json['product_id']),
      name: _toString(json['name'] ?? json['productName']),
      category: categoryName,
      categoryId: categoryId,

      price: _toDouble(json['price']),
      priceIn: _toDoubleOrNull(json['priceIn']),

      productCode: _toString(json['productCode']),
      stock: _toInt(json['stock']),
      available: _toInt(json['available']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': int.tryParse(id) ?? id,
      'productCode': productCode,
      'name': name,

      // FE chỉ hiển thị categoryName; nếu BE cần idCategory thì gửi ở nơi khác
      'category': category,

      'stock': stock,
      'available': available,
      'price': price,
      'priceIn': priceIn, // ✅
      'categoryId': categoryId, // ✅
    };
  }
}
