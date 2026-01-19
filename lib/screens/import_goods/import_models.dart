class ProductLite {
  final String code;
  final String name;
  final num? priceIn; // ✅ thêm
  final int? categoryId; // ✅ để biết category nếu cần
  final num? price; // ✅ giá bán nếu cần

  const ProductLite({
    required this.code,
    required this.name,
    this.priceIn,
    this.categoryId,
    this.price,
  });
}

class ImportProductDraft {
  final String code;
  String name;
  int? idCategory;
  num? price; // giá bán
  String? description;

  ImportProductDraft({
    required this.code,
    this.name = "",
    this.idCategory,
    this.price,
    this.description,
  });
}

class ImportLine {
  final ProductLite product;
  final int quantity;
  final double costPrice;
  final ImportProductDraft? draft; // ✅ thêm

  ImportLine({
    required this.product,
    required this.quantity,
    required this.costPrice,
    this.draft,
  });

  ImportLine copyWith({
    ProductLite? product,
    int? quantity,
    double? costPrice,
    ImportProductDraft? draft,
  }) {
    return ImportLine(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      costPrice: costPrice ?? this.costPrice,
      draft: draft ?? this.draft,
    );
  }

  double get lineTotal => quantity * costPrice;
}

enum PaymentStatus { unpaid, partial, paid }

extension PaymentStatusX on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.unpaid:
        return "Chưa thanh toán";
      case PaymentStatus.partial:
        return "Thanh toán một phần";
      case PaymentStatus.paid:
        return "Đã thanh toán";
    }
  }
}

extension FirstOrNullExt<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
