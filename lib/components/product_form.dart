import 'package:flutter/material.dart';
import '../widgets/label_input.dart'; // Import LabelInput đã sửa

class ProductForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController idCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController qtyCtrl;

  final List<String> categoryList;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;

  const ProductForm({
    super.key,
    required this.nameCtrl,
    required this.idCtrl,
    required this.priceCtrl,
    required this.qtyCtrl,
    required this.categoryList,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LabelInput(label: "Tên sản phẩm", controller: nameCtrl),
        LabelInput(label: "Mã sản phẩm", controller: idCtrl),

        // GIỜ ĐÃ CÓ THỂ DÙNG LabelInput CHO DROPDOWN
        LabelInput(
          label: "Loại sản phẩm",
          widget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                style: const TextStyle(fontSize: 14, color: Colors.black),
                items: categoryList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: onCategoryChanged,
              ),
            ),
          ),
        ),

        LabelInput(label: "Số lượng", controller: qtyCtrl, isNumber: true),
        LabelInput(label: "Đơn giá", controller: priceCtrl, isNumber: true),
      ],
    );
  }
}
