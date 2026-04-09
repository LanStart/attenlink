# AGENTS.md

AI助手协作指南 for AttenLink

## 项目概述

AttenLink 是一款 AI 驱动的事实资讯聚合应用，基于 Flutter 打造，支持 Android、iOS、Linux、macOS 和 Windows 全平台。

**核心功能：**
- AI 智能推送 - 基于权重算法个性化推荐新闻
- 事实查证 - 喜欢的新闻自动触发 AI 查证
- 沉浸式交互 - 左滑不喜欢，右滑喜欢，下滑查看详情
- 多源聚合 - RSS / Atom / JSON Feed / HackerNews / Reddit

## 开发环境

### 环境要求

- Flutter SDK 3.x
- Dart 3.x
- Android Studio / VS Code

### 常用命令

```bash
# 安装依赖
flutter pub get

# 运行应用（Windows）
flutter run -d windows

# 运行应用（其他平台）
flutter run -d <device_id>

# 运行测试
flutter test

# 代码分析
flutter analyze

# 格式化代码
flutter format lib/

# 生成代码（Isar等）
flutter pub run build_runner build

# 清理构建
flutter clean
```

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # MaterialApp 配置 + 底部导航
├── core/                        # 核心基础设施
│   ├── theme/                   # MD3.1 主题定义
│   ├── constants/               # 常量
│   ├── extensions/              # 扩展方法
│   ├── services/                # 后台服务
│   ├── skills/                  # Skill管理
│   └── utils/                   # 工具类
├── data/                        # 数据层
│   ├── adapters/                # AI提供商适配器
│   ├── datasources/             # 数据源（本地/远程）
│   ├── models/                  # 数据模型
│   └── repositories/            # 仓库实现
├── domain/                      # 领域层
│   ├── entities/                # 领域实体
│   ├── algorithms/              # 权重算法
│   └── usecases/                # 用例
├── features/                    # 功能模块
│   ├── explore/                 # 探索页面
│   ├── search/                  # 搜索页面
│   └── settings/                # 设置页面
└── shared/                      # 共享组件
    ├── providers/               # Riverpod Providers
    └── widgets/                 # 共享 Widgets
```

## 代码风格规范

### Dart 代码规范

- 使用 `flutter_lints` 提供的规则
- 类名使用大驼峰命名法（UpperCamelCase）
- 文件、变量、函数使用小写下划线命名法（lower_snake_case）
- 常量使用小写下划线命名法

### 导入排序

```dart
// 1. Dart SDK 导入
import 'dart:async';
import 'dart:convert';

// 2. Flutter 包导入
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 3. 第三方包导入
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

// 4. 项目内部导入
import 'package:attenlink/core/theme/app_theme.dart';
import 'package:attenlink/data/models/news_article.dart';
```

### 状态管理

- 使用 **Riverpod** 进行状态管理
- 将 Providers 放在 `shared/providers/` 或功能模块内
- 使用 `ConsumerWidget` 或 `ConsumerStatefulWidget` 替代 `StatelessWidget`/`StatefulWidget`

### 架构原则

- 遵循 **Clean Architecture** 分层
- UI 层（Features）→ 领域层（Domain）→ 数据层（Data）
- 依赖方向：外层依赖内层
- 使用 Repository 模式抽象数据源

## 添加新功能指南

### 1. 添加新页面

```dart
// features/new_feature/new_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewPage extends ConsumerWidget {
  const NewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Feature')),
      body: const Center(child: Text('Content')),
    );
  }
}
```

### 2. 添加新数据源

1. 在 `data/datasources/remote/` 或 `data/datasources/local/` 创建数据源类
2. 在 `data/repositories/` 创建对应的 Repository
3. 在 `shared/providers/` 添加 Provider

### 3. 添加新模型

```dart
// data/models/new_model.dart
import 'package:isar/isar.dart';

part 'new_model.g.dart';

@collection
class NewModel {
  Id id = Isar.autoIncrement;
  
  late String title;
  late DateTime createdAt;
}
```

运行代码生成：
```bash
flutter pub run build_runner build
```

## 测试

### 运行测试

```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/widget_test.dart

# 带覆盖率报告
flutter test --coverage
```

### 测试规范

- Widget 测试放在 `test/` 目录
- 测试文件命名：`{feature}_test.dart`
- 使用 `testWidgets` 进行 Widget 测试

## Git 工作流

### 分支命名

- 功能分支：`feature/<feature-name>`
- 修复分支：`fix/<bug-description>`
- 文档分支：`docs/<doc-description>`

### 提交规范

使用约定式提交（Conventional Commits）：

```
feat: 添加新功能
fix: 修复 bug
docs: 文档更新
style: 代码格式调整（不影响功能）
refactor: 重构
test: 测试相关
chore: 构建/工具相关
```

示例：
```
feat: 添加 Reddit 数据源支持
fix: 修复新闻卡片滑动卡顿问题
docs: 更新 README 安装说明
```

## 依赖管理

### 添加新依赖

1. 在 `pubspec.yaml` 的 `dependencies` 或 `dev_dependencies` 中添加
2. 运行 `flutter pub get`
3. 更新 AGENTS.md 中的技术栈表格

### 依赖选择原则

- 优先选择维护活跃、Star 数高的包
- 检查 Flutter/Dart SDK 版本兼容性
- 避免引入不必要的重量级依赖

## AI 服务集成

### 支持的 AI 提供商

- OpenAI
- Claude (Anthropic)
- Gemini (Google)
- Kimi (Moonshot)
- GLM (智谱)

### 添加新 AI 提供商

1. 在 `data/adapters/ai/` 创建适配器类，继承 `AIProviderAdapter`
2. 在 `AIProviderFactory` 中注册新提供商
3. 在 `domain/entities/ai_service_provider.dart` 添加枚举值

## Feed 源集成

### 支持的 Feed 类型

- RSS Feed
- Atom Feed
- JSON Feed
- HackerNews API
- Reddit API

### 添加新 Feed 源

1. 在 `data/datasources/remote/` 创建数据源类
2. 实现 `FeedDataSource` 接口
3. 在 `FeedAggregator` 中注册

## 安全注意事项

- **永远不要**将 API 密钥提交到代码仓库
- 使用 `flutter_dotenv` 或环境变量管理敏感信息
- 在 `.gitignore` 中忽略包含密钥的配置文件
- AI 提供商的 API Key 由用户在设置页面自行配置

## 性能优化

- 使用 `cached_network_image` 缓存网络图片
- 列表使用 `ListView.builder` 实现懒加载
- 复杂计算使用 `compute` 隔离到后台线程
- 避免在 `build` 方法中进行耗时操作

## 常见问题

### 构建失败

```bash
# 清理并重新构建
flutter clean
flutter pub get
flutter run
```

### 代码生成问题

```bash
# 删除旧生成文件并重新生成
flutter pub run build_runner build --delete-conflicting-outputs
```

### 依赖冲突

```bash
# 查看依赖树
flutter pub deps

# 升级依赖
flutter pub upgrade
```

## 资源链接

- [Flutter 官方文档](https://docs.flutter.dev)
- [Dart 语言指南](https://dart.dev/guides)
- [Riverpod 文档](https://riverpod.dev)
- [Material Design 3](https://m3.material.io)
