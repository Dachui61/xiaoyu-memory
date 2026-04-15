import 'package:flutter/material.dart';
import '../app/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: ListView(
        children: [
          SizedBox(height: 12),
          // Profile section
          _buildSectionHeader('账号'),
          _buildTile(icon: Icons.person_outline, title: '个人资料', onTap: () {}),
          _buildTile(icon: Icons.lock_outline, title: '修改密码', onTap: () {}),
          _buildTile(icon: Icons.security, title: '隐私设置', onTap: () {}),

          _buildSectionHeader('同步'),
          _buildTile(icon: Icons.sync, title: '同步状态', subtitle: '已同步', trailing: Icon(Icons.check_circle, color: AppTheme.success, size: 20)),
          _buildTile(icon: Icons.cloud_upload_outlined, title: '云存储使用', subtitle: '2.3 GB / 5 GB', onTap: () {}),

          _buildSectionHeader('通知'),
          _buildTile(icon: Icons.notifications_outlined, title: '推送通知', trailing: Switch(value: true, onChanged: (_) {}, activeColor: AppTheme.primary)),
          _buildTile(icon: Icons.schedule, title: '提醒时间', subtitle: '每天 09:00', onTap: () {}),

          _buildSectionHeader('其他'),
          _buildTile(icon: Icons.auto_awesome, title: '小宇记忆 Pro', subtitle: '解锁全部功能', onTap: () {}),
          _buildTile(icon: Icons.help_outline, title: '帮助与反馈', onTap: () {}),
          _buildTile(icon: Icons.info_outline, title: '关于', subtitle: '版本 1.0.0', onTap: () {}),
          _buildTile(icon: Icons.logout, title: '退出登录', titleColor: AppTheme.voiceRed, onTap: () => _logout(context)),

          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
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
      title: Text(title, style: TextStyle(fontSize: 16, color: titleColor ?? AppTheme.textPrimary)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)) : null,
      trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right, color: AppTheme.textSecondary) : null),
      onTap: onTap,
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('退出登录'),
        content: Text('确定要退出当前账号吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消')),
          TextButton(onPressed: () { Navigator.pop(ctx); }, child: Text('退出', style: TextStyle(color: AppTheme.voiceRed))),
        ],
      ),
    );
  }
}
