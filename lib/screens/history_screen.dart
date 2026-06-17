import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';
import '../models/entry.dart';
import 'add_entry_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with TickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, _) {
        var filteredEntries = dataProvider.entries;

        // Apply filter
        if (_selectedFilter == 'Today') {
          filteredEntries = dataProvider.getTodayEntries();
        } else if (_selectedFilter == 'This Week') {
          filteredEntries = dataProvider.getThisWeekEntries();
        } else if (_selectedFilter == 'This Month') {
          filteredEntries = dataProvider.getThisMonthEntries();
        } else if (_selectedFilter == 'Cash') {
          filteredEntries = filteredEntries.where((e) => e.paymentType == 'Cash').toList();
        } else if (_selectedFilter == 'Online') {
          filteredEntries = filteredEntries.where((e) => e.paymentType == 'Online').toList();
        } else if (_selectedFilter == 'Due') {
          filteredEntries = filteredEntries.where((e) => e.paymentType == 'Due').toList();
        }

        // Apply search
        if (_searchQuery.isNotEmpty) {
          filteredEntries = filteredEntries
              .where((e) => e.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  e.serviceType.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
        }

        // Sort by date descending
        filteredEntries.sort((a, b) => b.date.compareTo(a.date));

        // Group by date
        final groupedEntries = <DateTime, List<Entry>>{};
        for (final entry in filteredEntries) {
          final dateKey = DateTime(entry.date.year, entry.date.month, entry.date.day);
          groupedEntries.putIfAbsent(dateKey, () => []).add(entry);
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7F6),
          appBar: AppBar(
            title: const Text('Transaction History'),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Search and Filter Header
              Container(
                color: const Color(0xFF0F6E56),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                  children: [
                    _ModernSearchBar(
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _ModernFilterChip(
                            label: 'All',
                            isSelected: _selectedFilter == 'All',
                            onTap: () => setState(() => _selectedFilter = 'All'),
                          ),
                          _ModernFilterChip(
                            label: 'Today',
                            isSelected: _selectedFilter == 'Today',
                            onTap: () => setState(() => _selectedFilter = 'Today'),
                          ),
                          _ModernFilterChip(
                            label: 'This Week',
                            isSelected: _selectedFilter == 'This Week',
                            onTap: () => setState(() => _selectedFilter = 'This Week'),
                          ),
                          _ModernFilterChip(
                            label: 'Cash',
                            isSelected: _selectedFilter == 'Cash',
                            onTap: () => setState(() => _selectedFilter = 'Cash'),
                          ),
                          _ModernFilterChip(
                            label: 'Online',
                            isSelected: _selectedFilter == 'Online',
                            onTap: () => setState(() => _selectedFilter = 'Online'),
                          ),
                          _ModernFilterChip(
                            label: 'Due',
                            isSelected: _selectedFilter == 'Due',
                            onTap: () => setState(() => _selectedFilter = 'Due'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // History List
              Expanded(
                child: filteredEntries.isEmpty
                  ? _EmptyHistoryState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: groupedEntries.length,
                      itemBuilder: (context, index) {
                        final date = groupedEntries.keys.elementAt(index);
                        final entries = groupedEntries[date]!;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
                              child: Text(
                                _formatDateHeader(date),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            ...entries.map((entry) => _ModernHistoryCard(entry: entry)).toList(),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return 'TODAY';
    if (checkDate == yesterday) return 'YESTERDAY';
    return DateFormat('EEEE, d MMMM').format(date).toUpperCase();
  }
}

class _ModernSearchBar extends StatelessWidget {
  final Function(String) onChanged;

  const _ModernSearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _ModernFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModernFilterChip({
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
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF0F6E56) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ModernHistoryCard extends StatelessWidget {
  final Entry entry;

  const _ModernHistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final paymentColor = entry.paymentType == 'Cash'
        ? const Color(0xFF0F6E56)
        : entry.paymentType == 'Online'
            ? Colors.blue.shade700
            : Colors.orange.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: paymentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              entry.paymentType == 'Due' ? Icons.timer_outlined : Icons.receipt_long_outlined,
              color: paymentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.serviceType,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  entry.customerName.isEmpty ? 'General Customer' : entry.customerName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${entry.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('hh:mm a').format(entry.date),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
