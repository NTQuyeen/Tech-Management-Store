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

  bool get _isAdmin => userRole == 'admin';

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

          // Index 0: Sản phẩm
          _buildItem(0, Icons.phone_android, "Sản phẩm"),

          // ✅ Index 1: Nhập hàng - CHỈ ADMIN
          if (_isAdmin) _buildItem(1, Icons.download, "Nhập hàng"),

          // Index 2: Xuất hóa đơn
          _buildItem(2, Icons.upload, "Xuất hóa đơn"),

          // Chỉ Admin mới thấy
          if (_isAdmin) ...[
            // Index 3: Nhân viên
            _buildItem(3, Icons.people, "Nhân viên"),
            // Index 4: Doanh thu
            _buildItem(4, Icons.bar_chart, "Doanh thu"),
          ],

          // Index 5: Kho hàng (ai cũng thấy)
          _buildItem(5, Icons.warehouse, "Kho hàng"),

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
    final bool isActive = index == selectedIndex;

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
