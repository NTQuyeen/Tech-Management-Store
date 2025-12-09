import 'package:flutter/material.dart';
import '../constants.dart';

class TopHeader extends StatelessWidget {
  final String employeeName;
  final String role;

  const TopHeader({
    super.key,
    this.employeeName = "Nguyễn Thiện Quyền", // Giá trị mặc định
    this.role = "Quản lý",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity, // Kéo dài hết chiều ngang
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Họ và tên: $employeeName",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Chức vụ: $role",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
