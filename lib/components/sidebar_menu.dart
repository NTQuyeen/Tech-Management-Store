import 'package:flutter/material.dart';
import '../constants.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

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
          _buildItem(Icons.phone_android, "Sản phẩm", isActive: true),
          _buildItem(Icons.shopping_cart, "Giỏ hàng"),
          _buildItem(Icons.people, "Nhân viên"),
          _buildItem(Icons.bar_chart, "Doanh thu"),
          _buildItem(Icons.warehouse, "Kho hàng"),
          const Spacer(),
          _buildItem(Icons.power_settings_new, "Đăng xuất"),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        border: Border.all(
          color: isActive ? AppColors.primary : Colors.transparent,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {},
      ),
    );
  }
}
