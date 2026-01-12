class Product {
  String id; // product_id (kỹ thuật, dùng update/delete)
  String name;
  String category;
  int quantity;
  double price;

  // ✅ Mã SP nghiệp vụ (vd: P101)
  String productCode;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    required this.productCode,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final cat = json['category'];
    final String categoryName = (cat is Map)
        ? (cat['categoryName'] ?? '').toString()
        : (json['categoryName'] ?? '').toString();

    return Product(
      id: (json['id'] ?? json['productId']).toString(),
      name: (json['name'] ?? json['productName'] ?? '').toString(),
      category: categoryName, // ✅ chỉ lưu categoryName
      quantity: (json['quantity'] ?? json['stock'] ?? 0) as int,
      price: (json['price'] ?? 0).toDouble(),

      // ✅ BE trả về productCode
      productCode: (json['productCode'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // id kỹ thuật (chỉ gửi khi update)
      'id': id,

      // ✅ mã SP nghiệp vụ
      'productCode': productCode,

      'name': name,

      // Lưu ý: BE của bạn dùng idCategory để nhận category,
      // nên 'category' chỉ để hiển thị ở FE.
      'category': category,

      // Đồng bộ theo BE: stock
      'stock': quantity,

      'price': price,
    };
  }
}
