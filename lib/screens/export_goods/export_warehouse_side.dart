import 'package:flutter/material.dart';
import '../../constants.dart';

class ExportWarehouseSide extends StatelessWidget {
  // products: { id(INT), code(String), name, price(num), qty(int) }
  final List<Map<String, dynamic>> products;

  // Callbacks
  final VoidCallback onAddProduct;
  final Function(int index)? onEditProduct;
  final Function(int index)? onRemoveProduct;

  const ExportWarehouseSide({
    super.key,
    required this.products,
    required this.onAddProduct,
    this.onEditProduct,
    this.onRemoveProduct,
  });

  String _formatMoney(num value) {
    final s = value.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (m) => '${m[1]}.');
  }

  num get _totalAmount {
    return products.fold<num>(
      0,
      (sum, p) => sum + ((p['price'] ?? 0) * (p['qty'] ?? 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ===== HEADER =====
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.list_alt, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  "DANH SÁCH SẢN PHẨM",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // ===== BODY =====
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // ===== TABLE =====
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                              const Color(0xFFE0F2F1),
                            ),
                            columnSpacing: 20,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Tên sản phẩm',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                              DataColumn(
                                numeric: true,
                                label: Text(
                                  'Đơn giá',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                              DataColumn(
                                numeric: true,
                                label: Text(
                                  'SL',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                              DataColumn(
                                numeric: true,
                                label: Text(
                                  'Thành tiền',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Thao tác',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                            ],
                            rows: products.asMap().entries.map((entry) {
                              final index = entry.key;
                              final product = entry.value;

                              final price = (product['price'] ?? 0) as num;
                              final qty = (product['qty'] ?? 0) as num;
                              final total = price * qty;

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      (product['name'] ?? '').toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _formatMoney(price),
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '$qty',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _formatMoney(total),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          tooltip: "Sửa",
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 18,
                                            color: Colors.orange,
                                          ),
                                          onPressed: onEditProduct == null
                                              ? null
                                              : () => onEditProduct!(index),
                                        ),
                                        IconButton(
                                          tooltip: "Xóa",
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          onPressed: onRemoveProduct == null
                                              ? null
                                              : () => onRemoveProduct!(index),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ===== TOTAL =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TỔNG CỘNG",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatMoney(_totalAmount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // ===== ADD BUTTON =====
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text("Thêm sản phẩm"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 3,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: onAddProduct,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
