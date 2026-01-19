import 'package:flutter/material.dart';
import '/../../models/product.dart';
import '../../../constants.dart';
import '../../../services/warehouse_api.dart';

// Import các components
import 'warehouse_stat_card.dart';
import 'inventory_table.dart';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  final WarehouseApi _warehouseApi = WarehouseApi();
  bool _isLoadingInventory = false;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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

  void _handleSearch(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _filteredProducts = List.from(_products);
      } else {
        final q = value.toLowerCase();
        _filteredProducts = _products.where((item) {
          final name = item.name.toLowerCase();
          final code = item.productCode.toLowerCase();
          return name.contains(q) || code.contains(q);
        }).toList();
      }
    });
  }

  // ✅ Kho tính theo STOCK
  int get _totalStock => _products.fold(0, (sum, item) => sum + item.stock);

  double get _totalValue =>
      _products.fold(0, (sum, item) => sum + (item.stock * item.price));

  int get _lowStockCount => _products.where((item) => item.stock < 10).length;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // 1) THỐNG KÊ
          Row(
            children: [
              Expanded(
                child: WarehouseStatCard(
                  title: "Tổng tồn kho",
                  value: _totalStock.toString(),
                  icon: Icons.inventory_2_outlined,
                  color: Colors.blue,
                  bgColor: Colors.blue.withOpacity(0.12),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: WarehouseStatCard(
                  title: "Tổng giá trị kho",
                  value: _formatCurrency(_totalValue),
                  icon: Icons.attach_money,
                  color: Colors.green,
                  bgColor: Colors.green.withOpacity(0.12),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: WarehouseStatCard(
                  title: "Sắp hết hàng",
                  value: _lowStockCount.toString(),
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                  bgColor: Colors.orange.withOpacity(0.12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // 2) HEADER + SEARCH
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  "Danh sách Tồn kho",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                SizedBox(
                  width: 300,
                  height: 40,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _handleSearch,
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm sản phẩm...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // 3) BẢNG TỒN KHO
          Expanded(
            child: _isLoadingInventory
                ? const Center(child: CircularProgressIndicator())
                : InventoryTable(products: _filteredProducts),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final s = amount.toStringAsFixed(0);
    final withDots = s.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return "$withDots đ";
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
