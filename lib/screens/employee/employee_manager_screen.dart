import 'package:flutter/material.dart';
import '../../models/employee.dart';
import 'employee_form_dialog.dart';
import '../../services/employee_api.dart';

class EmployeeManagerScreen extends StatefulWidget {
  const EmployeeManagerScreen({super.key});

  @override
  State<EmployeeManagerScreen> createState() => _EmployeeManagerScreenState();
}

class _EmployeeManagerScreenState extends State<EmployeeManagerScreen> {
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];

  final _searchCtrl = TextEditingController();
  int? _selectedIndex;

  final EmployeeApi _employeeApi = EmployeeApi();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final items = await _employeeApi.list();
      setState(() {
        _employees = items;
        _filteredEmployees = List.from(items);
        _selectedIndex = null;
      });
    } catch (e) {
      _showError('Không tải được danh sách nhân viên: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSearch(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredEmployees = List.from(_employees);
      } else {
        final q = value.toLowerCase();
        _filteredEmployees = _employees
            .where(
              (e) =>
                  e.fullName.toLowerCase().contains(q) ||
                  e.username.toLowerCase().contains(q),
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
        onSave: (newEmployee) async {
          try {
            await _employeeApi.create(newEmployee);
            await _loadEmployees();
          } catch (e) {
            _showError('Thêm nhân viên thất bại: $e');
          }
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
        onSave: (updatedEmployee) async {
          try {
            await _employeeApi.update(updatedEmployee);
            await _loadEmployees();
          } catch (e) {
            _showError('Cập nhật nhân viên thất bại: $e');
          }
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
            onPressed: () async {
              final emp = _filteredEmployees[_selectedIndex!];
              try {
                // ✅ FIX: id phải là số (int)
                if (emp.id == null) {
                  throw Exception('Nhân viên không có id hợp lệ để xóa');
                }
                await _employeeApi.deleteById(emp.id!);
                await _loadEmployees();
              } catch (e) {
                _showError('Xóa nhân viên thất bại: $e');
              }
              if (context.mounted) Navigator.pop(ctx);
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    // const SizedBox(width: 20),
                    // _buildTopButton(
                    //   "Xuất Excel",
                    //   Icons.file_download,
                    //   Colors.green.shade800,
                    //   () {},
                    // ),
                  ],
                ),
              ),
              const Spacer(),
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
                        SizedBox(
                          width: 260,
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
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        const SizedBox(height: 18),
                        IconButton(
                          onPressed: () {
                            _searchCtrl.clear();
                            _handleSearch('');
                            _loadEmployees();
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.white,
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          Colors.grey[200],
                        ),
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
                              (states) => isSelected
                                  ? Colors.blue.withOpacity(0.1)
                                  : null,
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

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
