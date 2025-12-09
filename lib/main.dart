import 'package:flutter/material.dart';
// Nhớ dòng import này phải trúng tên file bạn đã tạo
import 'screens/tech_store_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý Cửa hàng',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false, // Để giữ giao diện vuông vức kiểu cũ
      ),
      // Gọi màn hình chính chúng ta vừa làm xong
      home: const TechStoreScreen(),
    );
  }
}
