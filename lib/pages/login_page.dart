import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../stores/auth_store.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _phoneError;
  String? _passwordError;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    // Reset errors
    setState(() {
      _phoneError = null;
      _passwordError = null;
    });

    // Validation
    bool hasError = false;
    if (phone.isEmpty) {
      setState(() => _phoneError = '请输入手机号');
      hasError = true;
    } else if (!_isValidPhone(phone)) {
      setState(() => _phoneError = '请输入正确的手机号');
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = '请输入密码');
      hasError = true;
    } else if (password.length < 6) {
      setState(() => _passwordError = '密码至少6位');
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isLoading = true);
    try {
      final authStore = ref.read(authStoreProvider.notifier);
      bool success;
      if (_isLogin) {
        success = await authStore.login(phone, password);
      } else {
        success = await authStore.register(phone, password);
      }
      if (success && mounted) {
        context.go('/');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isLogin ? '登录失败' : '注册失败'), backgroundColor: AppTheme.voiceRed),
        );
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60),
              // Logo / Title
              Icon(Icons.auto_awesome, size: 64, color: AppTheme.primary),
              SizedBox(height: 16),
              Text(
                '小宇记忆',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                '你的 AI 记忆助手',
                style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60),
              // Toggle
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = true),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isLogin ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _isLogin ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
                          ),
                          child: Text('登录', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary), textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = false),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isLogin ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: !_isLogin ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
                          ),
                          child: Text('注册', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary), textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              // Phone
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '手机号',
                  prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.textSecondary),
                  errorText: _phoneError,
                ),
              ),
              SizedBox(height: 16),
              // Password
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '密码',
                  prefixIcon: Icon(Icons.lock_outlined, color: AppTheme.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  errorText: _passwordError,
                ),
              ),
              SizedBox(height: 32),
              // Submit
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isLogin ? '登录' : '注册', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ),
              SizedBox(height: 24),
              // Skip
              TextButton(
                onPressed: () => context.go('/'),
                child: Text('先看看', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
