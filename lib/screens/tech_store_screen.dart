import 'package:flutter/material.dart';
import '../constants.dart';
import '../components/sidebar_menu.dart';
import '../components/top_header.dart';
// Import màn hình quản lý sản phẩm vừa tách
import 'product_manager_screen.dart';
// 2. Import màn hình Nhập hàng (VỪA MỚI TÁCH XONG)
import './import_goods/import_goods_screen.dart';
import './export_goods/export_goods_screen.dart';
import './employee/employee_manager_screen.dart';
import './revenue/components/revenue_screen.dart';
import './warehouse/components/warehouse_screen.dart';

class TechStoreScreen extends StatefulWidget {
  const TechStoreScreen({super.key});

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
          // 1. SIDEBAR
          SidebarMenu(
            selectedIndex: _currentMenuIndex,
            onItemSelected: (index) {
              setState(() => _currentMenuIndex = index);
            },
          ),

          // 2. MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                const TopHeader(
                  employeeName: "Nguyễn Thiện Quyền",
                  role: "Quản lý",
                ),

                // Nội dung thay đổi theo Menu
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
        return const ProductManagerScreen(); // Gọi màn hình đã tách
      case 1:
        return const ImportGoodsScreen();
      case 2:
        return const ExportGoodsScreen();
      case 3:
        return const EmployeeManagerScreen();
      case 4:
        return const RevenueScreen();
      case 5:
        return const WarehouseScreen();
      default:
        return const Center(child: Text("Coming Soon"));
    }
  }

  // Widget _buildPlaceholder(String title) {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(Icons.construction, size: 80, color: Colors.grey[300]),
  //         const SizedBox(height: 20),
  //         Text(
  //           title,
  //           style: TextStyle(
  //             fontSize: 24,
  //             color: Colors.grey[600],
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
