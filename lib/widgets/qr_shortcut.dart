import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class QrShortcutButton extends StatelessWidget {
  const QrShortcutButton({super.key});

  void _openQr(BuildContext context, ThemeProvider themeProvider) {
    final qrPath = themeProvider.qrImagePath;
    if (qrPath == null || !File(qrPath).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload your QR from Settings first')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${themeProvider.shopName} QR'),
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
                'Show this QR when needed.',
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final qrPath = themeProvider.qrImagePath;
        final hasQr = qrPath != null && File(qrPath).existsSync();
        if (!hasQr) return const SizedBox.shrink();

        return FloatingActionButton.small(
          heroTag: 'qr_shortcut_fab',
          onPressed: () => _openQr(context, themeProvider),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F6E56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF0F6E56)),
          ),
          child: const Icon(Icons.qr_code_2),
        );
      },
    );
  }
}
