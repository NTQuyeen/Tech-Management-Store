import 'package:flutter/material.dart';
import '../models/product.dart';
import '../constants.dart';

class ProductTable extends StatefulWidget {
  final List<Product> data;
  final int? selectedIndex;
  final Function(int) onRowSelected;

  const ProductTable({
    super.key,
    required this.data,
    this.selectedIndex,
    required this.onRowSelected,
  });

  @override
  State<ProductTable> createState() => _ProductTableState();
}

class _ProductTableState extends State<ProductTable> {
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  String _formatCurrency(double price) {
    String priceStr = price.toInt().toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return priceStr.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Colors.white,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ScrollbarTheme(
            data: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all(
                AppColors.primary.withOpacity(0.6),
              ),
              thickness: WidgetStateProperty.all(10),
              radius: const Radius.circular(10),
            ),
            child: Scrollbar(
              controller: _verticalScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              child: SingleChildScrollView(
                controller: _verticalScrollController,
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  notificationPredicate: (notif) => notif.depth == 1,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        showCheckboxColumn: false,
                        headingRowColor: MaterialStateProperty.all(
                          Colors.grey[300],
                        ),
                        border: TableBorder.all(color: Colors.grey.shade300),
                        columnSpacing: 20,
                        columns: const [
                          DataColumn(
                            label: Center(
                              child: Text(
                                'STT',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Tên sản phẩm',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Mã SP',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Loại',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            numeric: true,
                            label: Text(
                              'Số lượng',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            numeric: true,
                            label: Text(
                              'Đơn giá',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: widget.data.asMap().entries.map((entry) {
                          int index = entry.key;
                          Product product = entry.value;
                          bool isSelected = index == widget.selectedIndex;

                          TextStyle textStyle = TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 14,
                          );

                          return DataRow(
                            selected: isSelected,
                            onSelectChanged: (_) => widget.onRowSelected(index),
                            color: MaterialStateProperty.resolveWith<Color?>((
                              _,
                            ) {
                              if (isSelected) return AppColors.primary;
                              return index % 2 == 0
                                  ? Colors.white
                                  : Colors.grey[100];
                            }),
                            cells: [
                              DataCell(
                                Center(
                                  child: Text('${index + 1}', style: textStyle),
                                ),
                              ),
                              DataCell(Text(product.name, style: textStyle)),

                              // ✅ MÃ SP ĐÚNG
                              DataCell(
                                Text(product.productCode, style: textStyle),
                              ),

                              DataCell(
                                Text(product.category, style: textStyle),
                              ),
                              DataCell(
                                Text('${product.quantity}', style: textStyle),
                              ),
                              DataCell(
                                Text(
                                  _formatCurrency(product.price),
                                  style: textStyle,
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
            ),
          );
        },
      ),
    );
  }
}
