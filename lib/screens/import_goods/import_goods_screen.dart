import 'package:flutter/material.dart';
import 'import_models.dart';
import 'import_helpers.dart';
import 'edit_line_dialog.dart';

import '../../../services/import_api.dart';
import '../../../services/product_api.dart';

class ImportGoodsScreen extends StatefulWidget {
  const ImportGoodsScreen({super.key});

  @override
  State<ImportGoodsScreen> createState() => _ImportGoodsScreenState();
}

class _ImportGoodsScreenState extends State<ImportGoodsScreen> {
  final ImportApi _importApi = ImportApi();
  final ProductApi _productApi = ProductApi();

  // =========================
  // ✅ Category cứng trong file
  // =========================
  final List<String> _categoryList = const [
    'Laptop',
    'Điện thoại',
    'Máy ảnh',
    'Phụ kiện',
    'Thiết bị lưu trữ',
  ];

  final Map<String, int> _categoryIdMap = const {
    'Laptop': 1,
    'Điện thoại': 2,
    'Máy ảnh': 3,
    'Phụ kiện': 4,
    'Thiết bị lưu trữ': 5,
  };

  String? _selectedCategoryName;

  // Phiếu nhập
  final receiptCodeCtrl = TextEditingController(
    text: "PN${DateTime.now().millisecondsSinceEpoch}",
  );
  DateTime receiptDate = DateTime.now();
  PaymentStatus paymentStatus = PaymentStatus.unpaid;

  // NCC
  final supplierNameCtrl = TextEditingController();
  final supplierPhoneCtrl = TextEditingController();
  final supplierEmailCtrl = TextEditingController();
  final supplierAddressCtrl = TextEditingController();
  bool _providerFound = false;

  // Quick add
  final quickCodeCtrl = TextEditingController();
  final quickQtyCtrl = TextEditingController(text: "1");
  final quickCostCtrl = TextEditingController(text: "0");

  // Name + desc
  final foundNameCtrl = TextEditingController();
  final newDescCtrl = TextEditingController();

  // ✅ sản phẩm tìm thấy theo code (có thể null)
  ProductLite? _pickedByCode;

  // ✅ đánh dấu sản phẩm mới
  bool _isNewProduct = false;

  final List<ImportLine> lines = [];

  // Catalog từ DB (để tìm nhanh theo code)
  List<ProductLite> catalog = [];
  bool _loadingCatalog = false;

  double get subTotal => lines.fold(0, (s, e) => s + e.lineTotal);

  @override
  void initState() {
    super.initState();
    _selectedCategoryName = _categoryList.first;
    _loadCatalogFromDb();
  }

  String _normCode(String? s) => (s ?? '').trim().toLowerCase();

  ProductLite? _catalogItemByCode(String code) {
    final c = _normCode(code);
    try {
      return catalog.firstWhere((p) => _normCode(p.code) == c);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadCatalogFromDb() async {
    setState(() => _loadingCatalog = true);
    try {
      final products = await _productApi.listAll();

      // ✅ khử trùng theo code
      final Map<String, ProductLite> unique = {};
      for (final p in products) {
        final code = (p.productCode).trim();
        if (code.isEmpty) continue;

        unique[_normCode(code)] = ProductLite(
          code: code,
          name: (p.name).trim(),
          priceIn: p.priceIn,
          price: p.price,
          categoryId: p.categoryId,
        );
      }

      setState(() => catalog = unique.values.toList());
    } catch (e) {
      toast("Không tải được danh sách sản phẩm: $e");
    } finally {
      setState(() => _loadingCatalog = false);
    }
  }

  @override
  void dispose() {
    receiptCodeCtrl.dispose();
    supplierNameCtrl.dispose();
    supplierPhoneCtrl.dispose();
    supplierEmailCtrl.dispose();
    supplierAddressCtrl.dispose();

    quickCodeCtrl.dispose();
    quickQtyCtrl.dispose();
    quickCostCtrl.dispose();

    foundNameCtrl.dispose();
    newDescCtrl.dispose();
    super.dispose();
  }

  void toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: receiptDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => receiptDate = picked);
  }

