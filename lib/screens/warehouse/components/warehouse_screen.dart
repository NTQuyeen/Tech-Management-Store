import 'package:flutter/material.dart';
import '/../../models/product.dart';
import '../../../constants.dart';
import '../../../services/warehouse_api.dart';

// Import các components
import 'warehouse_stat_card.dart';
import 'inventory_table.dart';
import 'stock_history.dart';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  final WarehouseApi _warehouseApi = WarehouseApi();
  bool _isLoadingInventory = false;
  bool _isLoadingHistory = false;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInventory();
    _loadHistory();
  }

  Future<void> _loadInventory() async {
    if (_isLoadingInventory) return;
    setState(() => _isLoadingInventory = true);

    try {
      final items = await _warehouseApi.getInventory();
      setState(() {
        _products = items;
        _filteredProducts = List.from(items);
      });
    } catch (e) {
      _showError('Không tải được tồn kho: $e');
    } finally {
      if (mounted) setState(() => _isLoadingInventory = false);
    }
  }

  Future<void> _loadHistory() async {
    if (_isLoadingHistory) return;
    setState(() => _isLoadingHistory = true);

    try {
      final items = await _warehouseApi.getStockHistory();
      setState(() => _history = items);
    } catch (e) {
      _showError('Không tải được lịch sử nhập/xuất: $e');
    } finally {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  void _handleSearch(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredProducts = List.from(_products);
      } else {
        _filteredProducts = _products
            .where(
              (p) =>
                  p.name.toLowerCase().contains(value.toLowerCase()) ||
                  p.id.toLowerCase().contains(value.toLowerCase()),
            )
            .toList();
      }
    });
  }

  // Tính toán thống kê
  int get _totalStock => _products.fold(0, (sum, item) => sum + item.quantity);
  double get _totalValue =>
      _products.fold(0, (sum, item) => sum + (item.quantity * item.price));
  int get _lowStockCount =>
      _products.where((item) => item.quantity < 10).length;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // 1. THẺ THỐNG KÊ (STATS)
          Row(
            children: [
              WarehouseStatCard(
                title: "TỔNG TỒN KHO",
                value: "$_totalStock sản phẩm",
                icon: Icons.inventory_2,
                color: Colors.blue,
                bgColor: Colors.blue.shade50,
              ),
              const SizedBox(width: 20),
              WarehouseStatCard(
                title: "GIÁ TRỊ KHO",
                value:
                    "${(_totalValue / 1000000000).toStringAsFixed(2)} Tỷ VNĐ",
                icon: Icons.monetization_on,
                color: Colors.green,
                bgColor: Colors.green.shade50,
              ),
              const SizedBox(width: 20),
              WarehouseStatCard(
                title: "SẮP HẾT HÀNG (<10)",
                value: "$_lowStockCount mặt hàng",
                icon: Icons.warning_amber_rounded,
                color: Colors.red,
                bgColor: Colors.red.shade50,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. THANH CÔNG CỤ & TAB
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                // Tab Selector
                Container(
                  width: 300,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black54,
                    tabs: const [
                      Tab(text: "Danh sách Tồn kho"),
                      Tab(text: "Lịch sử Nhập/Xuất"),
                    ],
                  ),
                ),
                const Spacer(),

                // Ô tìm kiếm
                SizedBox(
                  width: 300,
                  height: 40,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _handleSearch,
                    decoration: const InputDecoration(
                      hintText: "Tìm kiếm sản phẩm...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    _loadInventory();
                    _loadHistory();
                  },
                  icon: const Icon(Icons.print, color: Colors.grey),
                  tooltip: "In báo cáo",
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.file_download, color: Colors.green),
                  tooltip: "Xuất Excel",
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // 3. NỘI DUNG TAB (TABLES)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Bảng tồn kho
                _isLoadingInventory
                    ? const Center(child: CircularProgressIndicator())
                    : InventoryTable(products: _filteredProducts),

                // Tab 2: Lịch sử
                _isLoadingHistory
                    ? const Center(child: CircularProgressIndicator())
                    : StockHistory(history: _history),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
