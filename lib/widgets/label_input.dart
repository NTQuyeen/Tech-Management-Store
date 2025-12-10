import 'package:flutter/material.dart';
import '../constants.dart';

class LabelInput extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool isNumber;
  final Widget? widget;

  // --- CÁC THAM SỐ MỚI ---
  final bool
  isVertical; // true: Nhãn nằm trên (Form Nhân viên), false: Nhãn nằm trái (Form Sản phẩm)
  final bool isPassword; // true: Ẩn ký tự (Mật khẩu)

  const LabelInput({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.isNumber = false,
    this.widget,
    this.isVertical = false, // Mặc định là Ngang (như cũ)
    this.isPassword = false, // Mặc định không phải password
  });

  @override
  Widget build(BuildContext context) {
    // TRƯỜNG HỢP 1: FORM DỌC (Dùng cho Nhân viên)
    if (isVertical) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 40,
              child:
                  widget ??
                  TextField(
                    controller: controller,
                    obscureText: isPassword, // Ẩn mật khẩu
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
            ),
          ],
        ),
      );
    }

    // TRƯỜNG HỢP 2: FORM NGANG (Dùng cho Sản phẩm - Giữ nguyên code cũ của bạn)
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
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
          Expanded(
            child: SizedBox(
              height: 35,
              child:
                  widget ??
                  TextField(
                    controller: controller,
                    keyboardType: isNumber
                        ? TextInputType.number
                        : TextInputType.text,
                    obscureText: isPassword,
                    style: const TextStyle(fontSize: 14),
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
