# Ralph Loop - 小宇记忆功能完善

## 目标
完善小宇记忆 APP 的未完成功能，依据 SPEC.md 的优先级排序。

## 当前进度
- P0: F1(语音✅) F2(文字✅) F4(AI总结✅) F5(时间线✅) F8(三端同步⚠️ 部分)
- P1: F3(拍照✅) F6(AI对话⚠️ UI完成，API未对接) F7(搜索⚠️ 假数据)
- P2: F9(设置⚠️ UI框架，逻辑未实现)

## 待完成任务
1. **F6 AI对话** - `lib/pages/ai_chat_page.dart` 的 `_send()` 方法调用了 `ApiService.chat()` 但 API 未对接
2. **F7 搜索** - `lib/pages/search_page.dart` 使用硬编码假数据，需要对接真实 API
3. **F8 三端同步** - 后端同步逻辑需要完善（增量同步、冲突处理）
4. **F9 设置页面** - `lib/pages/settings_page.dart` 的 `退出登录` 等功能需要实现
5. **个人资料页面** - 需要新增个人资料编辑页
6. **登录注册流程** - 完整的登录注册 UI 和错误处理

## 规则
1. 每次只实现一个功能模块
2. 实现后运行 `flutter analyze` 确保无错误
3. 提交信息要清晰
4. 遇到问题先分析再动手

## 完成后
输出: <promise>COMPLETE</promise>
