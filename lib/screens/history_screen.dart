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

class _HistoryScreenState extends State<HistoryScreen> {
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

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by customer or service',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              // Filter pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterPill(
                        label: 'All',
                        isSelected: _selectedFilter == 'All',
                        onTap: () {
                          setState(() => _selectedFilter = 'All');
                        },
                      ),
                      _FilterPill(
                        label: 'Today',
                        isSelected: _selectedFilter == 'Today',
                        onTap: () {
                          setState(() => _selectedFilter = 'Today');
                        },
                      ),
                      _FilterPill(
                        label: 'This Week',
                        isSelected: _selectedFilter == 'This Week',
                        onTap: () {
                          setState(() => _selectedFilter = 'This Week');
                        },
                      ),
                      _FilterPill(
                        label: 'This Month',
                        isSelected: _selectedFilter == 'This Month',
                        onTap: () {
                          setState(() => _selectedFilter = 'This Month');
                        },
                      ),
                      _FilterPill(
                        label: 'Cash',
                        isSelected: _selectedFilter == 'Cash',
                        onTap: () {
                          setState(() => _selectedFilter = 'Cash');
                        },
                      ),
                      _FilterPill(
                        label: 'Online',
                        isSelected: _selectedFilter == 'Online',
                        onTap: () {
                          setState(() => _selectedFilter = 'Online');
                        },
                      ),
                      _FilterPill(
                        label: 'Due',
                        isSelected: _selectedFilter == 'Due',
                        onTap: () {
                          setState(() => _selectedFilter = 'Due');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Entries grouped by date
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: groupedEntries.entries.map((entry) {
                    final date = entry.key;
                    final dayName = DateFormat('EEEE').format(date);
                    final formattedDate = DateFormat('d MMMM yyyy').format(date);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$dayName $formattedDate',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...entry.value.map((e) => _HistoryEntryCard(entry: e)),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
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

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F6E56) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
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

class _HistoryEntryCard extends StatelessWidget {
  final Entry entry;

  const _HistoryEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final paymentColor = entry.paymentType == 'Cash'
        ? Colors.green
        : entry.paymentType == 'Online'
            ? Colors.blue
            : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: paymentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.serviceType,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      entry.customerName,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(entry.date),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${entry.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (entry.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              entry.note,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: paymentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  entry.paymentType,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: paymentColor,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEntryScreen(entry: entry),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 16),
                    onPressed: () {
                      context.read<DataProvider>().deleteEntry(entry.id);
                    },
                  ),
                  if (entry.paymentType == 'Due')
                    IconButton(
                      icon: const Icon(Icons.check_circle, size: 16),
                      onPressed: () {
                        final updatedEntry = entry.copyWith(paymentType: 'Cash');
                        context.read<DataProvider>().updateEntry(updatedEntry);
                      },
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
