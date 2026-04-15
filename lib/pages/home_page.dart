import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../stores/memory_store.dart';
import '../widgets/memory_card.dart';
import '../models/memory.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(memoryStoreProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final memoriesAsync = ref.watch(memoryStoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('小宇记忆', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: memoriesAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (memories) {
          if (memories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
                  SizedBox(height: 16),
                  Text('还没有记忆', style: TextStyle(fontSize: 17, color: AppTheme.textSecondary)),
                  SizedBox(height: 8),
                  Text('点击下方 + 开始记录', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.read(memoryStoreProvider.notifier).load(),
            child: ListView.builder(
              padding: EdgeInsets.only(top: 8, bottom: 100),
              itemCount: memories.length,
              itemBuilder: (context, index) {
                final m = memories[index];
                return MemoryCard(
                  memory: m,
                  onTap: () => context.push('/memory/${m.id}'),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/memory/new'),
        child: Icon(Icons.add, size: 28),
      ),
    );
  }
}
