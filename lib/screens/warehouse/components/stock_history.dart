import 'package:flutter/material.dart';

class StockHistory extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const StockHistory({super.key, required this.history});

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
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
          columns: const [
            DataColumn(label: Text("Thời gian")),
            DataColumn(label: Text("Loại phiếu")),
            DataColumn(label: Text("Mã phiếu")),
            DataColumn(label: Text("Sản phẩm")),
            DataColumn(label: Text("SL")),
            DataColumn(label: Text("Người thực hiện")),
          ],
          rows: history.map((item) {
            bool isImport = item['type'] == 'NHAP';
            return DataRow(
              cells: [
                DataCell(Text((item['date'] ?? '').toString())),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isImport ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isImport ? "Nhập hàng" : "Xuất hàng",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(Text((item['id'] ?? '').toString())),
                DataCell(Text((item['product'] ?? '').toString())),
                DataCell(
                  Text(
                    "${item['qty'] ?? ''}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataCell(Text((item['user'] ?? '').toString())),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
