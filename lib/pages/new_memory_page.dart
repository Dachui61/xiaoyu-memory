import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../widgets/voice_record_button.dart';

class NewMemoryPage extends StatefulWidget {
  const NewMemoryPage({super.key});

  @override
  State<NewMemoryPage> createState() => _NewMemoryPageState();
}

class _NewMemoryPageState extends State<NewMemoryPage> {
  int _selectedMode = 0; // 0=voice, 1=text, 2=camera
  final _textController = TextEditingController();
  bool _showVoice = true;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新建记忆'),
        leading: IconButton(icon: Icon(Icons.close), onPressed: () => context.pop()),
        actions: [
          TextButton(
            onPressed: () => _save(),
            child: Text('保存', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode selector
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                _modeChip(0, Icons.mic, '语音'),
                SizedBox(width: 12),
                _modeChip(1, Icons.edit, '文字'),
                SizedBox(width: 12),
                _modeChip(2, Icons.camera_alt, '拍照'),
              ],
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: _selectedMode == 0
                ? _buildVoiceView()
                : _selectedMode == 1
                    ? _buildTextView()
                    : _buildCameraView(),
          ),
        ],
      ),
    );
  }

  Widget _modeChip(int mode, IconData icon, String label) {
    final selected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? Colors.white : AppTheme.textSecondary),
            SizedBox(width: 6),
            Text(label, style: TextStyle(color: selected ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          VoiceRecordButton(
            onRecorded: (path) => _saveVoice(path),
          ),
        ],
      ),
    );
  }

  Widget _buildTextView() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(fontSize: 16, color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: '写下此刻的想法...',
          hintStyle: TextStyle(color: AppTheme.textSecondary),
          border: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
          SizedBox(height: 16),
          Text('拍照功能', style: TextStyle(fontSize: 17, color: AppTheme.textSecondary)),
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.camera_alt),
            label: Text('选择图片'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _saveVoice(String path) {
    _save();
  }

  void _save() {
    // TODO: save memory
    context.pop();
  }
}
