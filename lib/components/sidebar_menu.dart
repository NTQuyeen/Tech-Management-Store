import 'package:flutter/material.dart';
import '../constants.dart';
import '../screens/login_screen.dart';

class SidebarMenu extends StatelessWidget {
  final String userRole;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SidebarMenu({
    super.key,
    required this.userRole,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.primary, width: 4)),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            color: AppColors.primary,
            alignment: Alignment.center,
            child: const Text(
              "Cửa hàng điện tử",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // --- DANH SÁCH MENU (Đã đánh lại số thứ tự) ---

          // Index 0: Sản phẩm
          _buildItem(0, Icons.phone_android, "Sản phẩm"),

          // ĐÃ XÓA "NHẬP HÀNG" (Cũ là Index 1)

          // Index 1: Xuất hàng (Cũ là 2 -> Giờ thành 1)
          _buildItem(1, Icons.upload, "Xuất hóa đơn"),

          // LOGIC PHÂN QUYỀN: Chỉ Admin mới thấy
          if (userRole == 'admin') ...[
            // Index 2: Nhân viên (Cũ là 3 -> Giờ thành 2)
            _buildItem(2, Icons.people, "Nhân viên"),

            // Index 3: Doanh thu (Cũ là 4 -> Giờ thành 3)
            _buildItem(3, Icons.bar_chart, "Doanh thu"),
          ],

          // Index 4: Kho hàng (Cũ là 5 -> Giờ thành 4)
          _buildItem(4, Icons.warehouse, "Kho hàng"),

          const Spacer(),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Đăng xuất",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildItem(int index, IconData icon, String title) {
    bool isActive = index == selectedIndex;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        border: Border.all(
          color: isActive ? AppColors.primary : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primary : Colors.black87,
          ),
        ),
        onTap: () => onItemSelected(index),
      ),
    );
  }
}
