import 'package:flutter/material.dart';
import 'import_models.dart';
import 'import_helpers.dart';

class EditLineDialog extends StatefulWidget {
  final ImportLine line;
  const EditLineDialog({super.key, required this.line});

  @override
  State<EditLineDialog> createState() => _EditLineDialogState();
}

class _EditLineDialogState extends State<EditLineDialog> {
  late final TextEditingController qtyCtrl;
  late final TextEditingController costCtrl;

  @override
  void initState() {
    super.initState();
    qtyCtrl = TextEditingController(text: widget.line.quantity.toString());
    costCtrl = TextEditingController(
      text: widget.line.costPrice.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    qtyCtrl.dispose();
    costCtrl.dispose();
    super.dispose();
  }

  double _previewTotal() {
    final qty = int.tryParse(qtyCtrl.text.trim()) ?? widget.line.quantity;
    final cost =
        double.tryParse(costCtrl.text.trim().replaceAll(',', '')) ??
        widget.line.costPrice;
    return cost * qty;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Sửa: ${widget.line.product.code}"),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tf(qtyCtrl, "Số lượng", TextInputType.number),
            const SizedBox(height: 10),
            _tf(costCtrl, "Giá nhập", TextInputType.number),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Thành tiền: ${formatMoney(_previewTotal())}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Huỷ"),
        ),
        FilledButton(
          onPressed: () {
            final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
            final cost =
                double.tryParse(costCtrl.text.trim().replaceAll(',', '')) ?? 0;

            if (qty <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Số lượng phải > 0")),
              );
              return;
            }
            if (cost < 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Giá nhập không hợp lệ")),
              );
              return;
            }

            Navigator.pop(
              context,
              widget.line.copyWith(quantity: qty, costPrice: cost),
            );
          },
          child: const Text("Lưu"),
        ),
      ],
    );
  }

  Widget _tf(TextEditingController c, String label, TextInputType type) {
    return TextField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (_) => setState(() {}),
    );
  }
}
