import 'package:flutter/material.dart';
import '../../../models/product.dart';

class InventoryTable extends StatelessWidget {
  final List<Product> products;

  const InventoryTable({super.key, required this.products});

  String _money(num v) {
    final s = v.toStringAsFixed(0);
    final chars = s.split('');
    final out = <String>[];
    for (int i = 0; i < chars.length; i++) {
      out.add(chars[i]);
      final posFromEnd = chars.length - 1 - i;
      if (posFromEnd % 3 == 0 && i != chars.length - 1) out.add('.');
    }
    return out.join();
  }

  num _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  Widget _cellText(
    String text, {
    double? width,
    TextAlign align = TextAlign.left,
    FontWeight? weight,
    Color? color,
    int maxLines = 1,
  }) {
    final w = width;
    final t = Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      textAlign: align,
      style: TextStyle(fontWeight: weight, color: color),
    );

    if (w == null) return t;

    return SizedBox(
      width: w,
      child: Align(
        alignment: align == TextAlign.right
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: t,
      ),
    );
  }

  /// số thì dùng FittedBox để tự co khi chật
  Widget _cellNumber(String text, {double width = 70, FontWeight? weight}) {
    return SizedBox(
      width: width,
      child: Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(text, style: TextStyle(fontWeight: weight)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ lấy width màn hình để chia cột hợp lý
    final screenW = MediaQuery.of(context).size.width;

    // Bạn có thể chỉnh các width này tùy UI:
    final wStt = 42.0;
    final wCode = 70.0;
    final wName = (screenW * 0.22).clamp(140.0, 220.0);
    final wCate = (screenW * 0.14).clamp(90.0, 150.0);
    final wStock = 72.0;
    final wPriceIn = 92.0;
    final wTotal = 100.0;
    final wStatus = (screenW * 0.12).clamp(90.0, 130.0);

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
          // ✅ giảm khoảng cách để tránh overflow
          horizontalMargin: 8,
          columnSpacing: 8,

          // ✅ giảm chiều cao dòng để gọn
          dataRowMinHeight: 48,
          dataRowMaxHeight: 56,
          headingRowHeight: 44,

          headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
          columns: [
            DataColumn(
              label: _cellText("STT", width: wStt, weight: FontWeight.bold),
            ),
            DataColumn(
              label: _cellText("Mã", width: wCode, weight: FontWeight.bold),
            ),
            DataColumn(
              label: _cellText(
                "Tên sản phẩm",
                width: wName,
                weight: FontWeight.bold,
              ),
            ),
            DataColumn(
              label: _cellText(
                "Danh mục",
                width: wCate,
                weight: FontWeight.bold,
              ),
            ),
            DataColumn(
              numeric: true,
              label: _cellText(
                "Kho",
                width: wStock,
                align: TextAlign.right,
                weight: FontWeight.bold,
              ),
            ),
            DataColumn(
              numeric: true,
              label: _cellText(
                "Giá nhập",
                width: wPriceIn,
                align: TextAlign.right,
                weight: FontWeight.bold,
              ),
            ),
            DataColumn(
              numeric: true,
              label: _cellText(
                "Giá trị",
                width: wTotal,
                align: TextAlign.right,
                weight: FontWeight.bold,
              ),
            ),
            DataColumn(
              label: _cellText(
                "Trạng Thái",
                width: wStatus,
                weight: FontWeight.bold,
              ),
            ),
          ],
          rows: List.generate(products.length, (index) {
            final p = products[index];

            final stock = p.stock;
            final isLowStock = stock < 10;

            // nếu model Product có field priceIn thì dùng được,
            // còn không có thì sẽ ra 0
            final priceIn = _toNum((p as dynamic).priceIn);
            final totalValue = priceIn * stock;

            return DataRow(
              cells: [
                DataCell(_cellText("${index + 1}", width: wStt)),
                DataCell(
                  _cellText(
                    p.productCode,
                    width: wCode,
                    weight: FontWeight.w600,
                  ),
                ),
                DataCell(
                  _cellText(p.name, width: wName, weight: FontWeight.w500),
                ),
                DataCell(_cellText(p.category, width: wCate)),
                DataCell(
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isLowStock
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _cellNumber(
                        "$stock",
                        width: wStock - 12,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  _cellNumber(
                    _money(priceIn),
                    width: wPriceIn,
                    weight: FontWeight.w600,
                  ),
                ),
                DataCell(
                  _cellNumber(
                    _money(totalValue),
                    width: wTotal,
                    weight: FontWeight.w700,
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: wStatus,
                    child: Text(
                      isLowStock ? "Sắp hết" : "Ổn Định",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isLowStock ? Colors.red : Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
