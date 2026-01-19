import 'package:flutter/material.dart';
import 'import_models.dart';

class NewProductDialog extends StatefulWidget {
  final ImportProductDraft draft;

  const NewProductDialog({super.key, required this.draft});

  @override
  State<NewProductDialog> createState() => _NewProductDialogState();
}

class _NewProductDialogState extends State<NewProductDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;

  int? _categoryId;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.draft.name);
    _priceCtrl = TextEditingController(
      text: widget.draft.price?.toString() ?? "",
    );
    _descCtrl = TextEditingController(text: widget.draft.description ?? "");
    _categoryId = widget.draft.idCategory;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Tạo sản phẩm mới (${widget.draft.code})"),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: "Tên sản phẩm",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Giá bán",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: "Mô tả",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // ✅ Category: đơn giản nhập idCategory (vì bạn chưa đưa list categories)
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Loại (idCategory)",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _categoryId = int.tryParse(v.trim()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy"),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameCtrl.text.trim();
            final price = num.tryParse(
              _priceCtrl.text.trim().replaceAll(',', ''),
            );
            if (name.isEmpty) return;
            if (_categoryId == null) return;
            if (price == null) return;

            widget.draft.name = name;
            widget.draft.idCategory = _categoryId;
            widget.draft.price = price;
            widget.draft.description = _descCtrl.text.trim();

            Navigator.pop(context, widget.draft);
          },
          child: const Text("Lưu"),
        ),
      ],
    );
  }
}
