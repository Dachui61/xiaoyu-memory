# 小宇记忆 — 产品规格说明书

## 1. 项目概述

**项目名称：** 小宇记忆（XiaoYu Memory）
**一句话描述：** 跨平台 AI 记忆助手，通过语音/文字交互，自动总结、整理用户的生活碎片与想法。
**目标平台：** iOS、Android、鸿蒙（HarmonyOS NEXT）
**技术栈：** Flutter（跨端）+ Go（后端）
**核心价值：** 把一闪而过的想法、日程、灵感、聊天记录变成结构化的记忆，AI 自动归纳总结。

---

## 2. UI/UX 规格

### 2.1 视觉风格

- **风格参考：** Apple Notes + Apple Intelligence 简洁风格
- **主色调：** 纯白/浅灰背景 + 品牌蓝（#007AFF）点缀
- **字体：** 系统原生字体（San Francisco / HarmonyOS Sans）
- **圆角卡片：** 12px 圆角，轻微阴影（blur 20, opacity 8%）
- **动效：** 轻微弹性动画（spring curve），切换 250ms，弹入 300ms
- **图标：** SF Symbols / HarmonyOS Icons，线性风格，24px

### 2.2 页面结构

```
App
├── 启动页 (Splash)          — 品牌 Logo 渐入
├── 首页 (Home)              — 今日记忆流 + 快捷入口
│   ├── 记忆流 (Memory Feed)  — 时间线展示记忆卡片
│   ├── 快捷入口              — 新建语音 / 新建文字 / 拍照
│   └── 底部 Tab Bar
├── 记忆详情 (Memory Detail) — 单条记忆 + AI 总结
├── 新建记忆 (New Memory)    — 语音录制 / 文字输入 / 拍照
├── AI 对话 (AI Chat)        — 与 AI 对话交互
├── 搜索 (Search)            — 全局搜索记忆
└── 设置 (Settings)           — 账号、同步、偏好设置
```

**底部 Tab Bar（4个）：** 首页 | AI 对话 | 搜索 | 设置

### 2.3 颜色定义

| 用途        | 颜色     | Hex       |
|-------------|----------|-----------|
| 背景        | 纯白      | `#FFFFFF` |
| 卡片背景    | 浅灰      | `#F5F5F7` |
| 主品牌色    | Apple蓝  | `#007AFF` |
| 文字主色    | 深灰黑    | `#1D1D1F` |
| 文字次级    | 中灰      | `#86868B` |
| 成功        | 绿色      | `#34C759` |
| 警告        | 橙色      | `#FF9500` |
| 语音录制    | 红色      | `#FF3B30` |
| AI 强调     | 紫色      | `#AF52DE` |

### 2.4 组件规范

**记忆卡片：**
- 白色背景，12px 圆角，轻阴影
- 顶部：时间标签（灰色小字）
- 主体：内容预览（最多3行）
- 底部：AI 总结标签（#AF52DE小标签）+ 操作按钮

**语音录制按钮：**
- 圆形，红色（#FF3B30），60px 直径
- 按住说话，松开停止
- 录音中：脉冲动画 + 时长显示

**新建记忆 FAB：**
- 品牌蓝（#007AFF），圆形 + "+" 图标
- 点击展开三个选项：语音 / 文字 / 拍照

**AI 对话气泡：**
- 用户：右对齐，品牌蓝背景，白色文字
- AI：左对齐，浅灰背景，深灰文字，圆角气泡

---

## 3. 功能规格

### 3.1 核心功能

#### F1: 语音输入记忆
- 长按录制按钮说话，松开自动结束
- 语音实时转文字（ASR）并显示
- 结束后自动调用 AI 总结，生成标题 + 关键词标签
- 支持打断取消录制

#### F2: 文字输入记忆
- 文字输入框，支持多行
- 输入时实时字符计数
- 发布后触发 AI 总结流程

#### F3: 拍照/图片记忆
- 拍照或从相册选择图片
- 图片 + 可选文字描述
- AI 自动识别图片内容并生成记忆描述

#### F4: AI 总结与标签
- 每条记忆自动生成：标题（8字内）+ 3个关键词标签
- 支持 AI 续写/润色内容
- AI 可追问："你想补充什么吗？"

#### F5: 记忆时间线（首页）
- 按时间倒序展示所有记忆卡片
- 支持按日期/标签筛选
- 下拉刷新，上拉加载更多

#### F6: AI 对话（Chat）
- 与 AI 进行自然语言对话
- AI 可访问用户记忆库回答问题
- 支持多轮对话，记忆上下文

#### F7: 全局搜索
- 搜索记忆内容、标题、标签
- 支持语音搜索
- 搜索结果高亮关键词

#### F8: 三端数据同步
- 用户注册/登录（手机号 or 邮箱）
- 所有记忆实时同步到云端（Go 后端）
- 冲突解决：服务端为主，本地为缓存

#### F9: 账号与设置
- 个人资料编辑
- 通知偏好
- 存储使用情况
- 隐私政策 & 退出登录

