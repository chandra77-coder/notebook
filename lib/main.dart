import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/data_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/due_screen.dart';
import 'screens/people_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_entry_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
            home: const MainScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const SummaryScreen(),
    const DueScreen(),
    const PeopleScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const AddEntryScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
          backgroundColor: const Color(0xFF0F6E56),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add Entry',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _SmoothBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

class _SmoothBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _SmoothBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_SmoothBottomNavigationBar> createState() => _SmoothBottomNavigationBarState();
}

class _SmoothBottomNavigationBarState extends State<_SmoothBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SmoothNavItem(
                icon: Icons.home,
                label: 'Home',
                isSelected: widget.currentIndex == 0,
                onTap: () => widget.onTap(0),
              ),
              _SmoothNavItem(
                icon: Icons.history,
                label: 'History',
                isSelected: widget.currentIndex == 1,
                onTap: () => widget.onTap(1),
              ),
              _SmoothNavItem(
                icon: Icons.bar_chart,
                label: 'Summary',
                isSelected: widget.currentIndex == 2,
                onTap: () => widget.onTap(2),
              ),
              _SmoothNavItem(
                icon: Icons.payment,
                label: 'Due',
                isSelected: widget.currentIndex == 3,
                onTap: () => widget.onTap(3),
              ),
              _SmoothNavItem(
                icon: Icons.people,
                label: 'People',
                isSelected: widget.currentIndex == 4,
                onTap: () => widget.onTap(4),
              ),
              _SmoothNavItem(
                icon: Icons.settings,
                label: 'Settings',
                isSelected: widget.currentIndex == 5,
                onTap: () => widget.onTap(5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmoothNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SmoothNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SmoothNavItem> createState() => _SmoothNavItemState();
}

class _SmoothNavItemState extends State<_SmoothNavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: const Color(0xFF0F6E56),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_SmoothNavItem oldWidget) {
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
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return Icon(
                  widget.icon,
                  color: _colorAnimation.value,
                  size: 24,
                );
              },
            ),
            const SizedBox(height: 4),
            AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _colorAnimation.value,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
