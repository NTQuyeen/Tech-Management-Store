import 'package:flutter/material.dart';
import '../../models/employee.dart';
import '../../widgets/label_input.dart';

class EmployeeFormDialog extends StatefulWidget {
  final Employee? employee; // Nếu null là Thêm, có dữ liệu là Sửa
  final Function(Employee) onSave;

  const EmployeeFormDialog({super.key, this.employee, required this.onSave});

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog>
    with SingleTickerProviderStateMixin {
  // Controllers cho Thông tin
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _selectedRole = 'QUANLY';

  // Controllers cho Mật khẩu (Chỉ dùng khi sửa)
  final _passwordCtrl = TextEditingController(); // Dùng cho thêm mới
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (widget.employee != null) {
      // Load dữ liệu cũ
      _fullNameCtrl.text = widget.employee!.fullName;
      _usernameCtrl.text = widget.employee!.username;
      _emailCtrl.text = widget.employee!.email;
      _selectedRole = widget.employee!.role;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nếu là Thêm mới -> Hiển thị Form đơn giản cũ
    if (widget.employee == null) {
      return _buildAddLayout();
    }
    // Nếu là Sửa -> Hiển thị Form có Tab như yêu cầu
    return _buildEditLayout();
  }

  // ==================== GIAO DIỆN THÊM MỚI (GIỮ NGUYÊN) ====================
  Widget _buildAddLayout() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader("THÊM TÀI KHOẢN"),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  LabelInput(
                    label: "Họ tên",
                    controller: _fullNameCtrl,
                    isVertical: true,
                  ),
                  LabelInput(
                    label: "Tên đăng nhập",
                    controller: _usernameCtrl,
                    isVertical: true,
                  ),
                  LabelInput(
                    label: "Email",
                    controller: _emailCtrl,
                    isVertical: true,
                  ),
                  LabelInput(
                    label: "Mật khẩu",
                    controller: _passwordCtrl,
                    isVertical: true,
                    isPassword: true,
                  ),
                  _buildRoleDropdown(),
                  const SizedBox(height: 20),
                  _buildBottomButtons("Thêm"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== GIAO DIỆN SỬA (CÓ 2 TAB) ====================
  Widget _buildEditLayout() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: SizedBox(
        width: 450,
        height: 550, // Chiều cao cố định để TabBarView hoạt động tốt
        child: Column(
          children: [
            _buildHeader("SỬA THÔNG TIN TÀI KHOẢN"),

            // --- THANH TAB ---
            Container(
              color: Colors.grey[200],
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: const [
                  Tab(text: "Thông tin"),
                  Tab(text: "Mật khẩu"),
                ],
              ),
            ),

            // --- NỘI DUNG TAB ---
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: THÔNG TIN
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        // Tên đăng nhập (Thường không cho sửa -> ReadOnly)
                        LabelInput(
                          label: "Tên đăng nhập",
                          controller: _usernameCtrl,
                          isVertical: true,
                        ), // Có thể thêm readOnly: true vào LabelInput nếu muốn chặn sửa
                        LabelInput(
                          label: "Họ tên",
                          controller: _fullNameCtrl,
                          isVertical: true,
                        ),
                        LabelInput(
                          label: "Email",
                          controller: _emailCtrl,
                          isVertical: true,
                        ),
                        _buildRoleDropdown(),
                        const Spacer(),
                        _buildBottomButtons("Xác nhận"),
                      ],
                    ),
                  ),

                  // TAB 2: MẬT KHẨU
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        LabelInput(
                          label: "Mật khẩu cũ",
                          controller: _oldPassCtrl,
                          isVertical: true,
                          isPassword: true,
                        ),
                        LabelInput(
                          label: "Mật khẩu mới",
                          controller: _newPassCtrl,
                          isVertical: true,
                          isPassword: true,
                        ),
                        LabelInput(
                          label: "Nhập lại mật khẩu",
                          controller: _confirmPassCtrl,
                          isVertical: true,
                          isPassword: true,
                        ),
                        const Spacer(),
                        _buildBottomButtons("Xác nhận"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET DÙNG CHUNG ---

  Widget _buildHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.cyanAccent[400], // Màu xanh sáng giống hình
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return LabelInput(
      label: "Vai trò",
      isVertical: true,
      widget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedRole,
            isExpanded: true,
            items: [
              'QUANLY',
              'NHANVIEN',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _selectedRole = val!),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(String confirmText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 120,
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Hủy",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(
          width: 120,
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
              side: const BorderSide(
                color: Colors.grey,
              ), // Viền nhẹ cho nút trắng
            ),
            onPressed: _saveData,
            child: Text(
              confirmText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // --- LOGIC LƯU DỮ LIỆU ---
  void _saveData() {
    // 1. Nếu đang ở Tab Mật khẩu (index 1) và là Sửa -> Xử lý đổi pass
    if (widget.employee != null && _tabController.index == 1) {
      // Logic kiểm tra mật khẩu cũ/mới (Mockup)
      if (_newPassCtrl.text != _confirmPassCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mật khẩu nhập lại không khớp!")),
        );
        return;
      }
      // Cập nhật mật khẩu vào object (Thực tế cần check pass cũ đúng không)
      widget.employee!.password = _newPassCtrl.text;
    }

    // 2. Logic Lưu chung (Thông tin hoặc Thêm mới)
    if (_usernameCtrl.text.isNotEmpty) {
      final empToSave = Employee(
        id: widget.employee?.id ?? DateTime.now().toString(),
        fullName: _fullNameCtrl.text,
        username: _usernameCtrl.text,
        email: _emailCtrl.text,
        password: widget.employee != null
            ? widget.employee!.password
            : _passwordCtrl.text, // Giữ pass cũ nếu chỉ sửa info
        role: _selectedRole,
        status: widget.employee?.status ?? 'Hoạt động',
      );

      widget.onSave(empToSave);
      Navigator.pop(context);
    }
  }
}
