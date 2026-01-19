import 'package:flutter/material.dart';
import '../constants.dart';

class ProductForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController idCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController qtyCtrl;

  // dropdown
  final List<String> categoryList;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;

  // ✅ search trong ô Mã SP
  final bool enableCodeSearch;
  final VoidCallback? onSearchCode;

  // ✅ khóa tên + loại khi đã auto-fill từ kho
  final bool lockNameAndCategory;

  const ProductForm({
    super.key,
    required this.nameCtrl,
    required this.idCtrl,
    required this.priceCtrl,
    required this.qtyCtrl,
    required this.categoryList,
    required this.selectedCategory,
    required this.onCategoryChanged,
    this.enableCodeSearch = false,
    this.onSearchCode,
    this.lockNameAndCategory = false,
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
              flex: 3,
              child: _buildRow(
                "Tên sản phẩm",
                controller: nameCtrl,
                readOnly: lockNameAndCategory, // ✅ auto fill -> khóa
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: _buildRow(
                "Mã SP",
                controller: idCtrl,
                // ✅ gắn nút tìm kiếm trong input mã
                suffixIcon: enableCodeSearch
                    ? IconButton(
                        tooltip: "Tìm trong kho",
                        icon: const Icon(Icons.search),
                        onPressed: onSearchCode,
                      )
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // --- HÀNG 2: Loại sản phẩm & Số lượng ---
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildRow(
                "Loại sản phẩm",
                customWidget: AbsorbPointer(
                  absorbing:
                      lockNameAndCategory, // ✅ khóa dropdown khi auto fill
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                      color: lockNameAndCategory
                          ? Colors.grey.shade100
                          : Colors.white,
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
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: _buildRow("Số lượng", controller: qtyCtrl, isNumber: true),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // --- HÀNG 3: Đơn giá ---
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
            const Expanded(flex: 2, child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(
    String label, {
    TextEditingController? controller,
    bool isNumber = false,
    Widget? customWidget,
    Widget? suffixIcon,
    bool readOnly = false,
  }) {
    return Row(
      children: [
        Container(
          width: 110,
          height: 40,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF00695C),
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
        Expanded(
          child:
              customWidget ??
              SizedBox(
                height: 40,
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  keyboardType: isNumber
                      ? TextInputType.number
                      : TextInputType.text,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 0,
                    ),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    suffixIcon: suffixIcon, // ✅ icon search ở đây
                  ),
                ),
              ),
        ),
      ],
    );
  }
}
