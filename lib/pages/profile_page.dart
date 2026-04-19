import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../services/api_service.dart';
import '../stores/auth_store.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    final user = ref.watch(authStoreProvider);
    if (user != null) {
      _nicknameController.text = user.nickname.isNotEmpty ? user.nickname : user.phone;
      _phoneController.text = user.phone;
    }
  }

  Future<void> _saveProfile() async {
    final nickname = _nicknameController.text.trim();
    final phone = _phoneController.text.trim();

    // Validation
    if (nickname.isEmpty) {
      setState(() => _errorMessage = '请输入昵称');
      return;
    }
    if (!_isValidPhone(phone)) {
      setState(() => _errorMessage = '请输入正确的手机号');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ApiService();
      await api.updateProfile(nickname, phone);
      ref.read(authStoreProvider.notifier).updateProfile(nickname, phone);
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存成功'), backgroundColor: AppTheme.success),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = '保存失败，请重试');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('个人资料'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: Text('编辑', style: TextStyle(color: AppTheme.primary)),
            )
          else
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('保存', style: TextStyle(color: AppTheme.primary)),
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Avatar
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.cardBg,
                  child: Icon(Icons.person, size: 50, color: AppTheme.textSecondary),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primary,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 32),

          // Error message
          if (_errorMessage != null)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.voiceRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppTheme.voiceRed, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text(_errorMessage!, style: TextStyle(color: AppTheme.voiceRed))),
                ],
              ),
            ),

          // Nickname
          _buildField(
            label: '昵称',
            controller: _nicknameController,
            hint: '请输入昵称',
            enabled: _isEditing,
            icon: Icons.person_outline,
          ),
          SizedBox(height: 16),

          // Phone
          _buildField(
            label: '手机号',
            controller: _phoneController,
            hint: '请输入手机号',
            enabled: false,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 16),

          // Email (optional)
          _buildField(
            label: '邮箱',
            controller: TextEditingController(text: user?.email ?? ''),
            hint: '请输入邮箱（选填）',
            enabled: _isEditing,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          if (_isEditing) ...[
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('保存修改', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() {
                _isEditing = false;
                _errorMessage = null;
                _loadProfile();
              }),
              child: Text('取消', style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool enabled,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType ?? TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.textSecondary),
            filled: true,
            fillColor: enabled ? Colors.white : AppTheme.cardBg,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primary),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
