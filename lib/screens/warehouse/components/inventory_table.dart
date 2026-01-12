import 'package:flutter/material.dart';
import '../../../models/product.dart';

class InventoryTable extends StatelessWidget {
  final List<Product> products;

  const InventoryTable({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(5),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
          dataRowHeight: 60,
          columns: const [
            DataColumn(
              label: Text("STT", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text(
                "Mã SP",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Tên sản phẩm",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Danh mục",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Tồn kho",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                "Trạng thái",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: List.generate(products.length, (index) {
            final p = products[index];
            // Logic cảnh báo: Nếu tồn kho < 10 thì tô đỏ
            final isLowStock = p.quantity < 10;

            return DataRow(
              cells: [
                DataCell(Text("${index + 1}")),
                DataCell(Text(p.id)),
                DataCell(
                  Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(Text(p.category)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isLowStock
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "${p.quantity}",
                      style: TextStyle(
                        color: isLowStock ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  isLowStock
                      ? const Text(
                          "Sắp hết hàng",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        )
                      : const Text(
                          "Ổn định",
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
