import 'package:flutter/material.dart';
import '../constants.dart';

class LabelInput extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool isNumber; // Thêm biến này để xử lý nhập số

  // THÊM DÒNG NÀY: Để nhận Dropdown hoặc widget khác
  final Widget? widget;

  const LabelInput({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.isNumber = false,
    this.widget, // Thêm vào constructor
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10.0,
      ), // Tăng khoảng cách chút cho thoáng
      child: Row(
        children: [
          // LABEL XANH
          Container(
            width: 110,
            height: 35,
            color: AppColors.primary,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 5),

          // INPUT TRẮNG
          Expanded(
            child: SizedBox(
              height: 35,
              child:
                  widget ?? // Logic: Nếu có widget (Dropdown) thì dùng, ko thì dùng TextField
                  TextField(
                    controller: controller,
                    keyboardType: isNumber
                        ? TextInputType.number
                        : TextInputType.text,
                    style: const TextStyle(
                      fontSize: 14,
                    ), // Chữ nhập vào to hơn chút
                    decoration: InputDecoration(
                      hintText: hintText,
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
