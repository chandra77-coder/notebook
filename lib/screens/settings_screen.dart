import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SmoothSettingsButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Future<void> Function() onPressed;

  const _SmoothSettingsButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  State<_SmoothSettingsButton> createState() => _SmoothSettingsButtonState();
}

class _SmoothSettingsButtonState extends State<_SmoothSettingsButton> {
  bool _isPressed = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
      },
      onTapUp: (_) async {
        setState(() => _isPressed = false);
        if (!_isLoading) {
          setState(() => _isLoading = true);
          await widget.onPressed();
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _shopNameController;

  @override
  void initState() {
    super.initState();
    final themeProvider = context.read<ThemeProvider>();
    _shopNameController = TextEditingController(text: themeProvider.shopName);
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DataProvider, ThemeProvider>(
      builder: (context, dataProvider, themeProvider, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop name
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shop Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _shopNameController,
                      onChanged: (value) {
                        themeProvider.setShopName(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter shop name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Dark mode toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleDarkMode();
                      },
                      activeColor: const Color(0xFF0F6E56),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Export data
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Backup & Restore',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SmoothSettingsButton(
                      icon: Icons.download,
                      label: 'Export Data as JSON',
                      backgroundColor: Colors.blue,
                      onPressed: () async {
                        try {
                          await dataProvider.exportDataAsJson();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Data exported successfully to Downloads'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _SmoothSettingsButton(
                      icon: Icons.upload,
                      label: 'Import Data from JSON',
                      backgroundColor: Colors.green,
                      onPressed: () async {
                        try {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['json'],
                          );

                          if (result != null && result.files.isNotEmpty) {
                            final file = result.files.first;
                            if (file.path != null) {
                              try {
                                final importFile = File(file.path!);
                                await dataProvider.importDataFromJson(importFile);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Data imported successfully'),
                                    ),
                                  );
                                }
                              } catch (importError) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Import error: $importError')),
                                  );
                                }
                              }
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              // App version
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ShopBook',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manage your earnings, expenses, and profits with ease.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
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
