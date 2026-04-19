import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../widgets/memory_card.dart';
import '../models/memory.dart';
import '../services/api_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _results = <Memory>[];
  bool _searched = false;
  bool _loading = false;

  Future<void> _search(String query) async {
    setState(() {
      if (query.isEmpty) {
        _results.clear();
        _searched = false;
        return;
      }
      _searched = true;
      _loading = true;
    });

    try {
      final api = ApiService();
      final memories = await api.search(query);
      if (mounted) {
        setState(() {
          _results.clear();
          _results.addAll(memories);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _results.clear();
          _loading = false;
        });
      }
    }
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
              onChanged: (v) => _search(v),
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _searched
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
                            Icon(Icons.search, size: 56, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
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
