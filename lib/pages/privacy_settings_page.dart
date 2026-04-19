import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../app/theme.dart';
import '../services/api_service.dart';
import '../stores/auth_store.dart';
import '../stores/memory_store.dart';

class PrivacySettingsPage extends ConsumerStatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  ConsumerState<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends ConsumerState<PrivacySettingsPage> {
  bool _isExporting = false;
  bool _isDeleting = false;

  Future<void> _exportData() async {
    setState(() => _isExporting = true);

    try {
      final memories = ref.read(memoryStoreProvider).valueOrNull ?? [];
      final exportData = {
        'exported_at': DateTime.now().toIso8601String(),
        'memories': memories.map((m) => m.toJson()).toList(),
      };

      final jsonStr = const JsonEncoder.withIndent('  ').convert(exportData);
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/xiaoyu_memory_export_$timestamp.json');
      await file.writeAsString(jsonStr);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已导出到: ${file.path}'),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: AppTheme.voiceRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('注销账号'),
        content: const Text(
          '确定要注销账号吗？此操作不可恢复，所有数据将被永久删除。',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('注销', style: TextStyle(color: AppTheme.voiceRed)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final doubleConfirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('确认注销'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('请输入"注销"以确认操作：'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: '注销'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text == '注销') {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('确认', style: TextStyle(color: AppTheme.voiceRed)),
            ),
          ],
        );
      },
    );

    if (doubleConfirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final api = ApiService();
      await api.deleteAccount();
      await ref.read(authStoreProvider.notifier).logout();
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('注销失败: $e'),
            backgroundColor: AppTheme.voiceRed,
          ),
        );
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          _buildSectionHeader('数据管理'),
          _buildTile(
            icon: Icons.download_outlined,
            title: '导出数据',
            subtitle: '将所有记忆导出为 JSON 文件',
            trailing: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _isExporting ? null : _exportData,
          ),
          _buildTile(
            icon: Icons.delete_forever_outlined,
            title: '注销账号',
            titleColor: AppTheme.voiceRed,
            subtitle: '永久删除账号和所有数据',
            trailing: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _isDeleting ? null : _deleteAccount,
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '注销后，您的所有记忆数据将被永久删除，且无法恢复。',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? AppTheme.textSecondary),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: titleColor ?? AppTheme.textPrimary),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            )
          : null,
      trailing: trailing ??
          (onTap != null ? const Icon(Icons.chevron_right, color: AppTheme.textSecondary) : null),
      onTap: onTap,
    );
  }
}
