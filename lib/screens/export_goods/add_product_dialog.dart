import 'package:flutter/material.dart';
import '../../services/invoice_api.dart';

class AddProductDialog extends StatefulWidget {
  final Future<void> Function(String productCode, int quantity) onSubmit;

  const AddProductDialog({super.key, required this.onSubmit});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _codeCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');

  final InvoiceApi _invoiceApi = InvoiceApi();

  Map<String, dynamic>? _foundProduct;
  bool _loading = false;

  String _formatMoney(num value) {
    final s = value.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (m) => '${m[1]}.');
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchProduct() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _loading = true;
      _foundProduct = null;
    });

    try {
      // ✅ Endpoint đúng: /product-invoice
      // body đúng: { productCode, number }
      final res = await _invoiceApi.addProductToInvoice({
        "productCode": code,
        "number": 1,
      });

      setState(() {
        _foundProduct = res;
      });
    } catch (e) {
      setState(() => _foundProduct = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy sản phẩm")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = _foundProduct != null;

    return AlertDialog(
      title: const Text("Thêm sản phẩm vào hóa đơn"),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _codeCtrl,
              decoration: InputDecoration(
                labelText: "Mã SP",
                hintText: "Ví dụ: P101",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: "Tìm sản phẩm",
                  onPressed: _loading ? null : _searchProduct,
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _loading ? null : _searchProduct(),
            ),

            const SizedBox(height: 12),

            if (_loading) const CircularProgressIndicator(),

            if (_foundProduct != null) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Tên: ${_foundProduct!['name'] ?? ''}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Giá: ${_formatMoney((_foundProduct!['price'] ?? 0) as num)}",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Số lượng",
                  hintText: "Nhập số lượng",
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy"),
        ),
        ElevatedButton(
          onPressed: !canAdd
              ? null
              : () async {
                  final code = _codeCtrl.text.trim();
                  final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
                  if (code.isEmpty || qty <= 0) return;

                  await widget.onSubmit(code, qty);

                  if (context.mounted) Navigator.pop(context);
                },
          child: const Text("Thêm"),
        ),
      ],
    );
  }
}
