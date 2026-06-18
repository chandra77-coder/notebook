import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _shopName = 'ShopBook';
  String? _qrImagePath;
  late SharedPreferences _prefs;

  bool get isDarkMode => _isDarkMode;
  String get shopName => _shopName;
  String? get qrImagePath => _qrImagePath;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    _shopName = _prefs.getString('shopName') ?? 'ShopBook';
    _qrImagePath = _prefs.getString('qrImagePath');
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setShopName(String name) async {
    final cleanName = name.trim().isEmpty ? 'ShopBook' : name.trim();
    _shopName = cleanName;
    await _prefs.setString('shopName', cleanName);
    notifyListeners();
  }

  Future<void> setQrImagePath(String path) async {
    _qrImagePath = path;
    await _prefs.setString('qrImagePath', path);
    notifyListeners();
  }

  Future<void> removeQrImagePath() async {
    _qrImagePath = null;
    await _prefs.remove('qrImagePath');
    notifyListeners();
  }

  ThemeData getTheme() {
    const primaryColor = Color(0xFF0F6E56);
    const surfaceColor = Color(0xFFF5F7F6);
    const darkSurfaceColor = Color(0xFF121212);

    if (_isDarkMode) {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
          primary: primaryColor,
          surface: const Color(0xFF1E1E1E),
        ),
        primaryColor: primaryColor,
        scaffoldBackgroundColor: darkSurfaceColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          elevation: 2,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      );
    } else {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
          primary: primaryColor,
          surface: Colors.white,
        ),
        primaryColor: primaryColor,
        scaffoldBackgroundColor: surfaceColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          elevation: 0,
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Color(0xFFDDE7E2)),
          ),
        ),
      );
    }
  }
}
