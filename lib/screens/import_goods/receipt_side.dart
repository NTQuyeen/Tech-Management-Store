import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../constants.dart';

class ReceiptSide extends StatelessWidget {
  // Dữ liệu
  final List<Map<String, dynamic>> importItems;
  final List<String> suppliers;
  final String selectedSupplier;
  final int? selectedIndex;
  final double totalAmount;

  // Callbacks
  final Function(String?) onSupplierChanged;
  final Function(int) onSelectRow;
  final VoidCallback onRemove;
  final VoidCallback onEditQty;
  final VoidCallback onExportExcel;
  final VoidCallback onSubmit;

  const ReceiptSide({
    super.key,
    required this.importItems,
    required this.suppliers,
    required this.selectedSupplier,
    required this.selectedIndex,
    required this.totalAmount,
    required this.onSupplierChanged,
    required this.onSelectRow,
    required this.onRemove,
    required this.onEditQty,
    required this.onExportExcel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // THÔNG TIN PHIẾU
          _buildInfoRow(
            "Mã phiếu",
            "PN${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
            isReadOnly: true,
          ),
          const SizedBox(height: 10),

          // Dropdown Nhà cung cấp
          Row(
            children: [
              const SizedBox(
                width: 100,
                child: Text(
                  "Nhà cung cấp",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedSupplier,
                      isExpanded: true,
                      items: suppliers
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: onSupplierChanged,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow("Người tạo", "Admin", isReadOnly: true),
          const SizedBox(height: 20),

          // --- BẢNG CHI TIẾT (ĐÃ SỬA LỖI NHỎ & OVERFLOW) ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: LayoutBuilder(
                // 1. Lấy kích thước khung chứa
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        // 2. Ép chiều rộng tối thiểu bằng chiều rộng khung chứa
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.grey[200],
                          ),
                          showCheckboxColumn: false,
                          columnSpacing: 20,
                          // Kéo giãn các cột
                          columns: const [
                            DataColumn(label: Text("STT")),
                            DataColumn(label: Text("Mã máy")),
                            DataColumn(
                              label: Text("Tên máy"),
                            ), // Bỏ giới hạn độ rộng để tự giãn
                            DataColumn(label: Text("SL"), numeric: true),
                            DataColumn(label: Text("Đơn giá"), numeric: true),
                            DataColumn(
                              label: Text("Thành tiền"),
                              numeric: true,
                            ),
                          ],
                          rows: List.generate(importItems.length, (index) {
                            final item = importItems[index];
                            final product = item['product'] as Product;
                            final isSelected = index == selectedIndex;
                            final total =
                                (item['quantity'] as int) *
                                (item['price'] as double);

                            return DataRow(
                              selected: isSelected,
                              onSelectChanged: (_) => onSelectRow(index),
                              color: MaterialStateProperty.resolveWith<Color?>(
                                (states) => isSelected
                                    ? Colors.blue.withOpacity(0.1)
                                    : null,
                              ),
                              cells: [
                                DataCell(Text("${index + 1}")),
                                DataCell(Text(product.id)),
                                // Cho phép tên hiển thị dài thoải mái
                                DataCell(Text(product.name)),
                                DataCell(Text("${item['quantity']}")),
                                DataCell(Text("${item['price']}")),
                                DataCell(Text(total.toStringAsFixed(0))),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ----------------------------------------------------
          const SizedBox(height: 15),

          // CÁC NÚT CHỨC NĂNG
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                "Xuất Excel",
                Icons.file_download,
                Colors.green,
                onExportExcel,
                isOutlined: true,
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                "Sửa số lượng",
                Icons.edit,
                Colors.black54,
                onEditQty,
                isOutlined: true,
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                "Xóa",
                Icons.delete,
                Colors.red,
                onRemove,
                isOutlined: false,
              ),
            ],
          ),

          const Divider(height: 30, thickness: 2),

          // TỔNG TIỀN & NÚT NHẬP HÀNG
          Row(
            children: [
              const Text(
                "TỔNG TIỀN:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${totalAmount.toStringAsFixed(0)} VNĐ",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                ),
                onPressed: onSubmit,
                child: const Text(
                  "NHẬP HÀNG",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildInfoRow(String label, String value, {bool isReadOnly = false}) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Container(
            height: 40,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isReadOnly ? Colors.grey[200] : Colors.white,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(value),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return ElevatedButton.icon(
        icon: Icon(icon, color: color),
        label: Text(label, style: const TextStyle(color: Colors.black)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(
            color: color == Colors.black54 ? Colors.grey : color,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
        onPressed: onTap,
      );
    }
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
      onPressed: onTap,
    );
  }
}
