import 'package:flutter/material.dart';
import '../app/theme.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_Msg>[];

  @override
  void initState() {
    super.initState();
    _messages.add(_Msg(
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

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() => _messages.add(_Msg(role: 'user', text: text)));

    // Mock AI response
    await Future.delayed(Duration(milliseconds: 800));
    String reply;
    if (text.contains('记得') || text.contains('记忆')) {
      reply = '我已经记住了！你可以随时问我关于你记忆中的内容。';
    } else if (text.contains('你好') || text.contains('hi') || text.contains('hello')) {
      reply = '你好呀！今天过得怎么样？有什么想记录的吗？ 😊';
    } else {
      reply = '明白了，我会帮你记住这件事。有什么需要补充的吗？';
    }
    setState(() => _messages.add(_Msg(role: 'ai', text: reply)));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI 对话'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildBubble(_messages[i]),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 34),
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: Border(top: BorderSide(color: AppTheme.cardBg)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: '输入消息...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(22)),
                    child: Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(_Msg msg) {
    final isUser = msg.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : AppTheme.cardBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Text(msg.text, style: TextStyle(fontSize: 16, color: isUser ? Colors.white : AppTheme.textPrimary, height: 1.4)),
      ),
    );
  }
}

class _Msg {
  final String role; // 'user' or 'ai'
  final String text;
  _Msg({required this.role, required this.text});
}
