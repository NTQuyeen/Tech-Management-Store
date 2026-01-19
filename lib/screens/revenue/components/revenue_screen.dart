import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/../../constants.dart';
import './revenue_stat_card.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  // Desktop Windows: backend chạy cùng máy -> localhost
  static const String BASE_URL = "http://localhost:8080/shopqtqt";

  bool _isDailyView = true;

  bool _loading = false;
  String? _error;

  // doanh thu ngày (hôm nay)
  int _todayRevenue = 0;
  List<CustomerSpend> _todayCustomers = [];

  // doanh thu tháng (tháng này)
  int _monthRevenue = 0;

  // thống kê phụ (optional) để fill vào RevenueStatCard
  int _totalOrders = 0; // số invoice items (không phải số hóa đơn)
  double _profit = 0; // tạm tính 20%

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isDailyView) {
        final res = await _fetchRevenueDate();
        _todayRevenue = res.total;

        // list trả về là các item bán (invoice items)
        _totalOrders = res.list.length;
        _profit = _todayRevenue * 0.2;

        // Group theo phone để ra danh sách khách
        final Map<String, CustomerSpend> grouped = {};

        for (final item in res.list) {
          final phone = (item.phone ?? "").trim();
          if (phone.isEmpty) continue;

          final qty = item.quantity ?? 0;
          final price =
              item.price ?? 0; // backend trả BigDecimal -> json number
          final spent = price * qty;

          grouped.putIfAbsent(phone, () => CustomerSpend(phone: phone));
          grouped[phone]!.totalQty += qty;
          grouped[phone]!.totalSpent += spent;
        }

        // Gọi /customer/{sdt} để lấy fullName (và email/address nếu muốn)
        final phones = grouped.keys.toList();
        final infos = await Future.wait(phones.map(_fetchCustomerByPhone));

        for (final info in infos) {
          if (info == null) continue;
          final g = grouped[info.phone];
          if (g != null) {
            g.fullName = info.fullName;
            g.email = info.email;
            g.address = info.address;
          }
        }

        final listCustomers = grouped.values.toList()
          ..sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
        _todayCustomers = listCustomers;
      } else {
        final res = await _fetchRevenueMonth();
        _monthRevenue = res.total;

        _totalOrders = res.list.length;
        _profit = _monthRevenue * 0.2;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  // =========================
  // API CALLS
  // =========================
  Future<RevenueResponse> _fetchRevenueDate() async {
    final uri = Uri.parse("$BASE_URL/revenue/date");
    final r = await http.get(uri);

    if (r.statusCode != 200) {
      throw Exception("GET /revenue/date lỗi: ${r.statusCode} - ${r.body}");
    }
    return RevenueResponse.fromJson(
      json.decode(r.body) as Map<String, dynamic>,
    );
  }

  Future<RevenueResponse> _fetchRevenueMonth() async {
    final uri = Uri.parse("$BASE_URL/revenue/month");
    final r = await http.get(uri);

    if (r.statusCode != 200) {
      throw Exception("GET /revenue/month lỗi: ${r.statusCode} - ${r.body}");
    }
    return RevenueResponse.fromJson(
      json.decode(r.body) as Map<String, dynamic>,
    );
  }

  Future<CustomerDTO?> _fetchCustomerByPhone(String phone) async {
    final uri = Uri.parse("$BASE_URL/customer/$phone");
    final r = await http.get(uri);

    if (r.statusCode == 404) return null;
    if (r.statusCode != 200) return null;

    return CustomerDTO.fromJson(json.decode(r.body) as Map<String, dynamic>);
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final totalRevenue = _isDailyView ? _todayRevenue : _monthRevenue;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER + TOGGLE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "DOANH THU",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    _buildToggleButton("Theo Ngày", true),
                    _buildToggleButton("Theo Tháng", false),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "Lỗi: $_error",
                style: const TextStyle(color: Colors.red),
              ),
            ),

          const SizedBox(height: 20),

          // STAT CARDS
          Row(
            children: [
              Expanded(
                child: RevenueStatCard(
                  title: _isDailyView
                      ? "DOANH THU HÔM NAY"
                      : "DOANH THU THÁNG NÀY",
                  value: _formatCurrency(totalRevenue.toDouble()),
                  icon: Icons.attach_money,
                  color: Colors.green,
                  percent: "",
                ),
              ),
              const SizedBox(width: 20),
              RevenueStatCard(
                title: "SỐ LƯỢNG ITEM",
                value: "$_totalOrders",
                icon: Icons.shopping_cart,
                color: Colors.orange,
                percent: "",
              ),
              const SizedBox(width: 20),
              RevenueStatCard(
                title: "LỢI NHUẬN (TẠM)",
                value: _formatCurrency(_profit),
                icon: Icons.pie_chart,
                color: Colors.blue,
                percent: "",
              ),
            ],
          ),

          const SizedBox(height: 24),

          // CONTENT (NO CHART!)
          _isDailyView ? _buildDailyView() : _buildMonthlyView(),
        ],
      ),
    );
  }

  Widget _buildDailyView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Khách hàng đã mua hôm nay",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (!_loading && _todayCustomers.isEmpty)
            Text(
              "Hôm nay chưa có khách mua.",
              style: TextStyle(color: Colors.grey.shade600),
            ),

          if (_todayCustomers.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  Colors.grey.shade100,
                ),
                columns: const [
                  DataColumn(label: Text("Khách hàng")),
                  DataColumn(label: Text("SĐT")),
                  DataColumn(label: Text("SL SP")),
                  DataColumn(label: Text("Tổng chi")),
                ],
                rows: _todayCustomers.map((c) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          (c.fullName == null || c.fullName!.trim().isEmpty)
                              ? "Không rõ"
                              : c.fullName!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(Text(c.phone)),
                      DataCell(Text("${c.totalQty}")),
                      DataCell(Text(_formatCurrency(c.totalSpent.toDouble()))),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthlyView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Doanh thu tháng này",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            _formatCurrency(_monthRevenue.toDouble()),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // TOGGLE
  Widget _buildToggleButton(String text, bool isDayMode) {
    final isSelected = _isDailyView == isDayMode;

    return InkWell(
      onTap: () async {
        if (_isDailyView == isDayMode) return;
        setState(() => _isDailyView = isDayMode);
        await _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isDayMode ? const Radius.circular(5) : Radius.zero,
            right: isDayMode ? Radius.zero : const Radius.circular(5),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // FORMAT
  String _formatCurrency(double amount) {
    return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ";
  }
}

// =========================
// MODELS (fit đúng RevenueResponse + ProductInvoiceResponse của bạn)
// RevenueResponse: { total: Long, list: List<ProductInvoiceResponse> }
// ProductInvoiceResponse fields: id, quantity, name, price, productCode, phone
// =========================
class RevenueResponse {
  final int total;
  final List<ProductInvoiceResponse> list;

  RevenueResponse({required this.total, required this.list});

  factory RevenueResponse.fromJson(Map<String, dynamic> json) {
    final total = (json['total'] ?? 0) as num;
    final raw = (json['list'] as List?) ?? [];
    return RevenueResponse(
      total: total.toInt(),
      list: raw
          .map(
            (e) => ProductInvoiceResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class ProductInvoiceResponse {
  final int? id;
  final int? quantity;
  final String? name;
  final int? price;
  final String? productCode;
  final String? phone;

  ProductInvoiceResponse({
    this.id,
    this.quantity,
    this.name,
    this.price,
    this.productCode,
    this.phone,
  });

  factory ProductInvoiceResponse.fromJson(Map<String, dynamic> json) {
    return ProductInvoiceResponse(
      id: (json['id'] as num?)?.toInt(),
      quantity: (json['quantity'] as num?)?.toInt(),
      name: json['name']?.toString(),
      price: (json['price'] as num?)?.toInt(),
      productCode: json['productCode']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}

class CustomerDTO {
  final int? id;
  final String? fullName;
  final String phone;
  final String? email;
  final String? address;

  CustomerDTO({
    this.id,
    this.fullName,
    required this.phone,
    this.email,
    this.address,
  });

  factory CustomerDTO.fromJson(Map<String, dynamic> json) {
    return CustomerDTO(
      id: (json['id'] as num?)?.toInt(),
      fullName: json['fullName']?.toString(),
      phone: json['phone']?.toString() ?? "",
      email: json['email']?.toString(),
      address: json['address']?.toString(),
    );
  }
}

// Group theo SĐT để hiện “khách đã mua”
class CustomerSpend {
  final String phone;
  String? fullName;
  String? email;
  String? address;

  int totalQty = 0;
  int totalSpent = 0;

  CustomerSpend({required this.phone});
}
