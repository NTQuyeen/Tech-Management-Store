import 'package:flutter/material.dart';
import '../constants.dart'; // Chứa AppColors

class SidebarMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SidebarMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          // Logo hoặc tên app
          Container(
            height: 60,
            alignment: Alignment.center,
            color: AppColors.primary,
            child: const Text(
              "Cửa hàng điện tử",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Danh sách Menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(0, "Sản phẩm", Icons.phone_android),
                // --- THAY ĐỔI TẠI ĐÂY ---
                _buildMenuItem(
                  1,
                  "Nhập hàng",
                  Icons.add_business,
                ), // Thay cho Giỏ hàng
                _buildMenuItem(
                  2,
                  "Xuất hàng",
                  Icons.local_shipping,
                ), // Mới thêm
                _buildMenuItem(3, "Nhân viên", Icons.people),
                _buildMenuItem(4, "Doanh thu", Icons.bar_chart),
                _buildMenuItem(5, "Kho hàng", Icons.warehouse),
              ],
            ),
          ),

          // Nút đăng xuất ở dưới cùng
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.grey),
            title: const Text(
              "Đăng xuất",
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () {
              // Xử lý đăng xuất
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, String title, IconData icon) {
    final isSelected = index == selectedIndex;
    return Container(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : Colors.transparent, // Highlight mục đang chọn
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => onItemSelected(index), // Gọi hàm callback
      ),
    );
  }
}
