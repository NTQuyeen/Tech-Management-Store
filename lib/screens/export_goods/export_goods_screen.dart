import 'package:flutter/material.dart';
import '../../models/product.dart';
// Import 2 component vừa tạo
import 'export_warehouse_side.dart';
import 'export_receipt_side.dart';

class ExportGoodsScreen extends StatefulWidget {
  const ExportGoodsScreen({super.key});

  @override
  State<ExportGoodsScreen> createState() => _ExportGoodsScreenState();
}

class _ExportGoodsScreenState extends State<ExportGoodsScreen> {
  // --- DỮ LIỆU GIẢ ---
  final List<Product> _warehouseProducts = [
    Product(
      id: 'LP10',
      name: 'Laptop Lenovo IdeaPad Gaming 3',
      category: 'Laptop',
      quantity: 10,
      price: 23490000,
      status: 'Còn hàng',
      brand: 'Lenovo',
    ),
    Product(
      id: 'LP12',
      name: 'Laptop MSI Modern 14',
      category: 'Laptop',
      quantity: 10,
      price: 13090000,
      status: 'Còn hàng',
      brand: 'MSI',
    ),
    Product(
      id: 'IP15',
      name: 'iPhone 15 Pro Max',
      category: 'Điện thoại',
      quantity: 20,
      price: 31990000,
      status: 'Còn hàng',
      brand: 'Apple',
    ),
  ];
  List<Product> _filteredProducts = [];
  final List<Map<String, dynamic>> _exportItems = [];

  // --- CONTROLLERS ---
  final _searchCtrl = TextEditingController();
  final _qtyInputCtrl = TextEditingController();

  // --- STATE ---
  int? _selectedWarehouseIndex;
  int? _selectedExportIndex;

  @override
  void initState() {
    super.initState();
    _filteredProducts = List.from(_warehouseProducts);
  }

  // LOGIC
  void _handleSearch(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredProducts = List.from(_warehouseProducts);
      } else {
        _filteredProducts = _warehouseProducts
            .where(
              (p) =>
                  p.name.toLowerCase().contains(value.toLowerCase()) ||
                  p.id.toLowerCase().contains(value.toLowerCase()),
            )
            .toList();
      }
      _selectedWarehouseIndex = null;
    });
  }

  void _addToExportList() {
    if (_selectedWarehouseIndex == null)
      return _showSnack("Vui lòng chọn sản phẩm để xuất!");
    int qty = int.tryParse(_qtyInputCtrl.text) ?? 0;
    Product selectedProduct = _filteredProducts[_selectedWarehouseIndex!];

    // Kiểm tra tồn kho
    if (qty <= 0) return _showSnack("Số lượng phải lớn hơn 0");
    if (qty > selectedProduct.quantity)
      return _showSnack("Tồn kho không đủ (Còn: ${selectedProduct.quantity})");

    setState(() {
      int existingIndex = _exportItems.indexWhere(
        (item) => item['product'].id == selectedProduct.id,
      );
      if (existingIndex != -1) {
        int newTotal = _exportItems[existingIndex]['quantity'] + qty;
        if (newTotal > selectedProduct.quantity) {
          _showSnack("Tổng số lượng xuất vượt quá tồn kho!");
          return;
        }
        _exportItems[existingIndex]['quantity'] = newTotal;
      } else {
        _exportItems.add({
          'product': selectedProduct,
          'quantity': qty,
          'price': selectedProduct.price,
        });
      }
      _qtyInputCtrl.clear();
      _selectedWarehouseIndex = null;
    });
  }

  void _editExportQuantity() {
    if (_selectedExportIndex == null) return _showSnack("Chọn dòng để sửa!");
    final currentItem = _exportItems[_selectedExportIndex!];
    final editCtrl = TextEditingController(
      text: currentItem['quantity'].toString(),
    );
    final product = currentItem['product'] as Product;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Sửa số lượng: ${product.name}"),
        content: TextField(
          controller: editCtrl,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              int newQty = int.tryParse(editCtrl.text) ?? 0;
              if (newQty > 0 && newQty <= product.quantity) {
                setState(
                  () =>
                      _exportItems[_selectedExportIndex!]['quantity'] = newQty,
                );
                Navigator.pop(ctx);
              } else {
                // Có thể hiện thông báo lỗi trong dialog nếu muốn
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _removeExportItem() {
    if (_selectedExportIndex == null) return _showSnack("Chọn dòng để xóa!");
    setState(() {
      _exportItems.removeAt(_selectedExportIndex!);
      _selectedExportIndex = null;
    });
  }

  void _createExportReceipt() {
    if (_exportItems.isEmpty) return _showSnack("Danh sách xuất đang trống!");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Thành công"),
        content: const Text("Đã tạo phiếu xuất hàng thành công!"),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _exportItems.clear();
                _selectedExportIndex = null;
              });
              Navigator.pop(ctx);
            },
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  double get _totalAmount {
    double total = 0;
    for (var item in _exportItems) {
      total += (item['quantity'] as int) * (item['price'] as double);
    }
    return total;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // TRÁI: KHO HÀNG
        Expanded(
          flex: 5,
          child: ExportWarehouseSide(
            products: _filteredProducts,
            searchCtrl: _searchCtrl,
            qtyCtrl: _qtyInputCtrl,
            selectedIndex: _selectedWarehouseIndex,
            onSearch: _handleSearch,
            onSelectRow: (index) =>
                setState(() => _selectedWarehouseIndex = index),
            onAdd: _addToExportList,
          ),
        ),

        const VerticalDivider(width: 1, thickness: 1, color: Colors.grey),

        // PHẢI: PHIẾU XUẤT
        Expanded(
          flex: 6,
          child: ExportReceiptSide(
            exportItems: _exportItems,
            selectedIndex: _selectedExportIndex,
            totalAmount: _totalAmount,
            onSelectRow: (index) =>
                setState(() => _selectedExportIndex = index),
            onRemove: _removeExportItem,
            onEditQty: _editExportQuantity,
            onExportExcel: () => print("Xuất Excel"), // Placeholder
            onSubmit: _createExportReceipt,
          ),
        ),
      ],
    );
  }
}
