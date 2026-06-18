import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/data_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/add_entry_screen.dart';
import 'screens/due_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/people_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/summary_screen.dart';
import 'widgets/qr_shortcut.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (_) => DataProvider()..loadData()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'ShopBook',
            theme: themeProvider.getTheme(),
            debugShowCheckedModeBanner: false,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    SummaryScreen(),
    DueScreen(),
    PeopleScreen(),
    SettingsScreen(),
  ];

  void _openAddEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEntryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const QrShortcutButton(),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'add_entry_fab',
            onPressed: _openAddEntry,
            backgroundColor: const Color(0xFF0F6E56),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Entry',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 66,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home, label: 'Home', selected: _index == 0, onTap: () => setState(() => _index = 0)),
              _NavItem(icon: Icons.history, label: 'History', selected: _index == 1, onTap: () => setState(() => _index = 1)),
              _NavItem(icon: Icons.bar_chart, label: 'Summary', selected: _index == 2, onTap: () => setState(() => _index = 2)),
              _NavItem(icon: Icons.payment, label: 'Due', selected: _index == 3, onTap: () => setState(() => _index = 3)),
              _NavItem(icon: Icons.people, label: 'People', selected: _index == 4, onTap: () => setState(() => _index = 4)),
              _NavItem(icon: Icons.settings, label: 'Settings', selected: _index == 5, onTap: () => setState(() => _index = 5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF0F6E56) : Colors.grey;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: selected ? 5 : 0,
              height: selected ? 5 : 0,
              decoration: const BoxDecoration(color: Color(0xFF0F6E56), shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }
}
