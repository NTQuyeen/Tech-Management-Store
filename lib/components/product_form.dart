import 'package:flutter/material.dart';
import '../widgets/label_input.dart';

class ProductForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController idCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController qtyCtrl;
  final TextEditingController categoryCtrl;
  // Đã xóa searchCtrl

  const ProductForm({
    super.key,
    required this.nameCtrl,
    required this.idCtrl,
    required this.priceCtrl,
    required this.qtyCtrl,
    required this.categoryCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Để Dialog co lại vừa đủ nội dung
      children: [
        LabelInput(label: "Tên sản phẩm", controller: nameCtrl),
        LabelInput(label: "Mã sản phẩm", controller: idCtrl),
        LabelInput(label: "Loại sản phẩm", controller: categoryCtrl),
        LabelInput(label: "Số lượng", controller: qtyCtrl),
        LabelInput(label: "Đơn giá", controller: priceCtrl),
        // Có thể thêm Voucher/Thương hiệu nếu muốn
      ],
    );
  }
}
