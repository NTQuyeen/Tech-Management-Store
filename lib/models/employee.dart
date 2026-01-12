class Employee {
  int? id;
  String fullName;
  String username;
  String email;

  /// Khi đổi mật khẩu: password = mật khẩu cũ
  String password;

  /// Khi đổi mật khẩu: newPassword = mật khẩu mới
  String? newPassword;

  String role; // admin / staff
  String status;

  Employee({
    this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    this.status = '',
    this.newPassword,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    int? parseId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString().trim());
    }

    return Employee(
      id: parseId(json['id'] ?? json['userId'] ?? json['user_id']),
      fullName: (json['fullName'] ?? json['full_name'] ?? json['name'] ?? '')
          .toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
      role: (json['role'] ?? json['userRole'] ?? 'staff').toString(),
      status: (json['status'] ?? '').toString(),
      // newPassword không có trong response
    );
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      'fullName': fullName,
      'username': username,
      'email': email,
      'password': password, // tạo mới dùng password
      'role': role,
      'status': status,
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    final map = <String, dynamic>{
      'id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'role': role,
      'status': status,
    };

    // ✅ Nếu đổi mật khẩu: gửi password (cũ) + newPassword (mới)
    if (newPassword != null && newPassword!.trim().isNotEmpty) {
      map['password'] = password; // old password
      map['newPassword'] = newPassword; // new password
    }

    // ❗ Nếu không đổi mật khẩu: KHÔNG gửi password để tránh ghi đè bậy
    return map;
  }
}
