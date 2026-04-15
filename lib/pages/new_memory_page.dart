import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../app/theme.dart';
import '../services/api_service.dart';
import '../stores/memory_store.dart';
import '../widgets/voice_record_button.dart';

class NewMemoryPage extends ConsumerStatefulWidget {
  const NewMemoryPage({super.key});

  @override
  ConsumerState<NewMemoryPage> createState() => _NewMemoryPageState();
}

class _NewMemoryPageState extends ConsumerState<NewMemoryPage> {
  int _selectedMode = 0; // 0=voice, 1=text, 2=camera
  final _textController = TextEditingController();
  final _captionController = TextEditingController();
  bool _isLoading = false;
  String? _recordedPath;
  XFile? _selectedImage;

  @override
  void dispose() {
    _textController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新建记忆'),
        leading: IconButton(icon: Icon(Icons.close), onPressed: () => context.pop()),
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
              ),
            )
          else
            TextButton(
              onPressed: _save,
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
            onRecorded: (path) => _onVoiceRecorded(path),
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          if (_selectedImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_selectedImage!.path),
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _captionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '为这张照片写个描述...',
                filled: true,
                fillColor: AppTheme.cardBg,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _selectedImage = null),
                    icon: Icon(Icons.delete_outline, color: AppTheme.voiceRed),
                    label: Text('删除', style: TextStyle(color: AppTheme.voiceRed)),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _cameraButton(Icons.camera_alt, '拍照', ImageSource.camera),
                SizedBox(width: 20),
                _cameraButton(Icons.photo_library, '相册', ImageSource.gallery),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _cameraButton(IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () => _pickImage(source),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppTheme.primary),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 15, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e'), backgroundColor: AppTheme.voiceRed),
        );
      }
    }
  }

  void _onVoiceRecorded(String path) {
    setState(() => _recordedPath = path);
    _saveVoice(path);
  }

  Future<void> _saveVoice(String path) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final api = ApiService();

      // 1. Upload audio and get transcribed text
      String text = '';
      try {
        text = await api.transcribeAudio(path);
      } catch (_) {
        // Fallback if ASR fails
        text = '（语音转文字失败，请手动编辑）';
      }

      // 2. Create memory with transcribed text
      final memory = await api.createVoiceMemory(path);
      if (text.isNotEmpty) {
        // Update content with transcribed text
        await api.updateMemory(memory.id, {'content': text});
      }

      // 3. Add to store and trigger AI summarization
      await ref.read(memoryStoreProvider.notifier).add(memory);
      await ref.read(memoryStoreProvider.notifier).summarize(memory.id);

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: AppTheme.voiceRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final memoryType = _selectedMode == 0 ? 'voice' : (_selectedMode == 1 ? 'text' : 'image');
      String content = '';
      String? mediaUrl;

      if (_selectedMode == 0) {
        content = '语音记录';
        mediaUrl = _recordedPath;
      } else if (_selectedMode == 1) {
        content = _textController.text.trim();
        if (content.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('请输入内容'), backgroundColor: AppTheme.warning),
          );
          setState(() => _isLoading = false);
          return;
        }
      } else {
        if (_selectedImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('请选择图片'), backgroundColor: AppTheme.warning),
          );
          setState(() => _isLoading = false);
          return;
        }
        content = _captionController.text.trim().isNotEmpty ? _captionController.text.trim() : '图片记录';
        mediaUrl = _selectedImage!.path;
      }

      final memory = await api.createMemory({
        'type': memoryType,
        'content': content,
        'media_url': mediaUrl,
      });
      await ref.read(memoryStoreProvider.notifier).add(memory);
      await ref.read(memoryStoreProvider.notifier).summarize(memory.id);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: AppTheme.voiceRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
