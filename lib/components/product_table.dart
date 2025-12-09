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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Colors.white,
      ),
      child: ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(
            AppColors.primary.withOpacity(0.6),
          ),
          thickness: MaterialStateProperty.all(10),
          radius: const Radius.circular(10),
        ),
        child: Scrollbar(
          controller: _verticalScrollController,
          thumbVisibility: true,
          trackVisibility: true,
          child: SingleChildScrollView(
            controller: _verticalScrollController,
            scrollDirection: Axis.vertical,
            child: Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              notificationPredicate: (notif) => notif.depth == 1,
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  showCheckboxColumn: false,
                  headingRowColor: MaterialStateProperty.all(Colors.grey[300]),
                  border: TableBorder.all(color: Colors.grey.shade300),

                  // --- CÒN LẠI 8 CỘT (Đã xóa cột Hình ảnh) ---
                  columns: const [
                    DataColumn(
                      label: Text(
                        'STT',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                      label: Text(
                        'Số lượng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Trạng thái',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Đơn giá',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Thương hiệu',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],

                  // --- CÒN LẠI 8 Ô (Đã xóa ô Hình ảnh) ---
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
                        states,
                      ) {
                        if (isSelected) return AppColors.primary;
                        return index % 2 == 0 ? Colors.white : Colors.grey[100];
                      }),
                      cells: [
                        DataCell(Text('${index + 1}', style: textStyle)),
                        DataCell(Text(product.name, style: textStyle)),
                        DataCell(Text(product.id, style: textStyle)),
                        DataCell(Text(product.category, style: textStyle)),
                        DataCell(Text('${product.quantity}', style: textStyle)),
                        DataCell(
                          Text(
                            product.status,
                            style: textStyle.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : (product.status == 'Hết hàng'
                                        ? Colors.red
                                        : Colors.green),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${product.price.toStringAsFixed(0)}',
                            style: textStyle,
                          ),
                        ),
                        DataCell(Text(product.brand, style: textStyle)),
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
  }
}
