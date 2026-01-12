import 'package:flutter/material.dart';
import 'constants.dart'; // Để lấy màu chủ đạo AppColors
import 'screens/login_screen.dart'; // Màn hình đầu tiên là Login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phần mềm Quản lý Cửa hàng', // Tên hiển thị trên thanh taskbar
      debugShowCheckedModeBanner: false, // Tắt chữ Debug ở góc phải
      // Cấu hình giao diện (Theme)
      theme: ThemeData(
        // Sử dụng Material 3 (Giao diện mới nhất của Google)
        useMaterial3: true,

        // Thiết lập màu chủ đạo cho toàn app dựa trên AppColors.primary
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),

        // Cấu hình font chữ mặc định (Tùy chọn)
        fontFamily: 'Roboto', // Hoặc font bạn thích
        // Cấu hình style cho các nút bấm (ElevatedButton)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Cấu hình style cho ô nhập liệu (Input)
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),

      // MÀN HÌNH KHỞI CHẠY ĐẦU TIÊN
      home: const LoginScreen(),
    );
  }
}
