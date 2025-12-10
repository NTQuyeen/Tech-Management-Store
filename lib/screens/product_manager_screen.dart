import 'package:flutter/material.dart';
import '../models/product.dart';
import '../constants.dart';
import '../components/product_form.dart';
import '../components/product_table.dart';

class ProductManagerScreen extends StatefulWidget {
  const ProductManagerScreen({super.key});

  @override
  State<ProductManagerScreen> createState() => _ProductManagerScreenState();
}

class _ProductManagerScreenState extends State<ProductManagerScreen> {
  // --- DỮ LIỆU ---
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
  final List<String> _categoryList = [
    'Laptop',
    'Điện thoại',
    'Máy ảnh',
    'Phụ kiện',
  ];

  // --- CONTROLLERS ---
  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _filteredProducts = List.from(_products);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
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
    setState(() => _selectedIndex = index);
  }

  // --- DIALOGS ---
  void _showAddDialog() {
    _clearControllers();
    String localCategory = _categoryList.first;
    _showFormDialog(
      "Thêm sản phẩm mới",
      "Lưu",
      localCategory,
      (category) => _saveProduct(category),
    );
  }

  void _showEditDialog() {
    if (_selectedIndex == null)
      return _showError("Vui lòng chọn sản phẩm cần sửa!");

    Product p = _filteredProducts[_selectedIndex!];
    _nameCtrl.text = p.name;
    _idCtrl.text = p.id;
    _priceCtrl.text = p.price.toStringAsFixed(0);
    _qtyCtrl.text = p.quantity.toString();

    String localCategory = _categoryList.contains(p.category)
        ? p.category
        : _categoryList.first;
    _showFormDialog(
      "Sửa sản phẩm ${p.id}",
      "Cập nhật",
      localCategory,
      (category) => _updateProduct(category),
    );
  }

  // Hàm hiển thị Dialog Form dùng chung cho cả Thêm và Sửa (Tối ưu code)
  void _showFormDialog(
    String title,
    String btnText,
    String initialCategory,
    Function(String) onSave,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        String currentCategory = initialCategory;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 500,
                child: ProductForm(
                  nameCtrl: _nameCtrl,
                  idCtrl: _idCtrl,
                  priceCtrl: _priceCtrl,
                  qtyCtrl: _qtyCtrl,
                  categoryList: _categoryList,
                  selectedCategory: currentCategory,
                  onCategoryChanged: (val) =>
                      setStateDialog(() => currentCategory = val!),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    onSave(currentCategory);
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    btnText,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog() {
    if (_selectedIndex == null)
      return _showError("Vui lòng chọn sản phẩm cần xóa!");
    Product p = _filteredProducts[_selectedIndex!];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc chắn muốn xóa ${p.name}?"),
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

  // --- CRUD LOGIC ---
  void _saveProduct(String category) {
    if (_nameCtrl.text.isEmpty || _idCtrl.text.isEmpty) return;
    final newProduct = Product(
      id: _idCtrl.text,
      name: _nameCtrl.text,
      category: category,
      quantity: int.tryParse(_qtyCtrl.text) ?? 0,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      status: 'Còn hàng',
      brand: 'Khác',
    );
    setState(() {
      _products.insert(0, newProduct);
      _handleSearch(_searchCtrl.text);
    });
  }

  void _updateProduct(String category) {
    Product p = _filteredProducts[_selectedIndex!];
    int idx = _products.indexWhere((item) => item.id == p.id);
    if (idx != -1) {
      setState(() {
        _products[idx] = _products[idx].copyWith(
          name: _nameCtrl.text,
          category: category,
          quantity: int.tryParse(_qtyCtrl.text) ?? 0,
          price: double.tryParse(_priceCtrl.text) ?? 0,
        );
        _handleSearch(_searchCtrl.text);
        _selectedIndex = null;
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

  // --- HELPERS ---
  void _clearControllers() {
    _nameCtrl.clear();
    _idCtrl.clear();
    _priceCtrl.clear();
    _qtyCtrl.clear();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // --- UI CHÍNH CỦA TAB SẢN PHẨM ---
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TOOLBAR
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _handleSearch,
                  decoration: const InputDecoration(
                    hintText: "Tìm kiếm sản phẩm...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _buildActionButton(
                "Thêm",
                Icons.add,
                AppColors.primary,
                _showAddDialog,
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                "Sửa",
                Icons.edit,
                Colors.orange,
                _showEditDialog,
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                "Xóa",
                Icons.delete,
                Colors.red,
                _showDeleteDialog,
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                "Xuất Excel",
                Icons.file_download, // Icon tải xuống
                Colors.green, // Màu xanh Excel
                () {
                  // Hiện tại chưa xử lý gì, chỉ in ra log
                  print("Bấm nút Xuất Excel");
                },
              ),
            ],
          ),
        ),
        // TABLE
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
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.all(18),
      ),
      onPressed: onTap,
    );
  }
}

// Extension nhỏ để copyWith giúp update object dễ hơn (Bạn có thể bỏ vào product.dart)
extension ProductExtension on Product {
  Product copyWith({
    String? name,
    String? category,
    int? quantity,
    double? price,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      status: status,
      brand: brand,
    );
  }
}
