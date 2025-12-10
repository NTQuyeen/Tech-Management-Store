import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../constants.dart';

class ExportWarehouseSide extends StatelessWidget {
  final List<Product> products;
  final TextEditingController searchCtrl;
  final TextEditingController qtyCtrl;
  final int? selectedIndex;
  final Function(String) onSearch;
  final Function(int) onSelectRow;
  final VoidCallback onAdd;

  const ExportWarehouseSide({
    super.key,
    required this.products,
    required this.searchCtrl,
    required this.qtyCtrl,
    required this.selectedIndex,
    required this.onSearch,
    required this.onSelectRow,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "DANH SÁCH SẢN PHẨM",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),

          // TÌM KIẾM & LÀM MỚI
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchCtrl,
                  onChanged: onSearch,
                  decoration: const InputDecoration(
                    hintText: "Tìm kiếm...",
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              // Nút làm mới icon xoay
              IconButton(
                onPressed: () => onSearch(''),
                icon: const Icon(Icons.refresh, color: Colors.blue),
                tooltip: "Làm mới",
              ),
            ],
          ),
          const SizedBox(height: 10),

          // BẢNG DỮ LIỆU
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Colors.grey[200],
                    ),
                    showCheckboxColumn: false,
                    columns: const [
                      DataColumn(label: Text("STT")),
                      DataColumn(label: Text("Mã máy")),
                      DataColumn(label: Text("Tên máy")),
                      DataColumn(label: Text("Số lượng")), // Tồn kho
                      DataColumn(label: Text("Đơn giá")),
                    ],
                    rows: List.generate(products.length, (index) {
                      final p = products[index];
                      final isSelected = index == selectedIndex;
                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (_) => onSelectRow(index),
                        color: MaterialStateProperty.resolveWith<Color?>((
                          states,
                        ) {
                          if (isSelected)
                            return AppColors.primary.withOpacity(0.2);
                          return null;
                        }),
                        cells: [
                          DataCell(Text("${index + 1}")),
                          DataCell(Text(p.id)),
                          DataCell(Text(p.name)),
                          DataCell(Text("${p.quantity}")),
                          DataCell(Text("${p.price.toStringAsFixed(0)}")),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // KHU VỰC NHẬP SỐ LƯỢNG & THÊM
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  "Số lượng: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 100,
                  height: 40,
                  child: TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Thêm",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  onPressed: onAdd,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
