# GalChat

<p align="center">
  <img src="docs/galchat-icon.png" alt="GalChat Logo" width="120" />
</p>

<p align="center">
  <strong>AI 驱动的 Galgame 风格聊天应用 · 与初雪一起写故事</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/platform-Android-green?logo=android" alt="Android" />
  <img src="https://img.shields.io/badge/license-MIT-blue" alt="License" />
</p>

---

## 简介

GalChat 是一款基于 Flutter 的 AI Galgame 风格聊天应用。你可以与初雪进行角色扮演式对话，让 AI 按照场景叙述、角色对白、分支选项和状态变化来推进一段持续发展的校园日常故事。

应用重点放在“可玩”和“可调”：角色设定、剧情文件、示例对话、回复风格和 API 后端都可以在本地配置；API Key 仅保存在系统安全存储中，不进入数据库或备份。

## 功能特性

- **Galgame 对话体验** — AI 返回场景叙述、角色对白、A/B/C/D 分支选项和状态变化
- **初雪角色系统** — 内置默认角色，可编辑人格提示词、故事开场、示例对话和回复风格
- **剧情文件工具调用** — AI 可读写世界观、NPC、剧情大纲、进度追踪等本地叙事文件
- **行为开关** — 支持示例对话、AI 主动开场、思考模式、工具调用等开关
- **多后端兼容** — 支持 OpenAI 兼容协议与 Anthropic Messages API
- **流式输出与思考过程** — 支持 SSE 流式文本、DeepSeek reasoning 内容展示和停止生成
- **游戏状态追踪** — 心情、场景、时间段、好感度、剧情 flags 由应用本地校验合并
- **多会话存档** — 创建、切换、归档多个对话存档
- **备份与恢复** — JSON 导出/导入完整游戏数据，备份不包含 API Key
- **本地安全** — API Key 仅存储在系统安全区域，数据库和备份不会保存密钥

## 快速开始

可以直接安装 Release 页面提供的 APK，也可以按下面步骤自行编译。

### 环境要求

- Flutter SDK ≥ 3.x
- Dart SDK ≥ 3.4
- Android Studio 或 VS Code + Flutter 插件
- Android 设备或模拟器（API 26+）

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

## 常用操作

- **行为设置**：在设置页进入“行为设置”，可控制 AI 是否主动开场、是否显示思考过程、是否允许工具调用。
- **提示词设置**：在设置页进入“提示词设置”，可编辑角色卡、剧情设定文件、开场提示和回复风格。
- **备份恢复**：在设置页导出或导入 JSON 备份；备份包含角色、会话、消息、选项、游戏状态和 AI 设置，但不包含 API Key。
- **异常兜底**：当 API 返回为空、网络中断、模型长时间只思考不输出正文时，应用会显示本地兜底提示，避免把本地占位误认为 AI 正式回复。

## 技术架构

| 层级 | 技术 | 说明 |
|------|------|------|
| 框架 | Flutter / Dart | 跨平台 UI |
| 状态管理 | Riverpod | Provider + StateNotifier / ChangeNotifier |
| 本地数据库 | Drift (SQLite) | 6 张表：角色、对话、消息、选项、游戏状态、AI 设置 |
| 安全存储 | flutter_secure_storage | Android Keystore / iOS Keychain |
| 网络 | http (Dart) | SSE 流式传输、工具调用、连接测试 |
| Markdown | flutter_markdown | 聊天气泡可选渲染 |

```
lib/
├── screens/      # Flutter 页面（聊天、会话列表、设置中心、API/行为/提示词子页面等）
├── state/        # 应用状态（ChatNotifier / SettingsNotifier / ConversationListNotifier）
├── providers/    # AI Provider 抽象与 OpenAI 兼容 / Anthropic 实现
├── services/     # 业务逻辑（游戏状态合并、剧情文件、备份、Token 计数、安全存储）
├── database/     # Drift 表定义与查询（6 表：角色/对话/消息/选项/游戏状态/AI设置）
├── constants/    # 固化的系统指令（工具调用指令等）
└── widgets/      # 可复用组件（聊天气泡、选项按钮、输入框）
```

## 项目定位

- **用途**：个人娱乐 / 同人创作 / 技术学习
- **首期平台**：Android（Flutter 架构预留 iOS / Desktop / Web 支持）
- **开源协议**：MIT
- **当前阶段**：MVP，核心玩法已可玩，持续迭代中

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
  Made by Karlan-Trade · Powered by 初雪 & AI
</p>

<p align="center">
  <sub>本项目完全由 AI Agent 完成 · DeepSeek V4 Pro 70% · Claude Opus 4.8 20% · ChatGPT 5.5 10% </sub>
</p>