### 3.2 优先级排序

**P0（首版必须）：**
F1（语音）、F2（文字）、F4（AI总结）、F5（时间线）、F8（三端同步）

**P1（第二版）：**
F3（拍照）、F6（AI对话）、F7（搜索）

**P2（迭代）：**
F9（设置）、通知推送、更多AI能力

---

## 4. 技术架构

### 4.1 Flutter 端

```
lib/
├── main.dart
├── app/                    # App 入口、路由、主题
├── pages/                  # 页面
│   ├── home/
│   ├── memory_detail/
│   ├── new_memory/
│   ├── ai_chat/
│   ├── search/
│   └── settings/
├── widgets/                # 通用组件
│   ├── memory_card.dart
│   ├── voice_record_button.dart
│   ├── ai_bubble.dart
│   └── ...
├── services/               # 业务服务
│   ├── api_service.dart     # 后端 API 调用
│   ├── speech_service.dart   # 语音转文字
│   ├── auth_service.dart     # 认证
│   └── sync_service.dart     # 同步服务
├── models/                  # 数据模型
├── stores/                  # 状态管理（Riverpod/Provider）
└── utils/                    # 工具函数
```

**关键依赖：**
- 状态管理：`flutter_riverpod`
- 路由：`go_router`
- 本地存储：`shared_preferences` / `hive`
- 网络：`dio`
- 语音录制：`record`
- 图片选择：`image_picker`
- 跨端能力：部分用 Platform Channel

### 4.2 Go 后端

```
backend/
├── main.go
├── internal/
│   ├── handler/            # HTTP Handler
│   │   ├── memory.go
│   │   ├── auth.go
│   │   └── ai.go
│   ├── service/            # 业务逻辑
│   │   ├── memory_service.go
│   │   ├── ai_service.go
│   │   └── sync_service.go
│   ├── model/              # 数据模型
│   ├── repository/         # 数据访问
│   └── middleware/         # 中间件
├── pkg/
│   ├── ai/                 # AI 接入（MiniMax/Claude）
│   └── storage/            # 文件存储
└── go.mod
```

**API 设计（REST）：**

| 方法 | 路径              | 描述              |
|------|-------------------|------------------|
| POST | /api/auth/register | 注册             |
| POST | /api/auth/login    | 登录             |
| GET  | /api/memories      | 获取记忆列表     |
| POST | /api/memories       | 创建记忆         |
| GET  | /api/memories/:id  | 获取单条记忆     |
| PUT  | /api/memories/:id  | 更新记忆         |
| DELETE| /api/memories/:id | 删除记忆         |
| POST | /api/memories/:id/summarize | AI总结 |
| POST | /api/chat          | AI 对话          |
| GET  | /api/search        | 搜索记忆         |
| POST | /api/sync          | 同步（增量）     |

### 4.3 数据模型

**Memory（记忆）：**
```go
type Memory struct {
    ID          string    `json:"id"`           // UUID
    UserID      string    `json:"user_id"`
    Type        string    `json:"type"`         // "voice" | "text" | "image"
    Content     string    `json:"content"`      // 原始内容/文字
    Summary     string    `json:"summary"`      // AI 总结
    Title       string    `json:"title"`        // AI 生成标题
    Tags        []string  `json:"tags"`         // AI 生成标签
    MediaURL    string    `json:"media_url"`    // 语音/图片 URL
    CreatedAt   time.Time `json:"created_at"`
    UpdatedAt   time.Time `json:"updated_at"`
}
```

**User：**
```go
type User struct {
    ID        string    `json:"id"`
    Phone     string    `json:"phone"`
    Email     string    `json:"email"`
    Password  string    `json:"-"`              // BCrypt 哈希
    CreatedAt time.Time `json:"created_at"`
}
```

### 4.4 存储方案

- **数据库：** PostgreSQL（用户、记忆元数据）
- **文件存储：** 语音/图片存 OSS（阿里云/腾讯云）或 S3 兼容存储
- **缓存：** Redis（会话、限流）
- **AI：** MiniMax API（语音识别 + AI 总结 + 对话）

---

## 5. 项目里程碑

| 阶段 | 内容                      | 交付物            |
|------|---------------------------|------------------|
| M1   | 项目初始化 + 规格说明书确认  | SPEC.md          |
| M2   | Flutter 项目骨架 + Go 后端骨架 | 可运行空项目     |
| M3   | 用户认证（注册/登录）+ 三端同步 | 认证流程         |
| M4   | 核心记忆 CRUD + 首页时间线  | 基础记忆功能     |
| M5   | 语音录制 + ASR + AI 总结   | 语音记忆         |
| M6   | AI 对话 + 搜索功能         | AI 增强功能      |
| M7   | 拍照/图片 + 详情页优化     | 媒体记忆         |
| M8   | iOS / Android / 鸿蒙 打包  | 三端可安装包     |

---

*本规格将作为开发基准，实际迭代中可根据用户反馈调整。*
