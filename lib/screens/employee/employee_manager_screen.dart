import 'package:flutter/material.dart';
import '../../models/employee.dart';
import '../../constants.dart';
// Import Dialog vừa tạo
import 'employee_form_dialog.dart';

class EmployeeManagerScreen extends StatefulWidget {
  const EmployeeManagerScreen({super.key});

  @override
  State<EmployeeManagerScreen> createState() => _EmployeeManagerScreenState();
}

class _EmployeeManagerScreenState extends State<EmployeeManagerScreen> {
  // Dữ liệu mẫu
  final List<Employee> _employees = [
    Employee(
      id: '1',
      username: 'admin',
      fullName: 'Nguyễn Thiện Quyền',
      email: 'thienquyenking@gmail.com',
      password: '123',
      role: 'QUANLY',
    ),
    Employee(
      id: '2',
      username: 'nhanvien1',
      fullName: 'Lê Quốc Huy',
      email: 'huy@gmail.com',
      password: '123',
      role: 'NHANVIEN',
    ),
    Employee(
      id: '3',
      username: 'nhanvien2',
      fullName: 'Nguyễn Quang Trường',
      email: 'truong@gmail.com',
      password: '123',
      role: 'NHANVIEN',
    ),
  ];
  List<Employee> _filteredEmployees = [];

  final _searchCtrl = TextEditingController();
  int? _selectedIndex;
  String _filterStatus = 'Hoạt động';

  @override
  void initState() {
    super.initState();
    _filteredEmployees = List.from(_employees);
  }

  // --- LOGIC ---
  void _handleSearch(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredEmployees = List.from(_employees);
      } else {
        _filteredEmployees = _employees
            .where(
              (e) =>
                  e.fullName.toLowerCase().contains(value.toLowerCase()) ||
                  e.username.toLowerCase().contains(value.toLowerCase()),
            )
            .toList();
      }
      _selectedIndex = null;
    });
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (_) => EmployeeFormDialog(
        onSave: (newEmployee) {
          setState(() {
            _employees.add(newEmployee);
            _handleSearch(_searchCtrl.text);
          });
        },
      ),
    );
  }

  void _openEditDialog() {
    if (_selectedIndex == null) return;
    showDialog(
      context: context,
      builder: (_) => EmployeeFormDialog(
        employee: _filteredEmployees[_selectedIndex!],
        onSave: (updatedEmployee) {
          setState(() {
            // Logic cập nhật (trong thực tế sẽ update DB)
            int index = _employees.indexWhere(
              (e) => e.id == updatedEmployee.id,
            );
            if (index != -1) _employees[index] = updatedEmployee;
            _handleSearch(_searchCtrl.text);
            _selectedIndex = null;
          });
        },
      ),
    );
  }

  void _deleteEmployee() {
    if (_selectedIndex == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa nhân viên này?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Không"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _employees.remove(_filteredEmployees[_selectedIndex!]);
                _handleSearch(_searchCtrl.text);
                _selectedIndex = null;
              });
              Navigator.pop(ctx);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- TOOLBAR ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Căn trên để khớp layout
            children: [
              // NHÓM CHỨC NĂNG (TRÁI)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    _buildTopButton(
                      "Thêm",
                      Icons.add_circle,
                      Colors.green,
                      _openAddDialog,
                    ),
                    const SizedBox(width: 20),
                    _buildTopButton(
                      "Sửa",
                      Icons.edit_square,
                      Colors.orange,
                      _openEditDialog,
                    ),
                    const SizedBox(width: 20),
                    _buildTopButton(
                      "Xóa",
                      Icons.delete,
                      Colors.red,
                      _deleteEmployee,
                    ),
                    const SizedBox(width: 20),
                    _buildTopButton(
                      "Xuất Excel",
                      Icons.file_download,
                      Colors.green.shade800,
                      () {},
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // NHÓM TÌM KIẾM (PHẢI)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Tìm kiếm",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            // Dropdown trạng thái
                            Container(
                              height: 35,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.grey[100],
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _filterStatus,
                                  items: ['Hoạt động', 'Đã khóa']
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => _filterStatus = val!),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            // Ô nhập
                            SizedBox(
                              width: 200,
                              height: 35,
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: _handleSearch,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    // Nút Refresh
                    Column(
                      children: [
                        const SizedBox(
                          height: 18,
                        ), // Để căn icon xuống dưới chữ "Tìm kiếm"
                        IconButton(
                          onPressed: () {
                            _searchCtrl.clear();
                            _handleSearch('');
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.blue,
                            size: 28,
                          ),
                          tooltip: "Làm mới",
                        ),
                        const Text("Làm mới", style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // --- BẢNG DỮ LIỆU ---
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                  showCheckboxColumn: false,
                  columns: const [
                    DataColumn(
                      label: Text(
                        "STT",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Tên Tài khoản",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Họ tên",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Email",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Vai trò",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: List.generate(_filteredEmployees.length, (index) {
                    final e = _filteredEmployees[index];
                    final isSelected = index == _selectedIndex;
                    return DataRow(
                      selected: isSelected,
                      onSelectChanged: (_) =>
                          setState(() => _selectedIndex = index),
                      color: MaterialStateProperty.resolveWith<Color?>(
                        (states) =>
                            isSelected ? Colors.blue.withOpacity(0.1) : null,
                      ),
                      cells: [
                        DataCell(Text("${index + 1}")),
                        DataCell(Text(e.username)),
                        DataCell(Text(e.fullName)),
                        DataCell(Text(e.email)),
                        DataCell(Text(e.role)),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon nằm trong hình vuông trắng, có bóng mờ
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
