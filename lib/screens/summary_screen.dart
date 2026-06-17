import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  String _selectedPeriod = 'Today';

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, _) {
        double earned = 0;
        double profit = 0;
        int count = 0;

        if (_selectedPeriod == 'Today') {
          earned = dataProvider.getTodayEarned();
          profit = dataProvider.getTodayProfit();
          count = dataProvider.getTodayEntries().length;
        } else if (_selectedPeriod == 'This Week') {
          earned = dataProvider.getThisWeekEarned();
          profit = dataProvider.getThisWeekProfit();
          count = dataProvider.getThisWeekEntries().length;
        } else if (_selectedPeriod == 'This Month') {
          earned = dataProvider.getThisMonthEarned();
          profit = dataProvider.getThisMonthProfit();
          count = dataProvider.getThisMonthEntries().length;
        } else if (_selectedPeriod == 'Last Month') {
          earned = dataProvider.getLastMonthEarned();
          profit = dataProvider.getLastMonthProfit();
          count = dataProvider.getLastMonthEntries().length;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7F6),
          appBar: AppBar(
            title: const Text('Business Summary'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                Container(
                  color: const Color(0xFF0F6E56),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _PeriodChip(
                          label: 'Today',
                          isSelected: _selectedPeriod == 'Today',
                          onTap: () => setState(() => _selectedPeriod = 'Today'),
                        ),
                        _PeriodChip(
                          label: 'This Week',
                          isSelected: _selectedPeriod == 'This Week',
                          onTap: () => setState(() => _selectedPeriod = 'This Week'),
                        ),
                        _PeriodChip(
                          label: 'This Month',
                          isSelected: _selectedPeriod == 'This Month',
                          onTap: () => setState(() => _selectedPeriod = 'This Month'),
                        ),
                        _PeriodChip(
                          label: 'Last Month',
                          isSelected: _selectedPeriod == 'Last Month',
                          onTap: () => setState(() => _selectedPeriod = 'Last Month'),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Stat Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Total Revenue',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${NumberFormat('#,##,###.##').format(earned)}',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F6E56),
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatItem(
                                  label: 'Net Profit',
                                  value: '₹${profit.toStringAsFixed(0)}',
                                  color: Colors.blue.shade700,
                                ),
                                Container(width: 1, height: 40, color: Colors.grey.shade200),
                                _StatItem(
                                  label: 'Transactions',
                                  value: count.toString(),
                                  color: Colors.orange.shade700,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      const Text(
                        'Insights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _InsightCard(
                        icon: Icons.auto_graph,
                        title: 'Performance',
                        description: count > 0 
                          ? 'Average transaction value is ₹${(earned/count).toStringAsFixed(0)}'
                          : 'No data available for this period',
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 12),
                      _InsightCard(
                        icon: Icons.lightbulb_outline,
                        title: 'Quick Tip',
                        description: 'Consistent tracking helps in better financial planning.',
                        color: Colors.amber.shade800,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF0F6E56) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
