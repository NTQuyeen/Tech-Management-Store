class Employee {
  String id;
  String fullName;
  String username;
  String email;
  String password; // Trong thực tế nên mã hóa
  String role; // QUANLY, NHANVIEN
  String status; // 1: Hoạt động, 0: Đã khóa (Dùng int hoặc String tùy logic)

  Employee({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    this.status = 'Hoạt động',
  });
}