  // =========================
  // ✅ TÌM NCC THEO SĐT
  // =========================
  Future<void> findProviderByPhone() async {
    final phone = supplierPhoneCtrl.text.trim();
    if (phone.isEmpty) return toast("Vui lòng nhập SĐT nhà cung cấp");

    try {
      final data = await _importApi.findProviderByPhone(phone);

      final name = (data["name"] ?? data["nameProvider"] ?? "")
          .toString()
          .trim();
      final email = (data["email"] ?? "").toString().trim();
      final address = (data["address"] ?? "").toString().trim();

      setState(() {
        _providerFound = true;
        supplierNameCtrl.text = name;
        supplierEmailCtrl.text = email;
        supplierAddressCtrl.text = address;
      });

      toast("Đã tìm thấy nhà cung cấp");
    } catch (_) {
      setState(() {
        _providerFound = false;
        supplierNameCtrl.clear();
        supplierEmailCtrl.clear();
        supplierAddressCtrl.clear();
      });

      toast("Chưa có nhà cung cấp này, vui lòng nhập thủ công");
    }
  }

  // =========================
  // ✅ Tìm theo mã SP
  // =========================
  Future<void> findByCode() async {
    final code = quickCodeCtrl.text.trim();
    if (code.isEmpty) return toast("Vui lòng nhập Mã SP");

    setState(() {
      _pickedByCode = null;
      _isNewProduct = false;
      foundNameCtrl.clear();
      newDescCtrl.clear();
    });

    // 1) tìm trong catalog (load từ /product)
    final hit = _catalogItemByCode(code);
    if (hit != null) {
      final existingPriceIn = (hit.priceIn is num)
          ? (hit.priceIn as num).toDouble()
          : double.tryParse(hit.priceIn?.toString() ?? "");

      setState(() {
        _pickedByCode = hit;
        _isNewProduct = false;
        foundNameCtrl.text = hit.name;

        if (existingPriceIn != null && existingPriceIn > 0) {
          quickCostCtrl.text = existingPriceIn.toStringAsFixed(0);
        }
      });
      return;
    }

    // 2) không có -> sản phẩm mới
    setState(() {
      _pickedByCode = ProductLite(code: code, name: "");
      _isNewProduct = true;
      _selectedCategoryName ??= _categoryList.first;
    });

    toast("Mã mới");
  }

  // =========================
  // ✅ Add line
  // =========================
  void addLine() {
    final base = _pickedByCode;
    if (base == null) return toast("Hãy nhập mã và bấm Tìm trước");

    final qty = int.tryParse(quickQtyCtrl.text.trim()) ?? 0;
    final cost =
        double.tryParse(quickCostCtrl.text.trim().replaceAll(',', '')) ?? 0;

    if (qty <= 0) return toast("Số lượng phải > 0");
    if (cost <= 0) return toast("Giá nhập phải > 0");

    ImportProductDraft? draft;
    ProductLite finalProduct = base;

    if (_isNewProduct) {
      final name = foundNameCtrl.text.trim();
      final cateName = _selectedCategoryName;
      final cateId = cateName == null ? null : _categoryIdMap[cateName];

      if (name.isEmpty) return toast("Sản phẩm mới: vui lòng nhập Tên SP");
      if (cateId == null) return toast("Sản phẩm mới: vui lòng chọn Category");

      draft = ImportProductDraft(
        code: base.code,
        name: name,
        idCategory: cateId,
        price: 0,
        description: newDescCtrl.text.trim(),
      );

      finalProduct = ProductLite(code: base.code, name: name);
    } else {
      final name = foundNameCtrl.text.trim();
      if (finalProduct.name.trim().isEmpty && name.isNotEmpty) {
        finalProduct = ProductLite(
          code: base.code,
          name: name,
          priceIn: base.priceIn,
        );
      }
    }

    final idx = lines.indexWhere(
      (e) => _normCode(e.product.code) == _normCode(finalProduct.code),
    );

    setState(() {
      if (idx >= 0) {
        lines[idx] = lines[idx].copyWith(
          quantity: lines[idx].quantity + qty,
          costPrice: cost,
          draft: lines[idx].draft ?? draft,
          product: finalProduct,
        );
      } else {
        lines.add(
          ImportLine(
            product: finalProduct,
            quantity: qty,
            costPrice: cost,
            draft: draft,
          ),
        );
      }

      _pickedByCode = null;
      _isNewProduct = false;

      foundNameCtrl.clear();
      newDescCtrl.clear();

      quickCodeCtrl.clear();
      quickQtyCtrl.text = "1";
      quickCostCtrl.text = "0";
      _selectedCategoryName = _categoryList.first;
    });
  }

