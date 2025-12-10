import 'package:flutter/material.dart';

class StockHistory extends StatelessWidget {
  // Mock Data cho lịch sử
  final List<Map<String, dynamic>> history = [
    {
      'date': '12/12/2024 10:30',
      'type': 'NHAP',
      'id': 'PN59446',
      'product': 'iPhone 15 Pro Max',
      'qty': 20,
      'user': 'Admin',
    },
    {
      'date': '12/12/2024 14:15',
      'type': 'XUAT',
      'id': 'PX2201',
      'product': 'Macbook Air M1',
      'qty': 2,
      'user': 'Nhân viên 1',
    },
    {
      'date': '11/12/2024 09:00',
      'type': 'NHAP',
      'id': 'PN59445',
      'product': 'Samsung S24 Ultra',
      'qty': 15,
      'user': 'Admin',
    },
    {
      'date': '10/12/2024 16:20',
      'type': 'XUAT',
      'id': 'PX2200',
      'product': 'Chuột Logitech',
      'qty': 5,
      'user': 'Nhân viên 2',
    },
  ];

  StockHistory({super.key});

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
                DataCell(Text(item['date'])),
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
                DataCell(Text(item['id'])),
                DataCell(Text(item['product'])),
                DataCell(
                  Text(
                    "${item['qty']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataCell(Text(item['user'])),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
