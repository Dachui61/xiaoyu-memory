import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
import '../services/api_service.dart';
import '../stores/auth_store.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_Msg>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(const _Msg(
      role: 'ai',
      text: '你好！我是小宇，你的 AI 记忆助手。有什么想聊的，或者想让我帮你整理的记忆吗？',
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;
    _controller.clear();

    setState(() => _messages.add(_Msg(role: 'user', text: text)));
    setState(() => _isLoading = true);

    final aiIndex = _messages.length;
    setState(() => _messages.add(const _Msg(role: 'ai', text: '')));

    try {
      final api = ApiService();
      final reply = await api.chat(text);

      if (mounted) {
        setState(() {
          _messages[aiIndex] = _Msg(role: 'ai', text: reply);
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages[aiIndex] = _Msg(
            role: 'ai',
            text: '抱歉，AI 服务暂时不可用。请稍后重试。',
          );
        });
        _scrollToBottom();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStoreProvider);
    final isLoggedIn = authState != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 对话'),
        centerTitle: true,
        actions: [
          if (!isLoggedIn)
            TextButton(
              onPressed: () => _showLoginHint(context),
              child: const Text('登录', style: TextStyle(color: AppTheme.primary)),
            ),
        ],
      ),
      body: Column(
        children: [
          if (!isLoggedIn)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppTheme.primary.withValues(alpha: 0.1),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '登录后可享受完整 AI 对话功能',
                      style: TextStyle(fontSize: 13, color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildBubble(_messages[i]),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: Border(top: BorderSide(color: AppTheme.cardBg)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isLoading,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: _isLoading ? 'AI 思考中...' : '输入消息...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isLoading ? null : _send,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isLoading ? AppTheme.textSecondary : AppTheme.primary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('请先登录后再使用 AI 对话功能'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildBubble(_Msg msg) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : AppTheme.cardBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Text(
          msg.text.isEmpty ? '思考中...' : msg.text,
          style: TextStyle(
            fontSize: 16,
            color: isUser ? Colors.white : AppTheme.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _Msg {
  final String role; // 'user' or 'ai'
  final String text;
  const _Msg({required this.role, required this.text});
}
