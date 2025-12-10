import 'package:flutter/material.dart';
import '../widgets/label_input.dart'; // Đảm bảo import đúng file LabelInput

class ProductForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController idCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController qtyCtrl;

  // Các tham số cho Dropdown
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
        // 1. Tên sản phẩm
        LabelInput(label: "Tên sản phẩm", controller: nameCtrl),

        // 2. Mã sản phẩm
        LabelInput(label: "Mã sản phẩm", controller: idCtrl),

        // 3. Loại sản phẩm (ĐÃ SỬA: Dùng LabelInput bọc Dropdown)
        LabelInput(
          label: "Loại sản phẩm",
          widget: Container(
            // Tạo khung viền giống hệt TextField trong LabelInput
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black45,
              ), // Màu viền xám đậm giống input
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.centerLeft,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true, // Bung full chiều ngang
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

        // 4. Số lượng
        LabelInput(label: "Số lượng", controller: qtyCtrl, isNumber: true),

        // 5. Đơn giá
        LabelInput(label: "Đơn giá", controller: priceCtrl, isNumber: true),
      ],
    );
  }
}
