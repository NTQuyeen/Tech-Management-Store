import 'package:flutter/material.dart';
import '/../../constants.dart';

// Import các components vừa tách
import './revenue_stat_card.dart';
import './revenue_chart.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  bool _isDailyView = true;

  // --- MOCK DATA ---
  final List<Map<String, dynamic>> _dailyData = [
    {'label': '01/12', 'revenue': 15000000, 'orders': 5},
    {'label': '02/12', 'revenue': 22000000, 'orders': 8},
    {'label': '03/12', 'revenue': 18500000, 'orders': 6},
    {'label': '04/12', 'revenue': 32000000, 'orders': 12},
    {'label': '05/12', 'revenue': 12000000, 'orders': 4},
    {'label': '06/12', 'revenue': 28000000, 'orders': 10},
    {'label': 'Hôm nay', 'revenue': 45000000, 'orders': 15},
  ];

  final List<Map<String, dynamic>> _monthlyData = [
    {'label': 'Thg 1', 'revenue': 120000000, 'orders': 45},
    {'label': 'Thg 2', 'revenue': 98000000, 'orders': 38},
    {'label': 'Thg 3', 'revenue': 150000000, 'orders': 60},
    {'label': 'Thg 4', 'revenue': 110000000, 'orders': 50},
    {'label': 'Thg 5', 'revenue': 180000000, 'orders': 75},
    {'label': 'Thg 6', 'revenue': 210000000, 'orders': 90},
    {'label': 'Thg 7', 'revenue': 195000000, 'orders': 85},
    {'label': 'Thg 8', 'revenue': 230000000, 'orders': 100},
    {'label': 'Thg 9', 'revenue': 170000000, 'orders': 70},
    {'label': 'Thg 10', 'revenue': 140000000, 'orders': 55},
    {'label': 'Thg 11', 'revenue': 260000000, 'orders': 110},
    {'label': 'Thg 12', 'revenue': 300000000, 'orders': 130},
  ];

  final List<Map<String, dynamic>> _topProducts = [
    {'name': 'iPhone 15 Pro Max', 'qty': 120, 'revenue': 3800000000},
    {'name': 'Samsung S24 Ultra', 'qty': 95, 'revenue': 2850000000},
    {'name': 'Macbook Air M1', 'qty': 80, 'revenue': 1480000000},
    {'name': 'Chuột Logitech G102', 'qty': 300, 'revenue': 150000000},
  ];

  // --- LOGIC ---
  List<Map<String, dynamic>> get _currentData =>
      _isDailyView ? _dailyData : _monthlyData;

  double get _totalRevenue => _currentData.fold(
    0,
    (sum, item) => sum + (item['revenue'] as num).toDouble(),
  );

  int get _totalOrders =>
      _currentData.fold(0, (sum, item) => sum + (item['orders'] as int));

  double get _totalProfit => _totalRevenue * 0.2;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TỔNG QUAN KINH DOANH",
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
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade300,
                    ),
                    _buildToggleButton("Theo Tháng", false),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. THẺ THỐNG KÊ
          Row(
            children: [
              RevenueStatCard(
                title: "DOANH THU",
                value: _formatCurrency(_totalRevenue),
                icon: Icons.monetization_on,
                color: Colors.green,
                percent: "+12%",
              ),
              const SizedBox(width: 20),
              RevenueStatCard(
                title: "ĐƠN HÀNG",
                value: "$_totalOrders",
                icon: Icons.shopping_cart,
                color: Colors.orange,
                percent: "-5%",
              ),
              const SizedBox(width: 20),
              RevenueStatCard(
                title: "LỢI NHUẬN",
                value: _formatCurrency(_totalProfit),
                icon: Icons.pie_chart,
                color: Colors.blue,
                percent: "+8%",
              ),
            ],
          ),
          const SizedBox(height: 30),

          // 3. BIỂU ĐỒ + TOP PRODUCTS
          SizedBox(
            height: 450,
            child: Row(
              children: [
                // Chart
                Expanded(
                  flex: 7,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Biểu đồ doanh thu (${_isDailyView ? '7 ngày qua' : 'Năm 2024'})",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Expanded(
                          child: RevenueChart(
                            data: _currentData,
                            isDailyView: _isDailyView,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // TOP PRODUCTS
                Expanded(flex: 3, child: _buildTopProductsList()),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 4. BẢNG CHI TIẾT
          _buildDetailTable(),
        ],
      ),
    );
  }

  // ---------------- WIDGET PHỤ ----------------

  Widget _buildTopProductsList() {
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
            "Top Bán Chạy",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          Expanded(
            child: ListView.separated(
              itemCount: _topProducts.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, index) {
                final item = _topProducts[index];

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: index == 0
                        ? Colors.amber
                        : Colors.grey[200],
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: index == 0 ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  title: Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text("${item['qty']} đã bán"),
                  trailing: Text(
                    _formatCompactCurrency(item['revenue']),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),

          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text("Xem tất cả"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTable() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Chi tiết giao dịch",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.file_download, size: 18),
                label: const Text("Xuất Báo Cáo"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
              columns: const [
                DataColumn(label: Text("Thời gian")),
                DataColumn(label: Text("Số đơn hàng")),
                DataColumn(label: Text("Doanh thu")),
                DataColumn(label: Text("Trạng thái")),
              ],
              rows: _currentData.map((e) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        e['label'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(Text("${e['orders']}")),
                    DataCell(
                      Text(_formatCurrency((e['revenue'] as num).toDouble())),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "Đã chốt",
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isDayMode) {
    final isSelected = _isDailyView == isDayMode;

    return InkWell(
      onTap: () => setState(() => _isDailyView = isDayMode),
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

  // ---------------- FORMAT ----------------
  String _formatCurrency(double amount) {
    return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (m) => '${m[1]}.')} đ";
  }

  String _formatCompactCurrency(num amount) {
    if (amount >= 1000000000)
      return "${(amount / 1000000000).toStringAsFixed(1)}B";
    if (amount >= 1000000) return "${(amount / 1000000).toStringAsFixed(0)}M";
    if (amount >= 1000) return "${(amount / 1000).toStringAsFixed(0)}K";
    return amount.toString();
  }
}
