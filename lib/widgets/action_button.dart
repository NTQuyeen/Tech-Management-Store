import 'package:flutter/material.dart';
import '../constants.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ActionButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 2,
        ), // Khoảng cách giữa các nút
        height: 40,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Nút vuông góc cạnh
              side: BorderSide(color: Colors.white, width: 2),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
