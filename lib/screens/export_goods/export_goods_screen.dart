import 'package:flutter/material.dart';
import 'export_warehouse_side.dart';
import 'export_receipt_side.dart';
import 'add_product_dialog.dart';
import '../../services/invoice_api.dart';

class ExportGoodsScreen extends StatefulWidget {
  const ExportGoodsScreen({super.key});

  @override
  State<ExportGoodsScreen> createState() => _ExportGoodsScreenState();
}

class _ExportGoodsScreenState extends State<ExportGoodsScreen> {
  // ================== CONTROLLERS KHÁCH HÀNG ==================
  final _customerNameCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();
  final _customerEmailCtrl = TextEditingController();

  final InvoiceApi _invoiceApi = InvoiceApi();

  // ================== DANH SÁCH SP TRONG HÓA ĐƠN ==================
  // { id(int product_id), code(String productCode), name, price, qty }
  final List<Map<String, dynamic>> _currentProducts = [];

  bool _loadingCustomer = false;
  bool _loadingExport = false;

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    _customerEmailCtrl.dispose();
    super.dispose();
  }

  // ================== TÌM KHÁCH HÀNG (CALL BE) ==================
  Future<void> _handleSearchCustomer() async {
    final phone = _customerPhoneCtrl.text.trim();
    if (phone.isEmpty) {
      _showMsg("Vui lòng nhập số điện thoại", Colors.red);
      return;
    }

    setState(() => _loadingCustomer = true);

    try {
      // BE: GET /shopqtqt/customer/{sdt}
      final c = await _invoiceApi.getCustomerByPhone(phone);

      setState(() {
        // Customers entity: fullName, phone, email, address...
        _customerNameCtrl.text = (c["fullName"] ?? "").toString();
        _customerEmailCtrl.text = (c["email"] ?? "").toString();
      });

      _showMsg("Đã tìm thấy khách hàng", Colors.green);
    } catch (e) {
      // Không tìm thấy -> khách mới -> cho nhập
      setState(() {
        _customerNameCtrl.clear();
        _customerEmailCtrl.clear();
      });
      _showMsg("Khách hàng mới. Vui lòng nhập thông tin", Colors.orange);
    } finally {
      if (mounted) setState(() => _loadingCustomer = false);
    }
  }

  // ================== THÊM SẢN PHẨM ==================
  Future<void> _handleAddProduct() async {
    await showDialog(
      context: context,
      builder: (context) => AddProductDialog(onSubmit: _addProductByCode),
    );
  }

  Future<void> _addProductByCode(String productCode, int quantity) async {
    try {
      // BE: POST /shopqtqt/product-invoice
      // Request: { productCode: "P101", number: quantity }
      // Response: { id, name, price, quantity }
      final res = await _invoiceApi.addProductToInvoice({
        "productCode": productCode,
        "number": quantity,
      });

      final int productId = int.tryParse(res["id"].toString()) ?? 0;
      if (productId <= 0) {
        _showMsg("Dữ liệu sản phẩm trả về không hợp lệ", Colors.red);
        return;
      }

      // Nếu SP đã có trong hóa đơn -> cộng dồn số lượng
      final index = _currentProducts.indexWhere((p) => p["id"] == productId);

      setState(() {
        if (index >= 0) {
          _currentProducts[index]["qty"] =
              (_currentProducts[index]["qty"] as int) + quantity;
        } else {
          _currentProducts.add({
            "id": productId,
            "code": productCode,
            "name": res["name"],
            "price": res["price"],
            "qty": quantity,
          });
        }
      });

      _showMsg("Đã thêm sản phẩm", Colors.green);
    } catch (e) {
      _showMsg("Không tìm thấy sản phẩm", Colors.red);
    }
  }

  // ================== SỬA / XÓA SP ==================
  Future<void> _editProduct(int index) async {
    final item = _currentProducts[index];
    final qtyCtrl = TextEditingController(text: item["qty"].toString());

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Sửa số lượng (${item['name']})"),
        content: TextField(
          controller: qtyCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Số lượng"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              final newQty = int.tryParse(qtyCtrl.text.trim()) ?? -1;
              if (newQty <= 0) {
                _showMsg("Số lượng phải > 0", Colors.red);
                return;
              }
              setState(() {
                _currentProducts[index]["qty"] = newQty;
              });
              Navigator.pop(context);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );

    qtyCtrl.dispose();
  }

  void _removeProduct(int index) {
    setState(() {
      _currentProducts.removeAt(index);
    });
  }

  // ================== XUẤT HÓA ĐƠN (CALL BE) ==================
  Future<void> _handleExport() async {
    if (_loadingExport) return;

    final phone = _customerPhoneCtrl.text.trim();
    final name = _customerNameCtrl.text.trim();

    if (phone.isEmpty || name.isEmpty) {
      _showMsg("Thiếu thông tin khách hàng (SĐT và Họ tên)", Colors.red);
      return;
    }
    if (_currentProducts.isEmpty) {
      _showMsg("Hóa đơn chưa có sản phẩm", Colors.red);
      return;
    }

    setState(() => _loadingExport = true);

    try {
      // InvoiceRequired theo BE:
      // products: List<ProductInvoiceResponse> (id, name, price, quantity)
      // nameCustomer, phoneCustomer, emailCustomer, addressCustomer, userId
      final productsPayload = _currentProducts.map((p) {
        return {
          "id": p["id"], // product_id
          "name": p["name"],
          "price": p["price"],
          "quantity": p["qty"],
        };
      }).toList();

      final body = {
        "products": productsPayload,
        "nameCustomer": name,
        "phoneCustomer": phone,
        "emailCustomer": _customerEmailCtrl.text.trim(),
        "addressCustomer": "",
        "userId": 1, // TODO: nếu bạn có userId thật từ session thì thay vào
      };

      // BE: POST /shopqtqt/invoice
      await _invoiceApi.createInvoiceLegacy(body);

      setState(() {
        _currentProducts.clear();
      });

      _showMsg("Xuất hóa đơn thành công", Colors.green);
    } catch (e) {
      _showMsg("Xuất hóa đơn thất bại: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _loadingExport = false);
    }
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TRÁI – DANH SÁCH SP
          Expanded(
            flex: 6,
            child: ExportWarehouseSide(
              products: _currentProducts,
              onAddProduct: _handleAddProduct,
              onEditProduct: (i) => _editProduct(i),
              onRemoveProduct: (i) => _removeProduct(i),
            ),
          ),

          const SizedBox(width: 25),

          // PHẢI – HÓA ĐƠN
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                ExportReceiptSide(
                  nameCtrl: _customerNameCtrl,
                  phoneCtrl: _customerPhoneCtrl,
                  emailCtrl: _customerEmailCtrl,
                  onExport: _handleExport,
                  onSearchCustomer: _handleSearchCustomer,
                ),

                if (_loadingCustomer || _loadingExport)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.05),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}
