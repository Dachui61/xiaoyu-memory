import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';
import '../models/memory.dart';

class MemoryDetailPage extends ConsumerWidget {
  final String id;
  const MemoryDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For demo, show detail from sample data
    final memory = _getMemory(id);
    if (memory == null) {
      return Scaffold(appBar: AppBar(title: Text('记忆详情')), body: Center(child: Text('未找到')));
    }

    final dateStr = DateFormat('yyyy年MM月dd日 HH:mm').format(memory.createdAt);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          IconButton(icon: Icon(Icons.edit_outlined), onPressed: () {}),
          IconButton(icon: Icon(Icons.delete_outline), onPressed: () => _confirmDelete(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type + Time
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(_typeIcon(memory.type), size: 14, color: AppTheme.primary),
                      SizedBox(width: 4),
                      Text(_typeLabel(memory.type), style: TextStyle(fontSize: 13, color: AppTheme.primary)),
                    ],
                  ),
                ),
                Spacer(),
                Text(dateStr, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              ],
            ),
            SizedBox(height: 20),
            // Title
            if (memory.title.isNotEmpty) ...[
              Text(memory.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              SizedBox(height: 16),
            ],
            // Tags
            if (memory.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                children: memory.tags.map((t) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: AppTheme.aiPurple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(t, style: TextStyle(fontSize: 13, color: AppTheme.aiPurple)),
                )).toList(),
              ),
              SizedBox(height: 20),
            ],
            // Content
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12)),
              child: Text(memory.content, style: TextStyle(fontSize: 16, height: 1.6, color: AppTheme.textPrimary)),
            ),
            // AI Summary
            if (memory.summary.isNotEmpty) ...[
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.aiPurple.withValues(alpha: 0.1), AppTheme.primary.withValues(alpha: 0.05)]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.aiPurple.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: AppTheme.aiPurple),
                        SizedBox(width: 6),
                        Text('AI 总结', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.aiPurple)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(memory.summary, style: TextStyle(fontSize: 15, height: 1.5, color: AppTheme.textPrimary)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'voice': return Icons.mic;
      case 'image': return Icons.photo;
      default: return Icons.note;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'voice': return '语音';
      case 'image': return '图片';
      default: return '文字';
    }
  }

  Memory? _getMemory(String id) {
    final samples = [
      Memory(id: '1', userId: 'u1', type: 'voice', content: '今天去超市买了些水果，苹果和香蕉，还有牛奶。想着周末要打扫房间，然后约朋友去爬山。', summary: '日常购物与周末计划', title: '今日随想', tags: ['生活', '计划'], createdAt: DateTime.now().subtract(Duration(hours: 2)), updatedAt: DateTime.now()),
      Memory(id: '2', userId: 'u1', type: 'text', content: 'Flutter 真的很强大，一套代码可以跑 iOS、Android、HarmonyOS。前端用 Riverpod 做状态管理，后端用 Go 语言，性能应该没问题。', summary: '跨平台技术选型思考', title: '技术选型', tags: ['技术', 'Flutter'], createdAt: DateTime.now().subtract(Duration(days: 1)), updatedAt: DateTime.now()),
      Memory(id: '3', userId: 'u1', type: 'image', content: '这张照片是上周拍的，当时天气很好，天特别蓝。', summary: '天气晴朗的日子', title: '好天气', tags: ['生活', '记录'], createdAt: DateTime.now().subtract(Duration(days: 3)), updatedAt: DateTime.now()),
    ];
    return samples.where((m) => m.id == id).firstOrNull;
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('删除记忆'),
        content: Text('确定要删除这条记忆吗？此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消')),
          TextButton(
            onPressed: () { Navigator.pop(ctx); context.pop(); },
            child: Text('删除', style: TextStyle(color: AppTheme.voiceRed)),
          ),
        ],
      ),
    );
  }
}
