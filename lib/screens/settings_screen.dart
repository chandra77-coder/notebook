import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
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

  Future<void> _uploadPaymentQr(ThemeProvider themeProvider) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;

    final selectedPath = result.files.first.path;
    if (selectedPath == null) return;

    final selectedFile = File(selectedPath);
    final appDir = await getApplicationDocumentsDirectory();
    final extension = p.extension(selectedPath).isEmpty ? '.png' : p.extension(selectedPath);
    final savedFile = File(p.join(appDir.path, 'shopbook_payment_qr$extension'));

    if (await savedFile.exists()) {
      await savedFile.delete();
    }

    await selectedFile.copy(savedFile.path);
    await themeProvider.setQrImagePath(savedFile.path);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment QR saved successfully')),
    );
  }

  Future<void> _removePaymentQr(ThemeProvider themeProvider) async {
    final path = themeProvider.qrImagePath;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await themeProvider.removeQrImagePath();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment QR removed')),
    );
  }

  void _showPaymentQr(BuildContext context, ThemeProvider themeProvider) {
    final qrPath = themeProvider.qrImagePath;
    if (qrPath == null || !File(qrPath).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload your payment QR first')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${themeProvider.shopName} Payment QR'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(qrPath),
                  width: 260,
                  height: 260,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Show this QR to customer for online payment.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DataProvider, ThemeProvider>(
      builder: (context, dataProvider, themeProvider, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shop Name',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _shopNameController,
                      onChanged: themeProvider.setShopName,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dark Mode',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleDarkMode(),
                      activeColor: const Color(0xFF0F6E56),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment QR',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      themeProvider.qrImagePath == null
                          ? 'Upload your UPI/payment QR. A QR button will appear on Home, History, Summary, Due, People, and Settings.'
                          : 'QR uploaded. The QR shortcut is active on all main screens.',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    if (themeProvider.qrImagePath != null &&
                        File(themeProvider.qrImagePath!).existsSync()) ...[
                      Center(
                        child: InkWell(
                          onTap: () => _showPaymentQr(context, themeProvider),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFDDE7E2)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.file(
                              File(themeProvider.qrImagePath!),
                              width: 150,
                              height: 150,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _SmoothSettingsButton(
                      icon: Icons.qr_code_2,
                      label: themeProvider.qrImagePath == null ? 'Upload QR Code' : 'Change QR Code',
                      backgroundColor: const Color(0xFF0F6E56),
                      onPressed: () => _uploadPaymentQr(themeProvider),
                    ),
                    if (themeProvider.qrImagePath != null) ...[
                      const SizedBox(height: 8),
                      _SmoothSettingsButton(
                        icon: Icons.delete_outline,
                        label: 'Remove QR Code',
                        backgroundColor: Colors.red,
                        onPressed: () => _removePaymentQr(themeProvider),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Backup & Restore',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _SmoothSettingsButton(
                      icon: Icons.download,
                      label: 'Export Data as JSON',
                      backgroundColor: Colors.blue,
                      onPressed: () async {
                        await dataProvider.exportDataAsJson();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data exported successfully to Downloads')),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _SmoothSettingsButton(
                      icon: Icons.upload,
                      label: 'Import Data from JSON',
                      backgroundColor: Colors.green,
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['json'],
                        );
                        if (result == null || result.files.isEmpty) return;

                        final filePath = result.files.first.path;
                        if (filePath == null) return;

                        await dataProvider.importDataFromJson(File(filePath));
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data imported successfully')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border.all(color: const Color(0xFFDDE7E2)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ShopBook',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text('Version 1.0.0', style: TextStyle(fontSize: 12)),
                          SizedBox(height: 4),
                          Text(
                            'Manage your earnings, expenses, due payments, QR payments, and profits offline.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 96),
            ],
          ),
        );
      },
    );
  }
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

  Future<void> _run() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await widget.onPressed();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _run();
      },
      onTapCancel: () => setState(() => _isPressed = false),
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
              ? const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
