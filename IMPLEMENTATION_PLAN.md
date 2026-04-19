# Implementation Plan - 小宇记忆功能完善

## 已完成
- [x] **T1: AI对话 API 对接** - ai_chat_page.dart _send() 方法已对接
- [x] **T2: 搜索 API 对接** - search_page.dart 使用 ApiService.search() 替代硬编码数据
- [x] **T3: 退出登录** - settings_page.dart _logout() + AuthStore.logout()
- [x] **T4: 个人资料页面** - 新建 profile_page.dart，支持查看/编辑用户资料
- [x] **T5: 登录注册流程完善** - 表单验证、错误处理、加载状态
- [x] **T6: 后端增量同步 API** - /api/sync + Flutter SyncService
- [x] **T7: 通知设置** - flutter_local_notifications + NotificationService
- [x] **T8: 隐私设置页面** - 数据导出 + 账号注销

## STATUS: COMPLETE ✓