  Future<void> editLine(int i) async {
    final updated = await showDialog<ImportLine>(
      context: context,
      builder: (_) => EditLineDialog(line: lines[i]),
    );
    if (updated != null) setState(() => lines[i] = updated);
  }

  void removeLine(int i) => setState(() => lines.removeAt(i));

  // =========================
  // ✅ Submit: gọi /shopqtqt/import
  // ✅ Sau khi thành công -> LƯU FILE TXT
  // =========================
  Future<void> submit() async {
    if (lines.isEmpty) return toast("Phiếu nhập chưa có sản phẩm.");

    // ✅ validate NCC tối thiểu
    if (supplierPhoneCtrl.text.trim().isEmpty) {
      return toast("Vui lòng nhập SĐT nhà cung cấp");
    }
    if (supplierNameCtrl.text.trim().isEmpty) {
      return toast("Vui lòng nhập Tên nhà cung cấp");
    }

    try {
      for (final line in lines) {
        final draft = line.draft;

        await _importApi.importStock(
          productCode: line.product.code,
          quantity: line.quantity,
          priceIn: line.costPrice,

          // nếu là sản phẩm mới
          name: draft?.name,
          idCategory: draft?.idCategory,
          price: null,
          description: draft?.description,

          // NCC
          supplierPhone: supplierPhoneCtrl.text,
          supplierName: supplierNameCtrl.text,
          supplierEmail: supplierEmailCtrl.text,
          supplierAddress: supplierAddressCtrl.text,
        );
      }

      // ✅ LƯU TXT SAU KHI IMPORT THÀNH CÔNG
      final file = await saveImportReceiptTxt(
        receiptCode: receiptCodeCtrl.text.trim(),
        receiptDate: receiptDate,
        paymentStatus: paymentStatus,
        supplierName: supplierNameCtrl.text.trim(),
        supplierPhone: supplierPhoneCtrl.text.trim(),
        supplierEmail: supplierEmailCtrl.text.trim(),
        supplierAddress: supplierAddressCtrl.text.trim(),
        lines: List<ImportLine>.from(lines),
        createdBy: null, // nếu có user thì truyền vào
      );

      toast("Nhập hàng thành công & đã lưu file:\n${file.path}");

      setState(() => lines.clear());
      await _loadCatalogFromDb();
    } catch (e) {
      toast("Lỗi nhập hàng: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nhập hàng"),
        actions: [
          IconButton(
            tooltip: "Tải lại danh sách sản phẩm",
            onPressed: _loadCatalogFromDb,
            icon: _loadingCatalog
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: submit,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("Xác nhận nhập"),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 1100;

          final main = _MainPanelWrap(
            receiptCodeCtrl: receiptCodeCtrl,
            receiptDate: receiptDate,
            onPickDate: pickDate,
            paymentStatus: paymentStatus,
            onPaymentChanged: (v) => setState(() => paymentStatus = v),

            supplierNameCtrl: supplierNameCtrl,
            supplierPhoneCtrl: supplierPhoneCtrl,
            supplierEmailCtrl: supplierEmailCtrl,
            supplierAddressCtrl: supplierAddressCtrl,
            onFindProvider: findProviderByPhone,
            providerFound: _providerFound,

            onFindByCode: findByCode,
            isNewProduct: _isNewProduct,
            categoryList: _categoryList,
            selectedCategoryName: _selectedCategoryName,
            onCategoryChanged: (v) => setState(() => _selectedCategoryName = v),
            descCtrl: newDescCtrl,

            foundNameCtrl: foundNameCtrl,
            quickCodeCtrl: quickCodeCtrl,
            quickQtyCtrl: quickQtyCtrl,
            quickCostCtrl: quickCostCtrl,
            onAddLine: addLine,

            lines: lines,
            onEditLine: editLine,
            onRemoveLine: removeLine,
          );

          final right = _RightPanel(total: subTotal);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: c.maxWidth * 0.68, child: main),
                      const SizedBox(width: 16),
                      Expanded(child: right),
                    ],
                  )
                : ListView(children: [main, const SizedBox(height: 16), right]),
          );
        },
      ),
    );
  }
}

