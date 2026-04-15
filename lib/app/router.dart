import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/memory_detail_page.dart';
import '../pages/new_memory_page.dart';
import '../pages/ai_chat_page.dart';
import '../pages/search_page.dart';
import '../pages/settings_page.dart';
import '../pages/login_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => HomePage()),
        GoRoute(path: '/chat', builder: (_, __) => AiChatPage()),
        GoRoute(path: '/search', builder: (_, __) => SearchPage()),
        GoRoute(path: '/settings', builder: (_, __) => SettingsPage()),
      ],
    ),
    GoRoute(path: '/login', builder: (_, __) => LoginPage()),
    GoRoute(path: '/memory/new', builder: (_, __) => NewMemoryPage()),
    GoRoute(path: '/memory/:id', builder: (_, state) => MemoryDetailPage(id: state.pathParameters['id']!)),
  ],
);

class MainShell extends StatefulWidget {
  final Widget child;
  MainShell({required this.child});

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
            case 1: context.go('/chat'); break;
            case 2: context.go('/search'); break;
            case 3: context.go('/settings'); break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), activeIcon: Icon(Icons.smart_toy), label: 'AI对话'),
          BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: '搜索'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}
