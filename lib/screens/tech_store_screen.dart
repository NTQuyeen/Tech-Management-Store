import 'package:flutter/material.dart';
import '../constants.dart';
import '../components/sidebar_menu.dart';
import '../components/top_header.dart';

import 'product_manager_screen.dart';
import './import_goods/import_goods_screen.dart';
import './export_goods/export_goods_screen.dart';
import './employee/employee_manager_screen.dart';
import './revenue/components/revenue_screen.dart';
import './warehouse/components/warehouse_screen.dart';

class TechStoreScreen extends StatefulWidget {
  final String userRole;
  final String userName;

  const TechStoreScreen({
    super.key,
    required this.userRole,
    required this.userName,
  });

  @override
  State<TechStoreScreen> createState() => _TechStoreScreenState();
}

class _TechStoreScreenState extends State<TechStoreScreen> {
  int _currentMenuIndex = 0;

  bool get _isAdmin => widget.userRole == 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          SidebarMenu(
            userRole: widget.userRole,
            selectedIndex: _currentMenuIndex,
            onItemSelected: (index) {
              // ✅ staff không được vào Nhập hàng + menu admin
              if (!_isAdmin && (index == 1 || index == 3 || index == 4)) return;

              setState(() => _currentMenuIndex = index);
            },
          ),

          Expanded(
            child: Column(
              children: [
                TopHeader(
                  employeeName: widget.userName,
                  role: _isAdmin ? "Quản trị viên" : "Nhân viên",
                ),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentMenuIndex) {
      case 0:
        return ProductManagerScreen(userRole: widget.userRole);

      case 1:
        if (_isAdmin) return const ImportGoodsScreen();
        return const Center(
          child: Text("Bạn không có quyền truy cập Nhập hàng"),
        );

      case 2:
        return const ExportGoodsScreen();

      case 3:
        if (_isAdmin) return const EmployeeManagerScreen();
        return const Center(child: Text("Bạn không có quyền truy cập mục này"));

      case 4:
        if (_isAdmin) return const RevenueScreen();
        return const Center(child: Text("Bạn không có quyền truy cập mục này"));

      case 5:
        return const WarehouseScreen();

      default:
        return const Center(child: Text("Chức năng đang phát triển"));
    }
  }
}
