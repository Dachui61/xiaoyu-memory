import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/memory_detail_page.dart';
import '../pages/new_memory_page.dart';
import '../pages/settings_page.dart';
import '../pages/login_page.dart';
import '../pages/profile_page.dart';
import '../pages/privacy_settings_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => HomePage()),
        GoRoute(path: '/settings', builder: (_, __) => SettingsPage()),
      ],
    ),
    GoRoute(path: '/login', builder: (_, __) => LoginPage()),
    GoRoute(path: '/memory/new', builder: (_, __) => NewMemoryPage()),
    GoRoute(path: '/memory/:id', builder: (_, state) => MemoryDetailPage(id: state.pathParameters['id']!)),
    GoRoute(path: '/profile', builder: (_, __) => ProfilePage()),
    GoRoute(path: '/privacy', builder: (_, __) => PrivacySettingsPage()),
  ],
);

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          switch (i) {
            case 0: context.go('/'); break;
            case 1: context.go('/settings'); break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), activeIcon: Icon(Icons.auto_awesome), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}
