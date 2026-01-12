import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../constants.dart';

class RevenueChart extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final bool isDailyView;

  const RevenueChart({
    super.key,
    required this.data,
    required this.isDailyView,
  });

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final maxY = _getSafeMaxRevenue();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            // Một số version dùng tooltipBgColor, một số dùng getTooltipColor
            // Nếu IDE báo lỗi getTooltipColor thì đổi sang tooltipBgColor: Colors.blueAccent,
            getTooltipColor: (_) => Colors.blueAccent,

            // ✅ tooltipRoundedRadius là double, KHÔNG phải BorderRadius
            tooltipRoundedRadius: 8,

            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final i = group.x.toInt();
              final label = (i >= 0 && i < widget.data.length)
                  ? (widget.data[i]['label']?.toString() ?? '')
                  : '';

              return BarTooltipItem(
                '$label\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: _formatCompactCurrency(rod.toY),
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  barTouchResponse?.spot == null) {
                _touchedIndex = -1;
              } else {
                _touchedIndex = barTouchResponse!.spot!.touchedBarGroupIndex;
              }
            });
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                final int index = value.toInt();
                if (index >= 0 && index < widget.data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      widget.data[index]['label']?.toString() ?? '',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  _formatCompactCurrency(value),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: widget.data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          final yValue = _toDouble(item['revenue']);
          final isTouched = index == _touchedIndex;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: yValue,
                color: isTouched ? Colors.orange : AppColors.primary,
                width: widget.isDailyView ? 30 : 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: Colors.grey.shade100,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Parse revenue an toàn
  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  /// Prevent maxY = 0 causing chart not visible
  double _getSafeMaxRevenue() {
    final maxVal = _getMaxRevenue();
    if (maxVal <= 0) return 1000; // default minimum scale
    return maxVal * 1.2;
  }

  double _getMaxRevenue() {
    double maxVal = 0;
    for (final e in widget.data) {
      final revenue = _toDouble(e['revenue']);
      if (revenue > maxVal) maxVal = revenue;
    }
    return maxVal;
  }

  /// Format numbers like: 1K, 2M, 1.2B
  String _formatCompactCurrency(num amount) {
    if (amount >= 1000000000) {
      return "${(amount / 1000000000).toStringAsFixed(1)}B";
    }
    if (amount >= 1000000) {
      return "${(amount / 1000000).toStringAsFixed(0)}M";
    }
    if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(0)}K";
    }
    return amount.toStringAsFixed(0);
  }
}
