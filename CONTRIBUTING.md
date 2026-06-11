# 贡献指南

感谢你对 GalChat 的关注！

## 行为准则

请保持友善和尊重。本项目社区欢迎所有人的参与。

## 如何贡献

### 报告 Bug

如果发现 Bug，请在 GitHub Issues 中提交，包含以下信息：

- 使用的设备和 Android 版本
- 使用的 AI 后端（DeepSeek / OpenAI / 其他）
- 复现步骤
- 期望行为 vs 实际行为
- 相关的错误日志

### 提交代码

1. Fork 本项目
2. 创建你的功能分支：`git checkout -b feature/amazing-feature`
3. 提交你的更改：`git commit -m 'Add amazing feature'`
4. 推送到分支：`git push origin feature/amazing-feature`
5. 打开一个 Pull Request

### 代码规范

- 遵循 `analysis_options.yaml` 中的 lint 规则
- 修改 `lib/database/tables.dart` 后，运行 `dart run build_runner build --delete-conflicting-outputs` 重新生成数据库代码
- **绝对禁止**在代码、数据库或备份文件中包含任何 API Key
- 新功能建议先开 Issue 讨论，避免重复劳动

### 测试

提交前请确保现有测试通过：

```bash
flutter test
```

如果添加了新功能，请补充相应的单元测试。

## 项目结构

参见 [README.md](./README.md) 中的技术架构部分。

## 联系方式

如有问题，欢迎在 GitHub Issues 中提出。