// =================== MAIN PANEL ===================

class _MainPanelWrap extends StatelessWidget {
  final TextEditingController receiptCodeCtrl;
  final DateTime receiptDate;
  final VoidCallback onPickDate;

  final PaymentStatus paymentStatus;
  final ValueChanged<PaymentStatus> onPaymentChanged;

  // NCC
  final TextEditingController supplierNameCtrl;
  final TextEditingController supplierPhoneCtrl;
  final TextEditingController supplierEmailCtrl;
  final TextEditingController supplierAddressCtrl;
  final VoidCallback onFindProvider;
  final bool providerFound;

  // product
  final VoidCallback onFindByCode;

  final bool isNewProduct;
  final List<String> categoryList;
  final String? selectedCategoryName;
  final ValueChanged<String?> onCategoryChanged;
  final TextEditingController descCtrl;

  final TextEditingController foundNameCtrl;
  final TextEditingController quickCodeCtrl;
  final TextEditingController quickQtyCtrl;
  final TextEditingController quickCostCtrl;
  final VoidCallback onAddLine;

  final List<ImportLine> lines;
  final Future<void> Function(int) onEditLine;
  final void Function(int) onRemoveLine;

  const _MainPanelWrap({
    required this.receiptCodeCtrl,
    required this.receiptDate,
    required this.onPickDate,
    required this.paymentStatus,
    required this.onPaymentChanged,

    required this.supplierNameCtrl,
    required this.supplierPhoneCtrl,
    required this.supplierEmailCtrl,
    required this.supplierAddressCtrl,
    required this.onFindProvider,
    required this.providerFound,

    required this.onFindByCode,

    required this.isNewProduct,
    required this.categoryList,
    required this.selectedCategoryName,
    required this.onCategoryChanged,
    required this.descCtrl,

    required this.foundNameCtrl,
    required this.quickCodeCtrl,
    required this.quickQtyCtrl,
    required this.quickCostCtrl,
    required this.onAddLine,

    required this.lines,
    required this.onEditLine,
    required this.onRemoveLine,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle("Thông tin phiếu nhập"),
        const SizedBox(height: 10),
        _card(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 320,
                child: _tf(receiptCodeCtrl, "Mã phiếu nhập", enabled: false),
              ),
              SizedBox(
                width: 260,
                child: InkWell(
                  onTap: onPickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Ngày nhập",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: Row(
                      children: [
                        Text(formatDateVN(receiptDate)),
                        const Spacer(),
                        const Icon(Icons.date_range),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 260,
                child: DropdownButtonFormField<PaymentStatus>(
                  value: paymentStatus,
                  items: PaymentStatus.values
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.label)),
                      )
                      .toList(),
                  onChanged: (v) => onPaymentChanged(v ?? PaymentStatus.unpaid),
                  decoration: const InputDecoration(
                    labelText: "Trạng thái thanh toán",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const _SectionTitle("Nhà cung cấp"),
        const SizedBox(height: 10),
        _card(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 360,
                child: _tf(
                  supplierNameCtrl,
                  "Tên nhà cung cấp",
                  enabled: !providerFound,
                ),
              ),
              SizedBox(
                width: 260,
                child: _tf(
                  supplierPhoneCtrl,
                  "Số điện thoại",
                  keyboardType: TextInputType.phone,
                  suffixIcon: IconButton(
                    tooltip: "Tìm nhà cung cấp",
                    onPressed: onFindProvider,
                    icon: const Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(
                width: 360,
                child: _tf(
                  supplierEmailCtrl,
                  "Email",
                  enabled: !providerFound,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              SizedBox(
                width: 260,
                child: _tf(
                  supplierAddressCtrl,
                  "Địa chỉ",
                  enabled: !providerFound,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const _SectionTitle("Danh sách hàng nhập"),
        const SizedBox(height: 10),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(width: 180, child: _tf(quickCodeCtrl, "Mã SP")),
                  OutlinedButton.icon(
                    onPressed: onFindByCode,
                    icon: const Icon(Icons.search),
                    label: const Text("Tìm"),
                  ),

                  SizedBox(
                    width: 320,
                    child: _tf(foundNameCtrl, "Tên SP", enabled: isNewProduct),
                  ),

                  if (isNewProduct) ...[
                    SizedBox(
                      width: 260,
                      child: DropdownButtonFormField<String>(
                        value: selectedCategoryName,
                        items: categoryList
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: onCategoryChanged,
                        decoration: const InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 320,
                      child: _tf(descCtrl, "Mô tả (tuỳ chọn)"),
                    ),
                  ],

                  SizedBox(
                    width: 140,
                    child: _tf(
                      quickQtyCtrl,
                      "Số lượng",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: _tf(
                      quickCostCtrl,
                      "Giá nhập",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: onAddLine,
                    icon: const Icon(Icons.add),
                    label: const Text("Thêm"),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (lines.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "Chưa có sản phẩm nào. Nhập Mã SP và bấm Tìm, sau đó nhập SL + Giá nhập và bấm Thêm.",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Colors.grey.shade100,
                    ),
                    columns: const [
                      DataColumn(label: Text("Mã")),
                      DataColumn(label: Text("Tên sản phẩm")),
                      DataColumn(label: Text("SL")),
                      DataColumn(label: Text("Giá nhập")),
                      DataColumn(label: Text("Thành tiền")),
                      DataColumn(label: Text("")),
                    ],
                    rows: List.generate(lines.length, (i) {
                      final l = lines[i];
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              l.product.code,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 320,
                              child: Text(
                                l.product.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text("${l.quantity}")),
                          DataCell(Text(formatMoney(l.costPrice))),
                          DataCell(
                            Text(
                              formatMoney(l.lineTotal),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => onEditLine(i),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  onPressed: () => onRemoveLine(i),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
      ],
    ),
    child: child,
  );

  Widget _tf(
    TextEditingController c,
    String label, {
    bool enabled = true,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) => TextField(
    controller: c,
    enabled: enabled,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      isDense: true,
      suffixIcon: suffixIcon,
    ),
  );
}

class _RightPanel extends StatelessWidget {
  final double total;
  const _RightPanel({required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle("Tổng kết"),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              _kv("Tạm tính", formatMoney(total)),
              const Divider(height: 24),
              _kv("Tổng thanh toán", formatMoney(total), strong: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kv(String k, String v, {bool strong = false}) => Row(
    children: [
      Text(k, style: TextStyle(color: Colors.grey.shade700)),
      const Spacer(),
      Text(
        v,
        style: TextStyle(
          fontWeight: strong ? FontWeight.bold : FontWeight.w600,
        ),
      ),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );
}
