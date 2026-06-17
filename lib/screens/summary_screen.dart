import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  String _selectedPeriod = 'This Week';

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, _) {
        late double totalEarned, totalSpent, netProfit;
        late int totalEntries;
        late List<Entry> entries;

        if (_selectedPeriod == 'This Week') {
          entries = dataProvider.getThisWeekEntries();
          totalEarned = dataProvider.getThisWeekEarned();
          totalSpent = dataProvider.getThisWeekSpent();
        } else if (_selectedPeriod == 'This Month') {
          entries = dataProvider.getThisMonthEntries();
          totalEarned = dataProvider.getThisMonthEarned();
          totalSpent = dataProvider.getThisMonthSpent();
        } else {
          entries = dataProvider.getTodayEntries();
          totalEarned = dataProvider.getTodayEarned();
          totalSpent = dataProvider.getTodaySpent();
        }

        netProfit = totalEarned - totalSpent;
        totalEntries = entries.length;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period toggle
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _PeriodButton(
                      label: 'This Week',
                      isSelected: _selectedPeriod == 'This Week',
                      onTap: () {
                        setState(() => _selectedPeriod = 'This Week');
                      },
                    ),
                    const SizedBox(width: 8),
                    _PeriodButton(
                      label: 'This Month',
                      isSelected: _selectedPeriod == 'This Month',
                      onTap: () {
                        setState(() => _selectedPeriod = 'This Month');
                      },
                    ),
                    const SizedBox(width: 8),
                    _PeriodButton(
                      label: 'Last Month',
                      isSelected: _selectedPeriod == 'Last Month',
                      onTap: () {
                        setState(() => _selectedPeriod = 'Last Month');
                      },
                    ),
                  ],
                ),
              ),
              // Stat cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryStatCard(
                            title: 'Total Earned',
                            amount: totalEarned,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryStatCard(
                            title: 'Total Spent',
                            amount: totalSpent,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryStatCard(
                            title: 'Net Profit',
                            amount: netProfit,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryStatCard(
                            title: 'Total Entries',
                            amount: totalEntries.toDouble(),
                            color: Colors.purple,
                            isCount: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Bar chart
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Earned vs Spent',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: _BarChartWidget(entries: entries),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Service breakdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Type Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ServiceBreakdownList(entries: entries),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F6E56) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final bool isCount;

  const _SummaryStatCard({
    required this.title,
    required this.amount,
    required this.color,
    this.isCount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            isCount ? '${amount.toInt()}' : '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  final List<Entry> entries;

  const _BarChartWidget({required this.entries});

  @override
  Widget build(BuildContext context) {
    // Group entries by date
    final groupedByDate = <DateTime, double>{};
    for (final entry in entries) {
      final dateKey = DateTime(entry.date.year, entry.date.month, entry.date.day);
      groupedByDate.update(dateKey, (value) => value + entry.amount, ifAbsent: () => entry.amount);
    }

    final sortedDates = groupedByDate.keys.toList()..sort();
    final maxAmount = groupedByDate.values.isEmpty ? 1.0 : groupedByDate.values.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        barGroups: List.generate(
          sortedDates.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: groupedByDate[sortedDates[index]] ?? 0,
                color: const Color(0xFF0F6E56),
                width: 20,
              ),
            ],
          ),
        ),
        maxY: maxAmount * 1.2,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₹${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedDates.length) {
                  return Text(
                    DateFormat('d/M').format(sortedDates[index]),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceBreakdownList extends StatelessWidget {
  final List<Entry> entries;

  const _ServiceBreakdownList({required this.entries});

  @override
  Widget build(BuildContext context) {
    // Group by service type
    final groupedByService = <String, double>{};
    for (final entry in entries) {
      groupedByService.update(entry.serviceType, (value) => value + entry.amount,
          ifAbsent: () => entry.amount);
    }

    final totalAmount = groupedByService.values.fold(0.0, (a, b) => a + b);
    final sortedServices = groupedByService.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return Column(
      children: List.generate(
        sortedServices.length,
        (index) {
          final service = sortedServices[index];
          final percentage = (service.value / totalAmount * 100);
          final color = colors[index % colors.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        service.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      '₹${service.value.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 6,
                    backgroundColor: color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Import Entry from models
import '../models/entry.dart';
