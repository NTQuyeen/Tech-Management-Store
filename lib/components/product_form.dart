import 'package:flutter/material.dart';
import '../constants.dart'; // Để lấy màu AppColors.primary

class ProductForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController idCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController qtyCtrl;

  // PHẦN DROPDOWN
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
        // --- HÀNG 1: Tên sản phẩm & Mã SP ---
        Row(
          children: [
            Expanded(
              flex: 3, // Tên SP dài hơn chút
              child: _buildRow("Tên sản phẩm", controller: nameCtrl),
            ),
            const SizedBox(width: 20),
            Expanded(flex: 2, child: _buildRow("Mã SP", controller: idCtrl)),
          ],
        ),
        const SizedBox(height: 15),

        // --- HÀNG 2: Loại sản phẩm & Số lượng ---
        Row(
          children: [
            // Dropdown Loại sản phẩm
            Expanded(
              flex: 3,
              child: _buildRow(
                "Loại sản phẩm",
                customWidget: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      hint: const Text("Chọn loại"),
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
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: _buildRow("Số lượng", controller: qtyCtrl, isNumber: true),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // --- HÀNG 3: Đơn giá & (Ô trống để cân đối) ---
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildRow(
                "Đơn giá",
                controller: priceCtrl,
                isNumber: true,
              ),
            ),
            const SizedBox(width: 20),
            // Spacer trống bên phải để giữ form thẳng hàng với flex ở trên
            const Expanded(flex: 2, child: SizedBox()),
          ],
        ),
      ],
    );
  }

  // --- HÀM TẠO DÒNG NHẬP LIỆU (Label Trái - Input Phải) ---
  Widget _buildRow(
    String label, {
    TextEditingController? controller,
    bool isNumber = false,
    Widget? customWidget,
  }) {
    return Row(
      children: [
        // 1. PHẦN LABEL (MÀU XANH BÊN TRÁI)
        Container(
          width: 110, // Độ rộng cố định cho Label để thẳng hàng
          height: 40, // Chiều cao cố định
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(
              0xFF00695C,
            ), // Màu xanh đậm giống hình mẫu (Teal)
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 10),

        // 2. PHẦN INPUT (MÀU TRẮNG BÊN PHẢI)
        Expanded(
          child:
              customWidget ??
              SizedBox(
                // Nếu có widget riêng (Dropdown) thì dùng, ko thì dùng TextField
                height: 40, // Chiều cao khớp với label
                child: TextField(
                  controller: controller,
                  keyboardType: isNumber
                      ? TextInputType.number
                      : TextInputType.text,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 0,
                    ),
                    border: OutlineInputBorder(), // Viền xám
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
        ),
      ],
    );
  }
}
