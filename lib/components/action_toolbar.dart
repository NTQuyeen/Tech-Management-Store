import 'package:flutter/material.dart';
import '../widgets/action_button.dart';

class ActionToolbar extends StatelessWidget {
  // Khai báo các hành động (Callback) có thể xảy ra
  // Dấu '?' nghĩa là có thể null (nếu chưa muốn xử lý nút đó)
  final VoidCallback? onDisplayTap;
  final VoidCallback? onCreateInvoiceTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onCancelTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onBuyTap;

  const ActionToolbar({
    super.key,
    this.onDisplayTap,
    this.onCreateInvoiceTap,
    this.onDeleteTap,
    this.onCancelTap,
    this.onSearchTap,
    this.onBuyTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45, // Chiều cao cố định cho hàng nút
      child: Row(
        children: [
          // Nút Display (Thường dùng để Refresh hoặc Thêm mới như bạn muốn)
          ActionButton(
            label: "Thêm Mới",
            onPressed:
                onDisplayTap ?? () {}, // Nếu null thì hàm rỗng (không làm gì)
          ),
          const SizedBox(width: 5),

          // Nút Tạo hóa đơn
          ActionButton(
            label: "Tạo hóa đơn",
            onPressed: onCreateInvoiceTap ?? () {},
          ),
          const SizedBox(width: 5),

          // Nút Xóa
          ActionButton(label: "Xóa", onPressed: onDeleteTap ?? () {}),
          const SizedBox(width: 5),

          // Nút Hủy (Reset form)
          ActionButton(label: "Hủy", onPressed: onCancelTap ?? () {}),
          const SizedBox(width: 5),

          // Nút Tìm kiếm
          ActionButton(label: "Tìm kiếm", onPressed: onSearchTap ?? () {}),
          const SizedBox(width: 5),

          // Nút Mua (POS)
          ActionButton(label: "Mua", onPressed: onBuyTap ?? () {}),
        ],
      ),
    );
  }
}
