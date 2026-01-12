import 'package:flutter/material.dart';
import '../../constants.dart';

class ExportReceiptSide extends StatefulWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final VoidCallback onExport;
  final VoidCallback onSearchCustomer;

  const ExportReceiptSide({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.onExport,
    required this.onSearchCustomer,
  });

  @override
  State<ExportReceiptSide> createState() => _ExportReceiptSideState();
}

class _ExportReceiptSideState extends State<ExportReceiptSide> {
  bool get _canExport =>
      widget.nameCtrl.text.trim().isNotEmpty &&
      widget.phoneCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.nameCtrl.addListener(_refresh);
    widget.phoneCtrl.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.nameCtrl.removeListener(_refresh);
    widget.phoneCtrl.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.person_outline, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  "THÔNG TIN KHÁCH HÀNG",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // BODY
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildInput(
                    "Số điện thoại",
                    widget.phoneCtrl,
                    Icons.phone,
                    isNumber: true,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: AppColors.primary),
                      onPressed: widget.onSearchCustomer,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInput(
                    "Họ và Tên",
                    widget.nameCtrl,
                    Icons.account_circle,
                  ),
                  const SizedBox(height: 20),
                  _buildInput("Email", widget.emailCtrl, Icons.email),
                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canExport
                            ? AppColors.primary
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                      ),
                      onPressed: _canExport ? widget.onExport : null,
                      child: const Text(
                        "XUẤT HÓA ĐƠN",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          onSubmitted: isNumber ? (_) => widget.onSearchCustomer() : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
