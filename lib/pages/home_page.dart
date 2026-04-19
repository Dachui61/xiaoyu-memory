import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../services/api_service.dart';

import '../stores/memory_store.dart';
import '../widgets/memory_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchController = TextEditingController();
  final _chatController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isChatLoading = false;
  String? _searchQuery;

  // Chat messages for inline AI
  final List<_ChatMessage> _chatMessages = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(memoryStoreProvider.notifier).load());
    _chatMessages.add(_ChatMessage(
      role: 'ai',
      text: '你好！我是小宇，你的 AI 记忆助手。可以问我任何关于你记忆的问题，或者直接搜索记忆～',
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchQuery = null;
        _searchQuery = null;
      });
      return;
    }

    setState(() {
      _searchQuery = query;
      _searchQuery = query;
    });
  }

  Future<void> _sendChat() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _isChatLoading) return;
    _chatController.clear();

    setState(() {
      _chatMessages.add(_ChatMessage(role: 'user', text: text));
      _isChatLoading = true;
    });

    final aiIndex = _chatMessages.length;
    _chatMessages.add(_ChatMessage(role: 'ai', text: '思考中...'));

    try {
      final api = ApiService();
      final reply = await api.chat(text);

      setState(() {
        // Strip think tags
        final cleanReply = reply.replaceAll(RegExp(r'<think>[\s\S]*?</think>', caseSensitive: false), '').trim();
        _chatMessages[aiIndex] = _ChatMessage(role: 'ai', text: cleanReply.isEmpty ? '抱歉，我没有理解你的问题。' : cleanReply);
        _isChatLoading = false;
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _chatMessages[aiIndex] = _ChatMessage(role: 'ai', text: '抱歉，AI 服务暂时不可用。');
        _isChatLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final memoriesAsync = ref.watch(memoryStoreProvider);
    final memories = memoriesAsync.valueOrNull ?? [];

    // Filter memories if searching
    final filteredMemories = _searchQuery != null && _searchQuery!.isNotEmpty
        ? memories.where((m) =>
            m.content.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
            m.title.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
            m.summary.toLowerCase().contains(_searchQuery!.toLowerCase())).toList()
        : memories;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar with Search
            Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: AppTheme.background,
                border: Border(bottom: BorderSide(color: AppTheme.cardBg)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('小宇记忆', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                      Spacer(),
                      IconButton(icon: Icon(Icons.notifications_outlined), onPressed: () {}),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onSubmitted: _performSearch,
                    decoration: InputDecoration(
                      hintText: '搜索记忆...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary),
                      prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                      suffixIcon: _searchQuery != null
                          ? IconButton(
                              icon: Icon(Icons.clear, color: AppTheme.textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme.cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: _searchQuery != null && _searchQuery!.isNotEmpty
                  ? _buildSearchResults(filteredMemories)
                  : _buildFeed(memories),
            ),

            // Inline AI Chat
            Container(
              decoration: BoxDecoration(
                color: AppTheme.background,
                border: Border(top: BorderSide(color: AppTheme.cardBg)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Chat messages preview
                  if (_chatMessages.isNotEmpty)
                    Container(
                      constraints: BoxConstraints(maxHeight: 150),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _chatMessages.length,
                        itemBuilder: (_, i) => _buildChatBubble(_chatMessages[i]),
                      ),
                    ),
                  // Chat input
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            enabled: !_isChatLoading,
                            onSubmitted: (_) => _sendChat(),
                            decoration: InputDecoration(
                              hintText: '问小宇...',
                              hintStyle: TextStyle(color: AppTheme.textSecondary),
                              filled: true,
                              fillColor: AppTheme.cardBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: _isChatLoading ? null : _sendChat,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _isChatLoading ? AppTheme.textSecondary : AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: _isChatLoading
                                ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Icon(Icons.send, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/memory/new'),
        child: Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildFeed(List memories) {
    if (memories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
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
  }

  Widget _buildSearchResults(List memories) {
    if (memories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
            SizedBox(height: 16),
            Text('没有找到相关记忆', style: TextStyle(fontSize: 17, color: AppTheme.textSecondary)),
            SizedBox(height: 8),
            Text('试试其他关键词', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 8, bottom: 100),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final m = memories[index];
        return MemoryCard(
          memory: m,
          onTap: () => context.push('/memory/${m.id}'),
        );
      },
    );
  }

  Widget _buildChatBubble(_ChatMessage msg) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 6),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : AppTheme.cardBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(fontSize: 14, color: isUser ? Colors.white : AppTheme.textPrimary),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  final String text;
  _ChatMessage({required this.role, required this.text});
}
