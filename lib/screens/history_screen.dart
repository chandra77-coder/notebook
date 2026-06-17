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
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

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

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar with smooth animation
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _AnimatedSearchBar(
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
                // Filter pills with smooth transitions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _SmoothFilterPill(
                          label: 'All',
                          isSelected: _selectedFilter == 'All',
                          onTap: () {
                            setState(() => _selectedFilter = 'All');
                          },
                        ),
                        _SmoothFilterPill(
                          label: 'Today',
                          isSelected: _selectedFilter == 'Today',
                          onTap: () {
                            setState(() => _selectedFilter = 'Today');
                          },
                        ),
                        _SmoothFilterPill(
                          label: 'This Week',
                          isSelected: _selectedFilter == 'This Week',
                          onTap: () {
                            setState(() => _selectedFilter = 'This Week');
                          },
                        ),
                        _SmoothFilterPill(
                          label: 'This Month',
                          isSelected: _selectedFilter == 'This Month',
                          onTap: () {
                            setState(() => _selectedFilter = 'This Month');
                          },
                        ),
                        _SmoothFilterPill(
                          label: 'Cash',
                          isSelected: _selectedFilter == 'Cash',
                          onTap: () {
                            setState(() => _selectedFilter = 'Cash');
                          },
                        ),
                        _SmoothFilterPill(
                          label: 'Online',
                          isSelected: _selectedFilter == 'Online',
                          onTap: () {
                            setState(() => _selectedFilter = 'Online');
                          },
                        ),
                        _SmoothFilterPill(
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
                          ...entry.value.asMap().entries.map((e) {
                            return _SmoothHistoryEntryCard(
                              entry: e.value,
                              delay: e.key,
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedSearchBar extends StatefulWidget {
  final Function(String) onChanged;

  const _AnimatedSearchBar({required this.onChanged});

  @override
  State<_AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<_AnimatedSearchBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: TextField(
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: 'Search by customer or service',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF0F6E56),
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SmoothFilterPill extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SmoothFilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SmoothFilterPill> createState() => _SmoothFilterPillState();
}

class _SmoothFilterPillState extends State<_SmoothFilterPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_SmoothFilterPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isSelected ? const Color(0xFF0F6E56) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _SmoothHistoryEntryCard extends StatefulWidget {
  final Entry entry;
  final int delay;

  const _SmoothHistoryEntryCard({
    required this.entry,
    required this.delay,
  });

  @override
  State<_SmoothHistoryEntryCard> createState() => _SmoothHistoryEntryCardState();
}

class _SmoothHistoryEntryCardState extends State<_SmoothHistoryEntryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(Duration(milliseconds: widget.delay * 80), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentColor = widget.entry.paymentType == 'Cash'
        ? Colors.green
        : widget.entry.paymentType == 'Online'
            ? Colors.blue
            : Colors.orange;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.translate(
        offset: Offset(0, _slideAnimation.value),
        child: Dismissible(
          key: Key(widget.entry.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            context.read<DataProvider>().deleteEntry(widget.entry.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Entry deleted'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    context.read<DataProvider>().undoDeleteEntry();
                  },
                ),
              ),
            );
          },
          child: Container(
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
                            widget.entry.serviceType,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            widget.entry.customerName,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            DateFormat('hh:mm a').format(widget.entry.date),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${widget.entry.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (widget.entry.note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.entry.note,
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
                        widget.entry.paymentType,
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
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    AddEntryScreen(entry: widget.entry),
                                transitionsBuilder:
                                    (context, animation, secondaryAnimation, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 1),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    ),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 16),
                          onPressed: () {
                            context.read<DataProvider>().deleteEntry(widget.entry.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Entry deleted'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    context.read<DataProvider>().undoDeleteEntry();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        if (widget.entry.paymentType == 'Due')
                          IconButton(
                            icon: const Icon(Icons.check_circle, size: 16),
                            onPressed: () {
                              final updatedEntry = widget.entry.copyWith(paymentType: 'Cash');
                              context.read<DataProvider>().updateEntry(updatedEntry);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Marked as received')),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
