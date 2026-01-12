import 'package:flutter/material.dart';
import '../constants.dart';
import '../components/sidebar_menu.dart';
import '../components/top_header.dart';

// Import màn hình chức năng
import 'product_manager_screen.dart';
// ĐÃ XÓA IMPORT MÀN HÌNH NHẬP HÀNG
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // SIDEBAR
          SidebarMenu(
            userRole: widget.userRole,
            selectedIndex: _currentMenuIndex,
            onItemSelected: (index) {
              setState(() => _currentMenuIndex = index);
            },
          ),

          // MAIN CONTENT
          Expanded(
            child: Column(
              children: [
                TopHeader(
                  employeeName: widget.userName,
                  role: widget.userRole == 'admin'
                      ? "Quản trị viên"
                      : "Nhân viên",
                ),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hàm điều hướng (Đã cập nhật lại Index)
  Widget _buildBody() {
    switch (_currentMenuIndex) {
      case 0:
        return ProductManagerScreen(userRole: widget.userRole);

      // Case 1 cũ là Nhập hàng -> Đã xóa

      case 1: // Cũ là 2
        return const ExportGoodsScreen();

      case 2: // Cũ là 3
        return const EmployeeManagerScreen();

      case 3: // Cũ là 4
        return const RevenueScreen();

      case 4: // Cũ là 5
        return const WarehouseScreen();

      default:
        return const Center(child: Text("Chức năng đang phát triển"));
    }
  }
}
