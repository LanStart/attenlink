# AttenLink

AttenLink 是一款基于 Flutter 构建的 AI 驱动的 RSS 新闻聚合器。它不仅提供传统的 RSS 订阅和阅读功能，还深度集成了大语言模型（LLM）和多种搜索引擎，旨在帮助用户智能总结新闻内容并进行自动化事实核查。

## ✨ 核心特性

- **RSS 聚合**：轻松订阅和管理您喜欢的信息源。
- **AI 智能摘要 & 事实核查**：支持集成主流 AI 模型，自动对新闻内容进行总结和交叉验证。
  - 支持的提供商：OpenAI, Claude, Gemini, GLM (智谱)
- **聚合搜索**：内置多种搜索引擎（DuckDuckGo, Bing, Google, Baidu）以辅助事实核查。
- **跨平台支持**：支持 Android, Linux, Windows, macOS。

## 🚀 GitHub Actions 自动打包

本项目已配置完整的 CI/CD 工作流，可自动完成跨平台产物的构建和发布。工作流配置文件位于 [release.yml](.github/workflows/release.yml)。

### 如何触发构建和发布？

1. **手动触发构建（测试用）**：
   - 进入本项目的 **Actions** 页面。
   - 选择 `Build and Release AttenLink` 工作流。
   - 点击 `Run workflow` 按钮。
   - 构建完成后，您可以在该次运行的 "Artifacts" 列表中直接下载各个平台的产物包（如 `apk`, `linux.tar.gz`, `windows.zip`, `macos.app`），无需发布 Release 即可测试。

2. **自动发布正式 Release**：
   - 当您向仓库推送以 `v` 开头的 Tag（例如 `v1.0.0`）时，工作流会自动运行。
   - 构建完成后，系统会自动在 GitHub Releases 页面创建一个新的版本发布，并附带所有平台的安装包。

## 🛠️ 本地开发指南

### 环境要求

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (推荐版本: 3.22.0)
- 对应平台的开发工具 (Android Studio / Visual Studio / Xcode 等)

### 运行项目

1. 克隆仓库（包含子模块）：
   ```bash
   git clone --recursive <repository-url>
   cd <repository-name>/AttenLink
   ```

2. 获取依赖：
   ```bash
   flutter pub get
   ```

3. 运行应用：
   ```bash
   flutter run
   ```

## ⚙️ 配置说明

在应用内的“设置”页面，您可以：
1. 添加或移除 RSS 订阅源。
2. 选择并配置您首选的 AI 模型服务商及 API Key。
3. 配置搜索引擎 API（例如 Bing, Google, Baidu 需要 API Key；DuckDuckGo 为直接支持）。
