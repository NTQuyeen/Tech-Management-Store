import 'package:flutter/material.dart';
import '../../models/product.dart';
// Import 2 component vừa tách
import 'warehouse_side.dart';
import 'receipt_side.dart';

class ImportGoodsScreen extends StatefulWidget {
  const ImportGoodsScreen({super.key});

  @override
  State<ImportGoodsScreen> createState() => _ImportGoodsScreenState();
}

class _ImportGoodsScreenState extends State<ImportGoodsScreen> {
  // --- DỮ LIỆU ---
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
      id: 'LP14',
      name: 'Macbook Air M1',
      category: 'Laptop',
      quantity: 8,
      price: 18490000,
      status: 'Còn hàng',
      brand: 'Apple',
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
    Product(
      id: 'SS24',
      name: 'Samsung Galaxy S24',
      category: 'Điện thoại',
      quantity: 15,
      price: 22990000,
      status: 'Còn hàng',
      brand: 'Samsung',
    ),
  ];
  List<Product> _filteredWarehouse = [];
  final List<Map<String, dynamic>> _importItems = [];
  final List<String> _suppliers = [
    'Công Ty TNHH Điều Khiển Tự Động An Phát',
    'Công Ty Cổ Phần FPT',
    'Nhà Phân Phối DigiWorld',
  ];

  // --- CONTROLLERS ---
  final _searchCtrl = TextEditingController();
  final _qtyInputCtrl = TextEditingController();

  // --- STATE ---
  String _selectedSupplier = 'Công Ty TNHH Điều Khiển Tự Động An Phát';
  int? _selectedWarehouseIndex;
  int? _selectedImportIndex;

  @override
  void initState() {
    super.initState();
    _filteredWarehouse = List.from(_warehouseProducts);
  }

  // --- LOGIC XỬ LÝ ---

  void _handleSearch(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredWarehouse = List.from(_warehouseProducts);
      } else {
        _filteredWarehouse = _warehouseProducts
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

  void _addToImportList() {
    if (_selectedWarehouseIndex == null)
      return _showSnack("Vui lòng chọn sản phẩm cần thêm!");
    int qty = int.tryParse(_qtyInputCtrl.text) ?? 0;
    if (qty <= 0) return _showSnack("Số lượng phải lớn hơn 0");

    Product selectedProduct = _filteredWarehouse[_selectedWarehouseIndex!];
    setState(() {
      int existingIndex = _importItems.indexWhere(
        (item) => item['product'].id == selectedProduct.id,
      );
      if (existingIndex != -1) {
        _importItems[existingIndex]['quantity'] += qty;
      } else {
        _importItems.add({
          'product': selectedProduct,
          'quantity': qty,
          'price': selectedProduct.price,
        });
      }
      _qtyInputCtrl.clear();
      _selectedWarehouseIndex = null;
    });
  }

  void _editImportQuantity() {
    if (_selectedImportIndex == null)
      return _showSnack("Chọn sản phẩm để sửa số lượng!");
    final currentItem = _importItems[_selectedImportIndex!];
    final editCtrl = TextEditingController(
      text: currentItem['quantity'].toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Sửa số lượng: ${currentItem['product'].name}"),
        content: TextField(
          controller: editCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Số lượng mới",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              int newQty = int.tryParse(editCtrl.text) ?? 0;
              if (newQty > 0) {
                setState(
                  () =>
                      _importItems[_selectedImportIndex!]['quantity'] = newQty,
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _removeImportItem() {
    if (_selectedImportIndex == null)
      return _showSnack("Chọn sản phẩm để xóa!");
    setState(() {
      _importItems.removeAt(_selectedImportIndex!);
      _selectedImportIndex = null;
    });
  }

  void _createReceipt() {
    if (_importItems.isEmpty) return _showSnack("Danh sách nhập đang trống!");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Thành công"),
        content: const Text("Đã tạo phiếu nhập hàng!"),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _importItems.clear();
                _selectedImportIndex = null;
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
    for (var item in _importItems) {
      total += (item['quantity'] as int) * (item['price'] as double);
    }
    return total;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  // --- GIAO DIỆN CHÍNH (GẮN 2 COMPONENT LẠI) ---
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Component TRÁI
        Expanded(
          flex: 5,
          child: WarehouseSide(
            products: _filteredWarehouse,
            searchCtrl: _searchCtrl,
            qtyCtrl: _qtyInputCtrl,
            selectedIndex: _selectedWarehouseIndex,
            onSearch: _handleSearch,
            onSelectRow: (index) =>
                setState(() => _selectedWarehouseIndex = index),
            onAdd: _addToImportList,
          ),
        ),

        const VerticalDivider(width: 1, thickness: 1, color: Colors.grey),

        // Component PHẢI
        Expanded(
          flex: 6,
          child: ReceiptSide(
            importItems: _importItems,
            suppliers: _suppliers,
            selectedSupplier: _selectedSupplier,
            selectedIndex: _selectedImportIndex,
            totalAmount: _totalAmount,
            onSupplierChanged: (val) =>
                setState(() => _selectedSupplier = val!),
            onSelectRow: (index) =>
                setState(() => _selectedImportIndex = index),
            onRemove: _removeImportItem,
            onEditQty: _editImportQuantity,
            onExportExcel: () =>
                print("Xuất Excel"), // Logic Excel chưa cần làm
            onSubmit: _createReceipt,
          ),
        ),
      ],
    );
  }
}
