import 'package:flutter/material.dart';
import '../models/product.dart';
import '../constants.dart';
import '../components/product_form.dart';
import '../components/product_table.dart';
import '../services/product_api.dart';

class ProductManagerScreen extends StatefulWidget {
  final String userRole;

  const ProductManagerScreen({super.key, required this.userRole});

  @override
  State<ProductManagerScreen> createState() => _ProductManagerScreenState();
}

class _ProductManagerScreenState extends State<ProductManagerScreen> {
  // DỮ LIỆU
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final List<String> _categoryList = [
    'Laptop',
    'Điện thoại',
    'Máy ảnh',
    'Phụ kiện',
    'Khác',
  ];

  // Map tên loại (UI) -> categoryId (DB)
  final Map<String, int> _categoryIdMap = {
    'Laptop': 1,
    'Điện thoại': 2,
    'Máy ảnh': 3,
    'Phụ kiện': 4,
    'Khác': 5,
  };

  int _parseIntLoose(String s) {
    final cleaned = s.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  // CONTROLLERS
  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController(); // ✅ dùng cho Mã SP (productCode)
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  int? _selectedIndex;
  bool get isAdmin => widget.userRole == 'admin';

  final ProductApi _productApi = ProductApi();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final items = await _productApi.list();
      setState(() {
        _products = items;
        _filteredProducts = List.from(items);
        _selectedIndex = null;
      });
    } catch (e) {
      _showError('Không tải được danh sách sản phẩm: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  // --- LOGIC ---
  void _handleSearch(String value) {
    final q = value.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredProducts = List.from(_products);
      } else {
        _filteredProducts = _products
            .where(
              (p) =>
                  p.name.toLowerCase().contains(q) ||
                  p.productCode.toLowerCase().contains(
                    q,
                  ), // ✅ search theo Mã SP
            )
            .toList();
      }
      _selectedIndex = null;
    });
  }

  void _onRowSelected(int index) {
    if (!isAdmin) return;
    setState(() => _selectedIndex = index);
  }

  // --- DIALOGS ---
  void _showAddDialog() {
    _clearControllers();
    String localCategory = _categoryList.first;
    _showFormDialog(
      title: "Thêm sản phẩm mới",
      btnText: "Lưu",
      initialCategory: localCategory,
      onSave: (category) => _saveProduct(category),
    );
  }

  void _showEditDialog() {
    if (_selectedIndex == null) {
      _showError("Vui lòng chọn sản phẩm cần sửa!");
      return;
    }

    Product p = _filteredProducts[_selectedIndex!];
    _nameCtrl.text = p.name;
    _idCtrl.text = p.productCode; // ✅ mã SP
    _priceCtrl.text = p.price.toStringAsFixed(0);
    _qtyCtrl.text = p.quantity.toString();
    String localCategory = _categoryList.contains(p.category)
        ? p.category
        : _categoryList.first;

    _showFormDialog(
      title: "Sửa sản phẩm ${p.productCode}", // ✅ hiển thị mã SP
      btnText: "Cập nhật",
      initialCategory: localCategory,
      onSave: (category) => _updateProduct(category),
    );
  }

  void _showFormDialog({
    required String title,
    required String btnText,
    required String initialCategory,
    required Future<void> Function(String) onSave,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        String currentCategory = initialCategory;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF5F5F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 800,
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
                  child: const Text(
                    "Hủy",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00695C),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 15,
                    ),
                  ),
                  onPressed: () async {
                    await onSave(currentCategory);
                    if (context.mounted) Navigator.pop(ctx);
                  },
                  child: Text(
                    btnText,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
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
    if (_selectedIndex == null) {
      _showError("Vui lòng chọn sản phẩm cần xóa!");
      return;
    }
    Product p = _filteredProducts[_selectedIndex!];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text(
          "Bạn có chắc chắn muốn xóa ${p.name} (${p.productCode})?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Không"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _deleteProduct();
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- CRUD LOGIC ---
  Future<void> _saveProduct(String category) async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showError("Vui lòng nhập Tên sản phẩm");
      return;
    }

    final code = _idCtrl.text.trim(); // ✅ productCode
    if (code.isEmpty) {
      _showError("Vui lòng nhập Mã SP (ví dụ P101)");
      return;
    }

    final categoryId = _categoryIdMap[category];
    if (categoryId == null) {
      _showError("Loại sản phẩm không hợp lệ");
      return;
    }

    // ✅ THÊM: không gửi id kỹ thuật
    // ✅ Key khớp ProductDTO: productCode, name, idCategory, price, stock
    final body = <String, dynamic>{
      "productCode": code,
      "name": _nameCtrl.text.trim(),
      "idCategory": categoryId,
      "price": _parseIntLoose(_priceCtrl.text),
      "stock": _parseIntLoose(_qtyCtrl.text),
    };

    try {
      await _productApi.createRaw(body);
      await _loadProducts();
    } catch (e) {
      _showError('Thêm sản phẩm thất bại: $e');
    }
  }

  Future<void> _updateProduct(String category) async {
    if (_selectedIndex == null) return;

    final selected = _filteredProducts[_selectedIndex!];

    final code = _idCtrl.text.trim(); // ✅ productCode
    if (code.isEmpty) {
      _showError("Vui lòng nhập Mã SP (ví dụ P101)");
      return;
    }

    final categoryId = _categoryIdMap[category];
    if (categoryId == null) {
      _showError("Loại sản phẩm không hợp lệ");
      return;
    }

    final idNum = int.tryParse(selected.id);
    if (idNum == null) {
      _showError("Không xác định được ID nội bộ để cập nhật");
      return;
    }

    // ✅ UPDATE: phải gửi id kỹ thuật + productCode
    final body = <String, dynamic>{
      "id": idNum,
      "productCode": code,
      "name": _nameCtrl.text.trim(),
      "idCategory": categoryId,
      "price": _parseIntLoose(_priceCtrl.text),
      "stock": _parseIntLoose(_qtyCtrl.text),
    };

    try {
      await _productApi.updateRaw(body);
      await _loadProducts();
    } catch (e) {
      _showError('Cập nhật sản phẩm thất bại: $e');
    }
  }

  Future<void> _deleteProduct() async {
    if (_selectedIndex == null) return;
    final p = _filteredProducts[_selectedIndex!];

    try {
      // ✅ Xóa theo id kỹ thuật (product_id)
      await _productApi.deleteById(p.id);
      await _loadProducts();
    } catch (e) {
      _showError('Xóa sản phẩm thất bại: $e');
    }
  }

  void _clearControllers() {
    _nameCtrl.clear();
    _idCtrl.clear();
    _priceCtrl.clear();
    _qtyCtrl.clear();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // --- UI CHÍNH ---
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
                isAdmin ? _showAddDialog : null,
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                "Sửa",
                Icons.edit,
                Colors.orange,
                isAdmin ? _showEditDialog : null,
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                "Xóa",
                Icons.delete,
                Colors.red,
                isAdmin ? _showDeleteDialog : null,
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                "Xuất Excel",
                Icons.file_download,
                Colors.green,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tính năng Xuất Excel đang phát triển"),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // TABLE
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
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
    VoidCallback? onTap,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: Colors.grey.shade300,
        padding: const EdgeInsets.all(18),
      ),
      onPressed: onTap,
    );
  }
}

extension ProductExtension on Product {
  Product copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    double? price,
    String? productCode,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      productCode: productCode ?? this.productCode,
    );
  }
}
