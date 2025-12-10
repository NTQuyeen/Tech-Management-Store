import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../constants.dart';

class ExportReceiptSide extends StatelessWidget {
  final List<Map<String, dynamic>> exportItems;
  final int? selectedIndex;
  final double totalAmount;
  final Function(int) onSelectRow;
  final VoidCallback onRemove;
  final VoidCallback onEditQty;
  final VoidCallback onExportExcel;
  final VoidCallback onSubmit;

  const ExportReceiptSide({
    super.key,
    required this.exportItems,
    required this.selectedIndex,
    required this.totalAmount,
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
          // THÔNG TIN PHIẾU (Chỉ có Mã phiếu & Người tạo)
          _buildInfoRow(
            "Mã phiếu",
            "PX${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            "Người tạo",
            "Admin",
          ), // Có thể thay bằng tên nhân viên đăng nhập
          const SizedBox(height: 20),

          // BẢNG CHI TIẾT PHIẾU XUẤT
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.grey[200],
                          ),
                          showCheckboxColumn: false,
                          columnSpacing: 20,
                          columns: const [
                            DataColumn(label: Text("STT")),
                            DataColumn(label: Text("Mã máy")),
                            DataColumn(label: Text("Tên máy")),
                            DataColumn(label: Text("Số lượng")),
                            DataColumn(label: Text("Đơn giá")),
                            DataColumn(label: Text("Thành tiền")),
                          ],
                          rows: List.generate(exportItems.length, (index) {
                            final item = exportItems[index];
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
          const SizedBox(height: 15),

          // NÚT CHỨC NĂNG
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Căn giữa giống hình mẫu
            children: [
              _buildActionButton(
                "Xuất excel",
                Icons.file_download,
                Colors.green,
                onExportExcel,
                isOutlined: true,
              ),
              const SizedBox(width: 20),
              _buildActionButton(
                "Sửa số lượng",
                Icons.edit,
                Colors.black54,
                onEditQty,
                isOutlined: true,
              ),
              const SizedBox(width: 20),
              _buildActionButton(
                "Xóa",
                Icons.delete,
                Colors.red,
                onRemove,
                isOutlined: true,
              ),
            ],
          ),

          const Divider(height: 30, thickness: 2),

          // TỔNG TIỀN & NÚT XUẤT HÀNG
          Row(
            children: [
              const Text(
                "TỔNG:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 150,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${totalAmount.toStringAsFixed(0)}", // Hiển thị số tiền
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan, // Màu nút Xuất Hàng (Cyan)
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                ),
                onPressed: onSubmit,
                child: const Text(
                  "Xuất hàng",
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

  Widget _buildInfoRow(String label, String value) {
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
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(2),
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
    // Style cho nút viền (như hình mẫu)
    return ElevatedButton.icon(
      icon: Icon(icon, color: isOutlined ? color : Colors.white),
      label: Text(
        label,
        style: TextStyle(
          color: isOutlined ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.white : color,
        side: isOutlined ? BorderSide(color: Colors.black54) : null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        elevation: 2,
      ),
      onPressed: onTap,
    );
  }
}
