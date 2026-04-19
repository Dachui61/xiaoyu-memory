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
  final _chatController = TextEditingController();
  bool _isChatOpen = false;
  bool _isTyping = false;
  final List<_ChatMessage> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(memoryStoreProvider.notifier).load());
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _sendChat() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _isTyping) return;
    _chatController.clear();

    setState(() {
      _chatHistory.add(_ChatMessage(role: 'user', text: text));
      _isTyping = true;
    });

    final userIndex = _chatHistory.length;
    _chatHistory.add(_ChatMessage(role: 'ai', text: '...'));

    try {
      final api = ApiService();
      final reply = await api.chat(text);

      setState(() {
        final cleanReply = reply.replaceAll(RegExp(r'<think>[\s\S]*?</think>', caseSensitive: false), '').trim();
        _chatHistory[userIndex] = _ChatMessage(role: 'ai', text: cleanReply.isEmpty ? '抱歉，我没有理解。' : cleanReply);
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _chatHistory[userIndex] = _ChatMessage(role: 'ai', text: '抱歉，AI 服务暂时不可用。');
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final memoriesAsync = ref.watch(memoryStoreProvider);
    final memories = memoriesAsync.valueOrNull ?? [];

    return Scaffold(
      body: Stack(
        children: [
          // 主内容
          memoriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('加载失败: $e')),
            data: (memories) => _buildContent(memories),
          ),

          // 浮动 AI 按钮
          Positioned(
            right: 16,
            bottom: 32,
            child: GestureDetector(
              onTap: () => setState(() => _isChatOpen = true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.cyan, Colors.purple, Colors.red],
                        ),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '问一问',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // AI 聊天模态框
          if (_isChatOpen) _buildChatModal(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/memory/new'),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildContent(List memories) {
    return CustomScrollView(
      slivers: [
        // 顶部间距（避免刘海）
        const SliverToBoxAdapter(child: SizedBox(height: 100)),

        // 欢迎信息
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '小宇记忆',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${memories.length} 条记忆碎片',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // 欢迎卡片
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                '小宇已陪你记录了 🗓️ 一起拥有更多美好记忆吧',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // 记忆标题
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '记忆',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // 记忆列表
        if (memories.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '还没有记忆',
                    style: TextStyle(fontSize: 17, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击下方 + 开始记录',
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final m = memories[index];
                  return _MemoryCard(
                    memory: m,
                    onTap: () => context.push('/memory/${m.id}'),
                  );
                },
                childCount: memories.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChatModal() {
    return GestureDetector(
      onTap: () => setState(() => _isChatOpen = false),
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: GestureDetector(
          onTap: () {}, // 阻止点击穿透
          child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  // 顶部栏
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.02),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '小宇 AI 助手',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '正在为你整理记忆碎片...',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _isChatOpen = false),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.withOpacity(0.05),
                            ),
                            child: const Icon(Icons.close, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 聊天内容
                  Expanded(
                    child: _chatHistory.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bubble_left,
                                  size: 48,
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '有什么关于你记忆的问题想问我吗？',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: controller,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _chatHistory.length,
                            itemBuilder: (_, i) => _buildChatBubble(_chatHistory[i]),
                          ),
                  ),

                  // 输入框
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            enabled: !_isTyping,
                            onSubmitted: (_) => _sendChat(),
                            decoration: InputDecoration(
                              hintText: '问问你的记忆...',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _isTyping ? null : _sendChat,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primary,
                            ),
                            child: _isTyping
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(_ChatMessage msg) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            fontSize: 14,
            color: isUser ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

// 记忆卡片 - 参考 doudo 设计
class _MemoryCard extends StatelessWidget {
  final dynamic memory;
  final VoidCallback onTap;

  const _MemoryCard({required this.memory, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.title ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    memory.summary ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.withOpacity(0.4),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _SourceBadge(source: memory.source ?? 'app'),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(memory.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (memory.imageUrl != null && memory.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  memory.imageUrl,
                  width: 96,
                  height: 128,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 96,
                    height: 128,
                    color: Colors.grey.withOpacity(0.05),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    return date.split(' ')[0];
  }
}

// 来源徽章
class _SourceBadge extends StatelessWidget {
  final String source;

  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (source.toLowerCase()) {
      case 'douyin':
        color = Colors.black;
        text = 'd';
        break;
      case 'xiaohongshu':
        color = Colors.red;
        text = 'R';
        break;
      default:
        color = Colors.black;
        text = 'W';
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
