# CONTRIBUTING.md

贡献指南 for AttenLink

感谢你对 AttenLink 项目的关注！本文档将指导你如何为项目做出贡献。

## 目录

1. [行为准则](#行为准则)
2. [如何贡献](#如何贡献)
3. [开发流程](#开发流程)
4. [代码规范](#代码规范)
5. [提交规范](#提交规范)
6. [Pull Request 流程](#pull-request-流程)
7. [问题报告](#问题报告)

## 行为准则

### 我们的承诺

为了营造一个开放和友好的环境，我们作为贡献者和维护者承诺：

- 尊重不同的观点和经验
- 接受建设性的批评
- 关注对社区最有利的事情
- 对其他社区成员表示同理心

### 不可接受的行为

- 使用带有性暗示的语言或图像
- 挑衅、侮辱/贬损的评论，以及个人或政治攻击
- 公开或私下的骚扰
- 未经明确许可发布他人的私人信息
- 其他不道德或不专业的行为

## 如何贡献

### 报告 Bug

如果你发现了 Bug，请通过 [GitHub Issues](https://github.com/user/attenlink/issues) 报告，并包含以下信息：

- **问题描述**：清晰简洁地描述 Bug
- **复现步骤**：详细的步骤说明如何复现问题
- **期望行为**：描述你期望发生的事情
- **实际行为**：描述实际发生的事情
- **截图**：如果适用，添加截图帮助说明问题
- **环境信息**：
  - 操作系统及版本
  - Flutter 版本 (`flutter --version`)
  - 应用版本

### 建议新功能

如果你有新功能建议：

1. 先检查是否已有类似建议
2. 创建新的 Issue，使用 "Feature Request" 标签
3. 清晰描述功能的用途和预期行为
4. 如果可能，提供设计草图或参考

### 提交代码

1. Fork 本仓库
2. 创建你的功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交你的修改 (`git commit -m 'feat: add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开一个 Pull Request

## 开发流程

### 环境搭建

```bash
# 1. Fork 并克隆仓库
git clone https://github.com/your-username/attenlink.git
cd attenlink

# 2. 安装依赖
flutter pub get

# 3. 运行代码生成
flutter pub run build_runner build

# 4. 运行应用
flutter run
```

### 分支策略

```
main
  │
  ├── feature/news-card-animation
  ├── feature/ai-verification
  ├── fix/memory-leak
  └── docs/api-documentation
```

- `main`：主分支，保持稳定可运行
- `feature/*`：功能分支
- `fix/*`：修复分支
- `docs/*`：文档分支

### 开发工作流

1. **创建分支**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **进行开发**
   - 编写代码
   - 添加测试
   - 更新文档

3. **运行检查**
   ```bash
   # 代码分析
   flutter analyze
   
   # 运行测试
   flutter test
   
   # 格式化代码
   flutter format lib/
   ```

4. **提交更改**
   ```bash
   git add .
   git commit -m "feat: your feature description"
   ```

5. **推送到远程**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **创建 Pull Request**

## 代码规范

### Dart 代码规范

我们使用 `flutter_lints` 作为基础代码规范。额外的规范：

#### 命名规范

```dart
// 类名：大驼峰命名法
class NewsArticle { }
class FeedRepository { }

// 文件名：小写下划线命名法
// news_article.dart
// feed_repository.dart

// 变量、函数：小写下划线命名法
final articleTitle = '';
Future<void> fetchArticles() { }

// 常量：小写下划线命名法
const maxRetryCount = 3;
const defaultTimeout = Duration(seconds: 30);

// 枚举：大驼峰命名法，值使用小写下划线
enum FeedType {
  rss,
  atom,
  jsonFeed,
}
```

#### 导入排序

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. 第三方包
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// 4. 项目内部
import 'package:attenlink/core/theme/app_theme.dart';
import 'package:attenlink/data/models/news_article.dart';
```

#### 代码组织

```dart
// 类成员顺序：
// 1. 静态常量
// 2. 实例变量
// 3. 构造函数
// 4. 工厂构造函数
// 5. 方法（按字母顺序）
// 6. 重写方法

class ExampleClass {
  // 1. 静态常量
  static const String defaultName = 'Example';
  
  // 2. 实例变量
  final String id;
  String name;
  int count = 0;
  
  // 3. 构造函数
  ExampleClass({
    required this.id,
    this.name = defaultName,
  });
  
  // 4. 工厂构造函数
  factory ExampleClass.fromJson(Map<String, dynamic> json) {
    return ExampleClass(
      id: json['id'],
      name: json['name'],
    );
  }
  
  // 5. 方法
  void increment() {
    count++;
  }
  
  void reset() {
    count = 0;
  }
  
  // 6. 重写方法
  @override
  String toString() => 'ExampleClass(id: $id, name: $name)';
}
```

### Flutter 规范

#### Widget 构建

```dart
// 使用 const 构造函数
const SizedBox(height: 16);

// 使用 ConsumerWidget 替代 StatelessWidget
class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Text('Hello'),
      ),
    );
  }
}

// 拆分复杂 Widget
class ComplexPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildContent(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() { }
  Widget _buildContent() { }
  Widget _buildFooter() { }
}
```

#### 状态管理

```dart
// 使用 Riverpod
final articlesProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final repository = ref.watch(articleRepositoryProvider);
  return repository.getArticles();
});

// 在 Widget 中使用
class ArticlesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(articlesProvider);
    
    return articlesAsync.when(
      data: (articles) => ArticlesList(articles),
      loading: () => const LoadingWidget(),
      error: (error, _) => ErrorWidget(error),
    );
  }
}
```

### 架构规范

项目遵循 Clean Architecture，请确保你的代码符合以下分层：

```
lib/
├── core/           # 核心基础设施，无业务依赖
├── domain/         # 领域层，包含业务逻辑
├── data/           # 数据层，实现数据访问
├── features/       # UI 层，页面和组件
└── shared/         # 共享组件
```

**依赖规则**：
- `features/` 可以依赖所有下层
- `data/` 可以依赖 `domain/` 和 `core/`
- `domain/` 只能依赖 `core/`
- `core/` 不依赖任何业务代码

### 测试规范

#### 测试覆盖率要求

- 业务逻辑：> 80%
- 数据层：> 70%
- UI 层：关键流程有 Widget 测试

#### 测试文件组织

```
test/
├── unit/                    # 单元测试
│   ├── algorithms/
│   ├── usecases/
│   └── repositories/
├── widget/                  # Widget 测试
│   ├── features/
│   └── shared/
└── integration/             # 集成测试
    └── app_test.dart
```

#### 测试示例

```dart
// 单元测试
void main() {
  group('WeightAlgorithm', () {
    test('should calculate correct score for liked category', () {
      final algorithm = WeightAlgorithm();
      final actions = [
        UserAction(category: Category.tech, type: ActionType.like),
      ];
      
      final score = algorithm.calculateScore(actions, Category.tech);
      
      expect(score, greaterThan(0));
    });
  });
}

// Widget 测试
testWidgets('NewsCard displays correct information', (tester) async {
  final article = NewsArticle(
    title: 'Test Title',
    source: 'Test Source',
  );
  
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: NewsCard(article: article),
      ),
    ),
  );
  
  expect(find.text('Test Title'), findsOneWidget);
  expect(find.text('Test Source'), findsOneWidget);
});
```

## 提交规范

### 提交信息格式

使用约定式提交（Conventional Commits）：

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 类型（Type）

| 类型 | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | Bug 修复 |
| `docs` | 文档更新 |
| `style` | 代码格式调整（不影响功能）|
| `refactor` | 重构 |
| `perf` | 性能优化 |
| `test` | 测试相关 |
| `chore` | 构建/工具相关 |
| `ci` | CI/CD 相关 |

### 范围（Scope）

可选，表示影响的模块：

- `core`
- `domain`
- `data`
- `features/explore`
- `features/search`
- `features/settings`
- `shared`

### 示例

```
feat(features/explore): 添加新闻卡片滑动动画

- 实现左滑不喜欢、右滑喜欢的手势
- 添加视觉反馈和动画效果
- 优化滑动性能和流畅度

Closes #123
```

```
fix(data): 修复 RSS 解析时编码错误

某些 RSS 源使用非 UTF-8 编码，导致解析失败。
现在自动检测编码并正确转换。

Fixes #456
```

```
docs: 更新 README 安装说明

- 添加 Windows 平台特定步骤
- 更新 Flutter 版本要求
```

## Pull Request 流程

### PR 创建检查清单

创建 PR 前，请确保：

- [ ] 代码符合项目规范
- [ ] 所有测试通过 (`flutter test`)
- [ ] 代码分析无警告 (`flutter analyze`)
- [ ] 代码已格式化 (`flutter format`)
- [ ] 相关文档已更新
- [ ] PR 描述清晰完整

### PR 标题格式

```
[<type>][<scope>] <简短描述>
```

示例：
- `[feat][explore] 添加新闻卡片滑动动画`
- `[fix][data] 修复 RSS 解析编码错误`
- `[docs] 更新架构文档`

### PR 描述模板

```markdown
## 描述
简要描述这个 PR 做了什么

## 变更类型
- [ ] Bug 修复
- [ ] 新功能
- [ ] 破坏性变更
- [ ] 文档更新

## 测试
- [ ] 添加了单元测试
- [ ] 添加了 Widget 测试
- [ ] 手动测试通过

## 截图（如适用）
添加截图帮助理解变更

## 相关 Issue
Fixes #123
Related to #456
```

### 代码审查流程

1. **自动检查**：CI 会自动运行测试和分析
2. **人工审查**：维护者会审查代码
3. **反馈处理**：根据反馈修改代码
4. **合并**：审查通过后合并到 main 分支

### 审查标准

- 代码符合项目规范
- 逻辑清晰，易于理解
- 有适当的测试覆盖
- 无明显的性能问题
- 文档完整

## 问题报告

### Bug 报告模板

```markdown
**描述**
清晰简洁地描述 Bug

**复现步骤**
1. 打开应用
2. 点击 '...'
3. 滚动到 '...'
4. 看到错误

**期望行为**
描述你期望发生的事情

**实际行为**
描述实际发生的事情

**截图**
如果适用，添加截图

**环境信息**
- 操作系统: [例如 iOS 16, Android 13]
- 设备: [例如 iPhone 14, Pixel 7]
- Flutter 版本: [运行 `flutter --version`]
- 应用版本: [例如 1.0.0+1]

**附加信息**
其他相关信息
```

### 功能请求模板

```markdown
**功能描述**
清晰简洁地描述你想要的功能

**使用场景**
描述这个功能会在什么场景下使用

**期望行为**
描述你期望这个功能如何工作

**替代方案**
描述你考虑过的替代方案

**附加信息**
其他相关信息，如设计草图、参考等
```

## 发布流程

### 版本号规范

使用语义化版本（Semantic Versioning）：`MAJOR.MINOR.PATCH`

- `MAJOR`：不兼容的 API 变更
- `MINOR`：向后兼容的功能添加
- `PATCH`：向后兼容的问题修复

### 发布步骤

1. 更新版本号（`pubspec.yaml`）
2. 更新 `CHANGELOG.md`
3. 创建 Release PR
4. 合并后打标签：`git tag v1.0.0`
5. 推送标签：`git push origin v1.0.0`
6. GitHub Actions 自动构建和发布

## 社区

### 沟通渠道

- **GitHub Issues**：Bug 报告、功能请求
- **GitHub Discussions**：一般讨论、问答
- **Pull Requests**：代码贡献

### 成为维护者

长期贡献者可以申请成为维护者：

1. 持续贡献代码至少 3 个月
2. 熟悉项目架构和规范
3. 帮助审查其他贡献者的 PR
4. 联系现有维护者申请

---

## 致谢

感谢所有为 AttenLink 做出贡献的人！

[贡献者列表](https://github.com/user/attenlink/graphs/contributors)
