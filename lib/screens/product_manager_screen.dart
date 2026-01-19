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
  // DỮ LIỆU (chỉ danh sách bán: available > 0)
  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  // Category cố định
  final List<String> _categoryList = const [
    'Laptop',
    'Điện thoại',
    'Máy ảnh',
    'Phụ kiện',
    'Khác',
  ];

  // Map tên loại (UI) -> categoryId (DB)
  final Map<String, int> _categoryIdMap = const {
    'Laptop': 1,
    'Điện thoại': 2,
    'Máy ảnh': 3,
    'Phụ kiện': 4,
    'Khác': 5,
  };

  // CONTROLLERS
  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController(); // Mã SP (productCode)
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  int? _selectedIndex;
  bool get isAdmin => widget.userRole == 'admin';

  final ProductApi _productApi = ProductApi();
  bool _isLoading = false;

  // trạng thái “đã tìm thấy trong kho” cho dialog Add
  bool _foundInWarehouse = false;

  // cache tạm sản phẩm tìm từ kho theo code (để dùng khi lưu)
  Product? _warehouseHit;

  @override
  void initState() {
    super.initState();
    _loadProducts();
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

  // ======================
  // Helpers
  // ======================
  int _parseIntLoose(String s) {
    final cleaned = s.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _categoryFromProduct(Product p) {
    // nếu category từ BE không nằm trong list, fallback về item đầu
    return _categoryList.contains(p.category)
        ? p.category
        : _categoryList.first;
  }

  // ✅ Tìm sản phẩm trong kho bằng cách gọi API BE:
  // GET /shopqtqt/import/product/{code}
  Future<Product?> _findWarehouseByCodeApi(String code) async {
    final c = code.trim();
    if (c.isEmpty) return null;

    try {
      final p = await _productApi.getImportProductByCode(c);

      // Nếu bạn muốn: phải có stock > 0 mới cho phép đưa lên bán
      if (p.stock <= 0) return null;

      return p;
    } catch (_) {
      return null;
    }
  }

  // ======================
  // Load / Search in table
  // ======================
  Future<void> _loadProducts() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // ✅ danh sách bán: available > 0
      final items = await _productApi.listForSale();
      setState(() {
        _products = items;
        _filteredProducts = List.from(items);
        _selectedIndex = null;
      });
    } catch (e) {
      _toast('Không tải được danh sách sản phẩm: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                  p.productCode.toLowerCase().contains(q),
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

  // ======================
  // Dialogs
  // ======================
  void _clearControllers() {
    _nameCtrl.clear();
    _idCtrl.clear();
    _priceCtrl.clear();
    _qtyCtrl.clear();
    _foundInWarehouse = false;
    _warehouseHit = null;
  }

  void _showAddDialog() {
    _clearControllers();

    // dialog Add: bắt buộc search theo mã -> fill tên + loại
    String localCategory = _categoryList.first;

    _showFormDialog(
      title: "Thêm sản phẩm bán",
      btnText: "Lưu",
      initialCategory: localCategory,
      isAddSaleFlow: true,
      onSave: (category) => _saveSaleProduct(category),
      onSearchByCode: (code, setStateDialog) async {
        final hit = await _findWarehouseByCodeApi(code);

        if (hit == null) {
          setStateDialog(() {
            _foundInWarehouse = false;
            _warehouseHit = null;
            _nameCtrl.clear();
          });
          _toast("Chưa có sản phẩm này trong kho hoặc stock = 0");
          return;
        }

        final cat = _categoryFromProduct(hit);

        setStateDialog(() {
          _foundInWarehouse = true;
          _warehouseHit = hit;
          _nameCtrl.text = hit.name;
          localCategory = cat; // update localCategory
        });

        _toast("Đã tìm thấy trong kho: ${hit.name}");
      },
    );
  }

  void _showEditDialog() {
    if (_selectedIndex == null) {
      _toast("Vui lòng chọn sản phẩm cần sửa!");
      return;
    }

    Product p = _filteredProducts[_selectedIndex!];

    _nameCtrl.text = p.name;
    _idCtrl.text = p.productCode;
    _priceCtrl.text = p.price.toStringAsFixed(0);
    _qtyCtrl.text = p.available.toString();

    String localCategory = _categoryFromProduct(p);

    _showFormDialog(
      title: "Sửa sản phẩm ${p.productCode}",
      btnText: "Cập nhật",
      initialCategory: localCategory,
      isAddSaleFlow: false,
      onSave: (category) => _updateProduct(category),
      onSearchByCode: null,
    );
  }

  void _showDeleteDialog() {
    if (_selectedIndex == null) {
      _toast("Vui lòng chọn sản phẩm cần xóa!");
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

  void _showFormDialog({
    required String title,
    required String btnText,
    required String initialCategory,
    required Future<void> Function(String) onSave,

    // add sale flow
    required bool isAddSaleFlow,

    // nút search nằm trong ô Mã SP
    Future<void> Function(
      String code,
      void Function(void Function()) setStateDialog,
    )?
    onSearchByCode,
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
                  // controllers
                  nameCtrl: _nameCtrl,
                  idCtrl: _idCtrl,
                  priceCtrl: _priceCtrl,
                  qtyCtrl: _qtyCtrl,

                  // categories
                  categoryList: _categoryList,
                  selectedCategory: currentCategory,
                  onCategoryChanged: (val) => setStateDialog(
                    () => currentCategory = val ?? _categoryList.first,
                  ),

                  // ✅ add: search button in id field
                  enableCodeSearch: onSearchByCode != null,
                  onSearchCode: onSearchByCode == null
                      ? null
                      : () async {
                          final code = _idCtrl.text.trim();
                          if (code.isEmpty) {
                            _toast("Vui lòng nhập Mã SP");
                            return;
                          }

                          await onSearchByCode(code, setStateDialog);

                          // nếu tìm thấy -> auto set dropdown theo product vừa tìm
                          if (_foundInWarehouse && _warehouseHit != null) {
                            final cat = _categoryFromProduct(_warehouseHit!);
                            setStateDialog(() => currentCategory = cat);
                          }
                        },

                  // ✅ khóa tên + loại khi đã tìm thấy trong kho
                  lockNameAndCategory: isAddSaleFlow && _foundInWarehouse,
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

  // ======================
  // CRUD
  // ======================

  /// ✅ Luồng “Thêm sản phẩm bán”:
  /// - bắt buộc: tìm theo mã trong kho (API)
  /// - auto fill name + category
  /// - user nhập price + qty
  /// - lưu: release qty lên bán
  Future<void> _saveSaleProduct(String category) async {
    final code = _idCtrl.text.trim();
    if (code.isEmpty) {
      _toast("Vui lòng nhập Mã SP rồi bấm tìm");
      return;
    }

    Product? hit = _warehouseHit ?? await _findWarehouseByCodeApi(code);
    if (hit == null) {
      _toast("Chưa có sản phẩm này trong kho hoặc stock = 0");
      return;
    }

    final categoryId = _categoryIdMap[category];
    if (categoryId == null) {
      _toast("Loại sản phẩm không hợp lệ");
      return;
    }

    final price = _parseIntLoose(_priceCtrl.text);
    if (price <= 0) {
      _toast("Vui lòng nhập Đơn giá hợp lệ");
      return;
    }

    final qty = _parseIntLoose(_qtyCtrl.text);
    if (qty <= 0) {
      _toast("Vui lòng nhập Số lượng hợp lệ");
      return;
    }

    try {
      // ✅ 1) Cập nhật giá trước (và các field cần thiết)
      await _productApi.updateRaw({
        "id": int.tryParse(hit.id) ?? hit.id,
        "productCode": hit.productCode,
        "name": hit.name,
        "idCategory": categoryId,
        "price": price,
        // nếu BE cần thêm field khác (priceIn/description) thì gửi kèm ở đây
      });

      // ✅ 2) Rồi mới đưa qty lên bán
      await _productApi.releaseToSale(productId: hit.id, qty: qty);

      await _loadProducts();
      _toast("Đã đưa $qty lên bán và cập nhật giá $price");
    } catch (e) {
      _toast("Thêm sản phẩm bán thất bại: $e");
    }
  }

  Future<void> _updateProduct(String category) async {
    if (_selectedIndex == null) return;

    final selected = _filteredProducts[_selectedIndex!];
    final code = _idCtrl.text.trim();
    if (code.isEmpty) {
      _toast("Vui lòng nhập Mã SP");
      return;
    }

    final categoryId = _categoryIdMap[category];
    if (categoryId == null) {
      _toast("Loại sản phẩm không hợp lệ");
      return;
    }

    final idNum = int.tryParse(selected.id);
    if (idNum == null) {
      _toast("Không xác định được ID nội bộ để cập nhật");
      return;
    }

    final body = <String, dynamic>{
      "id": idNum,
      "productCode": code,
      "name": _nameCtrl.text.trim(),
      "idCategory": categoryId,
      "price": _parseIntLoose(_priceCtrl.text),
      // giữ logic cũ của bạn:
      "stock": _parseIntLoose(_qtyCtrl.text),
    };

    try {
      await _productApi.updateRaw(body);
      await _loadProducts();
    } catch (e) {
      _toast('Cập nhật sản phẩm thất bại: $e');
    }
  }

  Future<void> _deleteProduct() async {
    if (_selectedIndex == null) return;
    final p = _filteredProducts[_selectedIndex!];

    try {
      await _productApi.deleteById(p.id);
      await _loadProducts();
    } catch (e) {
      _toast('Xóa sản phẩm thất bại: $e');
    }
  }

  // ======================
  // UI
  // ======================
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
