import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/entry.dart';
import '../providers/data_provider.dart';
import 'package:intl/intl.dart';

class AddEntryScreen extends StatefulWidget {
  final Entry? entry;

  const AddEntryScreen({Key? key, this.entry}) : super(key: key);

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  late TextEditingController _serviceController;
  late TextEditingController _customerController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String _paymentType;
  late String _selectedPersonId;

  @override
  void initState() {
    super.initState();
    _serviceController = TextEditingController(text: widget.entry?.serviceType ?? '');
    _customerController = TextEditingController(text: widget.entry?.customerName ?? '');
    _amountController = TextEditingController(text: widget.entry?.amount.toString() ?? '');
    _noteController = TextEditingController(text: widget.entry?.note ?? '');
    _paymentType = widget.entry?.paymentType ?? 'Cash';
    _selectedPersonId = widget.entry?.personId ?? '';
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _customerController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'Add Entry' : 'Edit Entry'),
        elevation: 0,
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service name
                const Text(
                  'Service Name *',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _serviceController,
                  decoration: InputDecoration(
                    hintText: 'Enter service name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Customer name
                const Text(
                  'Customer Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _customerController,
                  decoration: InputDecoration(
                    hintText: 'Enter customer name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Amount
                const Text(
                  'Amount',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Note
                const Text(
                  'Note/Remark',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter note or remark',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Payment type
                const Text(
                  'Payment Type',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _PaymentTypeButton(
                        label: 'Cash',
                        isSelected: _paymentType == 'Cash',
                        onTap: () {
                          setState(() => _paymentType = 'Cash');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PaymentTypeButton(
                        label: 'Online',
                        isSelected: _paymentType == 'Online',
                        onTap: () {
                          setState(() => _paymentType = 'Online');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PaymentTypeButton(
                        label: 'Due',
                        isSelected: _paymentType == 'Due',
                        onTap: () {
                          setState(() => _paymentType = 'Due');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Person selector
                const Text(
                  'Person',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedPersonId.isEmpty ? null : _selectedPersonId,
                  hint: const Text('Select a person'),
                  items: dataProvider.people.map((person) {
                    return DropdownMenuItem(
                      value: person.id,
                      child: Text(person.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedPersonId = value ?? '');
                  },
                ),
                const SizedBox(height: 32),
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: _SmoothSaveButton(
                    onPressed: () async {
                      if (_serviceController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Service name is required')),
                        );
                        return;
                      }

                      final now = DateTime.now();
                      final entry = Entry(
                        id: widget.entry?.id ?? const Uuid().v4(),
                        serviceType: _serviceController.text,
                        customerName: _customerController.text,
                        amount: double.tryParse(_amountController.text) ?? 0,
                        note: _noteController.text,
                        paymentType: _paymentType,
                        personId: _selectedPersonId,
                        date: widget.entry?.date ?? now,
                        dayName: DateFormat('EEEE').format(now),
                      );

                      if (widget.entry == null) {
                        await dataProvider.addEntry(entry);
                      } else {
                        await dataProvider.updateEntry(entry);
                      }

                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SmoothSaveButton extends StatefulWidget {
  final Future<void> Function() onPressed;

  const _SmoothSaveButton({required this.onPressed});

  @override
  State<_SmoothSaveButton> createState() => _SmoothSaveButtonState();
}

class _SmoothSaveButtonState extends State<_SmoothSaveButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F6E56),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Save Entry',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentTypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F6E56) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFF0F6E56) : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
