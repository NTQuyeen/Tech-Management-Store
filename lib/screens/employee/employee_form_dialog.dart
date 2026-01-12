import 'package:flutter/material.dart';
import '../../models/employee.dart';
import '../../widgets/label_input.dart';

class EmployeeFormDialog extends StatefulWidget {
  final Employee? employee; // null = Add; otherwise Edit
  final Future<void> Function(Employee) onSave;

  const EmployeeFormDialog({super.key, this.employee, required this.onSave});

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog>
    with SingleTickerProviderStateMixin {
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // ✅ role mới: admin / staff
  String _selectedRole = 'staff';

  final _passwordCtrl = TextEditingController(); // Add
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (widget.employee != null) {
      _fullNameCtrl.text = widget.employee!.fullName;
      _usernameCtrl.text = widget.employee!.username;
      _emailCtrl.text = widget.employee!.email;

      // ✅ nếu dữ liệu cũ đang là QUANLY/NHANVIEN thì map sang admin/staff
      final r = widget.employee!.role.toLowerCase().trim();
      if (r == 'quanly' || r == 'quản lý') {
        _selectedRole = 'admin';
      } else if (r == 'nhanvien' || r == 'nhân viên') {
        _selectedRole = 'staff';
      } else if (r == 'admin' || r == 'staff') {
        _selectedRole = r;
      } else {
        _selectedRole = 'staff';
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.employee == null ? _buildAddLayout() : _buildEditLayout();
  }

  Widget _buildAddLayout() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Container(
        width: 450,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader("THÊM TÀI KHOẢN"),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    LabelInput(
                      label: "Họ tên",
                      controller: _fullNameCtrl,
                      isVertical: true,
                    ),
                    const SizedBox(height: 15),
                    LabelInput(
                      label: "Tên đăng nhập",
                      controller: _usernameCtrl,
                      isVertical: true,
                    ),
                    const SizedBox(height: 15),
                    LabelInput(
                      label: "Email",
                      controller: _emailCtrl,
                      isVertical: true,
                    ),
                    const SizedBox(height: 15),
                    LabelInput(
                      label: "Mật khẩu",
                      controller: _passwordCtrl,
                      isVertical: true,
                      isPassword: true,
                    ),
                    const SizedBox(height: 15),
                    _buildRoleDropdown(),
                    const SizedBox(height: 30),
                    _buildBottomButtons("Thêm"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditLayout() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Container(
        width: 450,
        height: 600,
        child: Column(
          children: [
            _buildHeader("SỬA THÔNG TIN TÀI KHOẢN"),
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
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        LabelInput(
                          label: "Tên đăng nhập",
                          controller: _usernameCtrl,
                          isVertical: true,
                        ),
                        const SizedBox(height: 15),
                        LabelInput(
                          label: "Họ tên",
                          controller: _fullNameCtrl,
                          isVertical: true,
                        ),
                        const SizedBox(height: 15),
                        LabelInput(
                          label: "Email",
                          controller: _emailCtrl,
                          isVertical: true,
                        ),
                        const SizedBox(height: 15),
                        _buildRoleDropdown(),
                        const SizedBox(height: 30),
                        _buildBottomButtons("Xác nhận"),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        LabelInput(
                          label: "Mật khẩu cũ",
                          controller: _oldPassCtrl,
                          isVertical: true,
                          isPassword: true,
                        ),
                        const SizedBox(height: 15),
                        LabelInput(
                          label: "Mật khẩu mới",
                          controller: _newPassCtrl,
                          isVertical: true,
                          isPassword: true,
                        ),
                        const SizedBox(height: 15),
                        LabelInput(
                          label: "Nhập lại mật khẩu",
                          controller: _confirmPassCtrl,
                          isVertical: true,
                          isPassword: true,
                        ),
                        const SizedBox(height: 30),
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

  Widget _buildHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.cyanAccent[400],
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
            items: const [
              DropdownMenuItem(value: 'admin', child: Text('admin')),
              DropdownMenuItem(value: 'staff', child: Text('staff')),
            ],
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
              backgroundColor: Colors.yellowAccent[700],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
              side: const BorderSide(color: Colors.grey),
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

  Future<void> _saveData() async {
    // Validate cơ bản (tab thông tin hoặc add)
    if (_usernameCtrl.text.trim().isEmpty ||
        _fullNameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin!")),
      );
      return;
    }

    // Add: bắt buộc có password
    if (widget.employee == null && _passwordCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng nhập mật khẩu!")));
      return;
    }

    final isEdit = widget.employee != null;
    final isPasswordTab = isEdit && _tabController.index == 1;

    // Nếu đang đổi mật khẩu: check old/new/confirm
    if (isPasswordTab) {
      if (_oldPassCtrl.text.trim().isEmpty ||
          _newPassCtrl.text.trim().isEmpty ||
          _confirmPassCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng nhập đủ mật khẩu cũ/mới!")),
        );
        return;
      }

      if (_newPassCtrl.text != _confirmPassCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mật khẩu nhập lại không khớp!")),
        );
        return;
      }
    }

    final empToSave = Employee(
      id: widget.employee?.id,
      fullName: _fullNameCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      role: _selectedRole,
      status: widget.employee?.status ?? '',

      // ✅ Add: password là password mới
      // ✅ Edit tab thông tin: không đổi password, để tạm '' (vì toJsonForUpdate sẽ không gửi)
      // ✅ Edit tab mật khẩu: password = mật khẩu cũ
      password: widget.employee == null
          ? _passwordCtrl.text.trim()
          : (isPasswordTab ? _oldPassCtrl.text.trim() : ''),

      // ✅ chỉ set newPassword khi đang đổi mật khẩu
      newPassword: isPasswordTab ? _newPassCtrl.text.trim() : null,
    );

    await widget.onSave(empToSave);
    if (mounted) Navigator.pop(context);
  }
}
