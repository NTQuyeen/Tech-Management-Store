import 'package:flutter/material.dart';
import '../constants.dart';

class LabelInput extends StatelessWidget {
  final String label;
  final String? hintText;
  // Thêm dòng này:
  final TextEditingController? controller;

  const LabelInput({
    super.key,
    required this.label,
    this.hintText,
    this.controller, // Thêm dòng này vào constructor
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
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
              child: TextField(
                controller:
                    controller, // Nhớ truyền controller vào TextField ở đây
                decoration: InputDecoration(
                  hintText: hintText,
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
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
