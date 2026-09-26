import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final data = provider.expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = data.fold<double>(0, (sum, item) => sum + item.value);
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Chi tiêu tháng này',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              currency.format(total),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 28),
            if (data.isEmpty)
              const SizedBox(
                height: 280,
                child: Center(child: Text('Chưa có dữ liệu chi tiêu')),
              )
            else
              SizedBox(
                height: 280,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 62,
                    sections: List.generate(data.length, (index) {
                      final item = data[index];
                      final percent = total == 0 ? 0 : item.value / total * 100;
                      return PieChartSectionData(
                        value: item.value,
                        color: Colors.primaries[index % Colors.primaries.length],
                        radius: 62,
                        title: '${percent.toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            ...List.generate(data.length, (index) {
              final item = data[index];
              final color = Colors.primaries[index % Colors.primaries.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    leading: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(item.key),
                    trailing: Text(
                      currency.format(item.value),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
