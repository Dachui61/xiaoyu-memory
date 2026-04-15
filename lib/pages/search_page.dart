import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../widgets/memory_card.dart';
import '../models/memory.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _results = <Memory>[];
  bool _searched = false;

  final _allMemories = [
    Memory(id: '1', userId: 'u1', type: 'voice', content: '今天去超市买了些水果，苹果和香蕉，还有牛奶。想着周末要打扫房间，然后约朋友去爬山。', summary: '日常购物与周末计划', title: '今日随想', tags: ['生活', '计划'], createdAt: DateTime.now().subtract(Duration(hours: 2)), updatedAt: DateTime.now()),
    Memory(id: '2', userId: 'u1', type: 'text', content: 'Flutter 真的很强大，一套代码可以跑 iOS、Android、HarmonyOS。前端用 Riverpod 做状态管理，后端用 Go 语言，性能应该没问题。', summary: '跨平台技术选型思考', title: '技术选型', tags: ['技术', 'Flutter'], createdAt: DateTime.now().subtract(Duration(days: 1)), updatedAt: DateTime.now()),
    Memory(id: '3', userId: 'u1', type: 'image', content: '这张照片是上周拍的，当时天气很好，天特别蓝。', summary: '天气晴朗的日子', title: '好天气', tags: ['生活', '记录'], createdAt: DateTime.now().subtract(Duration(days: 3)), updatedAt: DateTime.now()),
  ];

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _results.clear();
        _searched = false;
        return;
      }
      _searched = true;
      _results.clear();
      _results.addAll(_allMemories.where((m) =>
        m.content.contains(query) || m.title.contains(query) || m.tags.any((t) => t.contains(query))
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('搜索'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: _search,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: '搜索记忆、标签...',
                hintStyle: TextStyle(color: AppTheme.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(icon: Icon(Icons.clear, color: AppTheme.textSecondary), onPressed: () { _controller.clear(); _search(''); })
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _searched
                ? _results.isEmpty
                    ? Center(child: Text('没有找到相关记忆', style: TextStyle(color: AppTheme.textSecondary)))
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (_, i) => MemoryCard(memory: _results[i], onTap: () => context.push('/memory/${_results[i].id}')),
                      )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 56, color: AppTheme.textSecondary.withOpacity(0.4)),
                        SizedBox(height: 12),
                        Text('输入关键词搜索记忆', style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
