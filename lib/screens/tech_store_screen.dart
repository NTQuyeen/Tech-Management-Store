import 'package:flutter/material.dart';
import '../models/product.dart';
import '../constants.dart';
import '../components/sidebar_menu.dart';
import '../components/top_header.dart';
import '../components/product_form.dart';
import '../components/product_table.dart';

class TechStoreScreen extends StatefulWidget {
  const TechStoreScreen({super.key});

  @override
  State<TechStoreScreen> createState() => _TechStoreScreenState();
}

class _TechStoreScreenState extends State<TechStoreScreen> {
  // --- DATA ---
  final List<Product> _products = [
    Product(
      id: 'IP001',
      name: 'iPhone 11 Pro Max',
      category: 'Điện thoại',
      quantity: 88,
      price: 15790000,
      status: 'Còn hàng',
      brand: 'Apple',
    ),
    Product(
      id: 'SS001',
      name: 'Samsung S22 Ultra',
      category: 'Điện thoại',
      quantity: 59,
      price: 27050000,
      status: 'Còn hàng',
      brand: 'Samsung',
    ),
  ];
  List<Product> _filteredProducts = [];

  // --- CONTROLLERS ---
  // Controller cho Form nhập liệu (Add/Edit)
  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

  // Controller cho Thanh tìm kiếm bên ngoài
  final _searchCtrl = TextEditingController();

  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _filteredProducts = List.from(_products);
  }

  // --- LOGIC TÌM KIẾM ---
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
      _selectedIndex = null;
    });
  }

  void _onRowSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- LOGIC HIỂN THỊ DIALOG ---

  // 1. Dialog THÊM MỚI
  void _showAddDialog() {
    // Xóa trắng form trước khi mở
    _nameCtrl.clear();
    _idCtrl.clear();
    _priceCtrl.clear();
    _qtyCtrl.clear();
    _categoryCtrl.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Thêm sản phẩm mới"),
        content: SizedBox(
          width: 500, // Độ rộng dialog
          child: ProductForm(
            nameCtrl: _nameCtrl,
            idCtrl: _idCtrl,
            priceCtrl: _priceCtrl,
            qtyCtrl: _qtyCtrl,
            categoryCtrl: _categoryCtrl,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              _saveProduct(); // Gọi hàm lưu
              Navigator.pop(ctx); // Đóng dialog
            },
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 2. Dialog SỬA
  void _showEditDialog() {
    if (_selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn sản phẩm cần sửa!")),
      );
      return;
    }

    // Đổ dữ liệu cũ vào form
    Product p = _filteredProducts[_selectedIndex!];
    _nameCtrl.text = p.name;
    _idCtrl.text = p.id;
    _categoryCtrl.text = p.category;
    _priceCtrl.text = p.price.toStringAsFixed(0);
    _qtyCtrl.text = p.quantity.toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Sửa sản phẩm ${p.id}"),
        content: SizedBox(
          width: 500,
          child: ProductForm(
            nameCtrl: _nameCtrl,
            idCtrl: _idCtrl, // Thường mã SP không cho sửa, nhưng tạm thời cứ để
            priceCtrl: _priceCtrl,
            qtyCtrl: _qtyCtrl,
            categoryCtrl: _categoryCtrl,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              _updateProduct(); // Gọi hàm cập nhật
              Navigator.pop(ctx);
            },
            child: const Text(
              "Cập nhật",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Dialog XÓA
  void _showDeleteDialog() {
    if (_selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn sản phẩm cần xóa!")),
      );
      return;
    }
    Product p = _filteredProducts[_selectedIndex!];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc chắn muốn xóa sản phẩm ${p.name} không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Không"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _deleteProduct();
              Navigator.pop(ctx);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- LOGIC CRUD (Xử lý dữ liệu) ---

  void _saveProduct() {
    if (_nameCtrl.text.isEmpty || _idCtrl.text.isEmpty) return;

    final newProduct = Product(
      id: _idCtrl.text,
      name: _nameCtrl.text,
      category: _categoryCtrl.text.isEmpty ? "Khác" : _categoryCtrl.text,
      quantity: int.tryParse(_qtyCtrl.text) ?? 0,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      status: 'Còn hàng',
      brand: 'Khác',
    );

    setState(() {
      _products.insert(0, newProduct);
      _handleSearch(_searchCtrl.text); // Refresh list
    });
  }

  void _updateProduct() {
    // Logic cập nhật: Tìm trong list gốc và sửa
    Product p = _filteredProducts[_selectedIndex!];
    int indexInOriginal = _products.indexWhere((item) => item.id == p.id);

    if (indexInOriginal != -1) {
      setState(() {
        _products[indexInOriginal].name = _nameCtrl.text;
        _products[indexInOriginal].category = _categoryCtrl.text;
        _products[indexInOriginal].quantity = int.tryParse(_qtyCtrl.text) ?? 0;
        _products[indexInOriginal].price =
            double.tryParse(_priceCtrl.text) ?? 0;

        _handleSearch(_searchCtrl.text); // Refresh UI
        _selectedIndex = null; // Bỏ chọn
      });
    }
  }

  void _deleteProduct() {
    Product p = _filteredProducts[_selectedIndex!];
    setState(() {
      _products.removeWhere((item) => item.id == p.id);
      _handleSearch(_searchCtrl.text);
      _selectedIndex = null;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _searchCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  // --- GIAO DIỆN CHÍNH ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          const SidebarMenu(),
          Expanded(
            child: Column(
              children: [
                const TopHeader(
                  employeeName: "Nguyễn Thiện Quyền",
                  role: "Quản lý",
                ),

                // --- PHẦN THANH CÔNG CỤ (MỚI) ---
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.white,
                  child: Row(
                    children: [
                      // 1. Ô Tìm kiếm
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: _handleSearch, // Gõ đến đâu tìm đến đấy
                          decoration: const InputDecoration(
                            hintText: "Tìm kiếm sản phẩm...",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // 2. Các nút chức năng
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "Thêm",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        onPressed: _showAddDialog,
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          "Sửa",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        onPressed: _showEditDialog,
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          "Xóa",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                        onPressed: _showDeleteDialog,
                      ),
                    ],
                  ),
                ),

                // --- PHẦN BẢNG DỮ LIỆU ---
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ProductTable(
                      data: _filteredProducts,
                      selectedIndex: _selectedIndex,
                      onRowSelected: _onRowSelected,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
