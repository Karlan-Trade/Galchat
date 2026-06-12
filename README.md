# GalChat

<p align="center">
  <img src="docs/icon.png" alt="GalChat Logo" width="120" />
</p>

<p align="center">
  <strong>AI 驱动的 Galgame 风格聊天应用</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/platform-Android-green?logo=android" alt="Android" />
  <img src="https://img.shields.io/badge/license-MIT-blue" alt="License" />
</p>

---

## 简介

GalChat 是一款基于 Flutter 的 AI Galgame 风格聊天应用，支持场景描写、角色对话和分支选项的实时交互。

## 功能特性

-  **自定义角色** — 所有提示词均可手动编辑，支持AI问答快速构建人格/背景/故事大纲
-  **AI 角色扮演** — 与初雪自由聊天，AI 返回场景叙述 + 对话 + 分支选项
-  **Galgame 选项系统** — 默认每回合可选分支（A/B/C/D），也可以自然语言推进进度
-  **游戏状态追踪** — 心情、场景、时间段、剧情标记（flags）实时变化
-  **工具调用** — AI 可以主动读写剧情设计文件（世界观、NPC 阵容、剧情大纲、进度追踪），实现有记忆的故事推进。
-  **多存档支持** — 创建多个对话存档，随时切换
-  **JSON 备份** — 一键导出/导入完整游戏数据（不含 API Key）
-  **本地安全** — API Key 仅存储在系统级安全区域（Keychain/Keystore），绝不写入数据库或备份文件
-  **Material 3 设计** — 支持亮色/暗色主题自动切换
-  **多种 AI 后端** — 支持自定义AI，兼容主流格式的API:OpenAI/Anthropic


## 快速开始

可选 Release页编译完成的安装包直接安装 或 自行编译 

### 环境要求

- Flutter SDK ≥ 3.x
- Android Studio 或 VS Code + Flutter 插件
- 一台 Android 设备（或模拟器，API 26+）

### 构建安装

```bash
# 克隆仓库
git clone https://github.com/Karlan-Trade/galchat.git
cd galchat

# 安装依赖
flutter pub get

# 生成 Drift 数据库代码
dart run build_runner build --delete-conflicting-outputs

# 编译 Android APK（debug，快速测试）
flutter build apk --debug

# 编译 Android APK（release，正式发布）
flutter build apk --release
```

### 配置 AI 后端

GalChat 不自带 API Key。首次启动后：

1. 进入 **设置**
2. 填入你的 **Base URL**（如 `https://api.deepseek.com/v1`）
3. 填入你的 **API Key**
4. 点击保存
5. 选择 **Model**（如 `deepseek-v4-pro`）
6. 点击 **测试连接**并保存

推荐使用 [DeepSeek](https://deepseek.com) 获得最佳中文体验。

## 技术架构

| 层级 | 技术 | 说明 |
|------|------|------|
| 框架 | Flutter / Dart | 跨平台 UI |
| 状态管理 | Riverpod | Provider + StateNotifier |
| 本地数据库 | Drift (SQLite) | 6 张表：角色、对话、消息、选项、游戏状态、AI 设置 |
| 安全存储 | flutter_secure_storage | Android Keystore / iOS Keychain |
| 网络 | http (Dart) | SSE 流式传输 + 工具调用 |
| Markdown | flutter_markdown | 聊天气泡可选渲染 |

```
lib/
├── screens/      # Flutter 页面（对话、设置中心、API/行为/提示词子页面、角色卡等）
├── state/        # Riverpod StateNotifier（ChatNotifier / SettingsNotifier / ConversationListNotifier）
├── providers/    # AI Provider 抽象接口（OpenAI 兼容实现，SSE 流式 + 工具调用 + 思考模式）
├── services/     # 业务逻辑（游戏状态合并、剧情文件管理、备份、Token 计数）
├── database/     # Drift 表定义与查询（6 表：角色/对话/消息/选项/游戏状态/AI设置）
├── constants/    # 固化的系统指令（工具调用指令等）
└── widgets/      # 可复用组件（聊天气泡、选项按钮、输入框）
```

## 项目定位

- 🎯 **用途**：个人娱乐 / 同人创作 / 技术学习
- 📱 **首期平台**：Android（Flutter 架构预留了 iOS / Desktop / Web 支持）
- 📖 **开源协议**：MIT
- 🧪 **当前阶段**：MVP —— 核心玩法已可玩，持续迭代中

## 贡献指南

欢迎提交 Issue 和 PR！请遵循以下约定：

- 代码风格遵循 `flutter_lints` 规则（见 `analysis_options.yaml`）
- 修改数据库表结构后请重新运行 `build_runner`
- API Key 绝不应出现在代码、数据库或备份文件中

详见 [CONTRIBUTING.md](./CONTRIBUTING.md)

## 许可证

本项目采用 [MIT 许可证](./LICENSE)。

---

<p align="center">
  Made with ❤️ by Karlan-Trade · Powered by 初雪 & AI
</p>

<p align="center">
  <sub>本项目完全由 AI Agent 完成 · DeepSeek V4 Pro 70% · Claude Opus 4.8 20% · ChatGPT 5.5 10% </sub>
</p>
