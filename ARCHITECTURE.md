# ARCHITECTURE.md

AttenLink 技术架构文档

## 目录

1. [概述](#概述)
2. [架构原则](#架构原则)
3. [系统架构](#系统架构)
4. [数据流](#数据流)
5. [分层设计](#分层设计)
6. [核心模块](#核心模块)
7. [技术选型](#技术选型)
8. [数据模型](#数据模型)
9. [安全设计](#安全设计)
10. [性能考虑](#性能考虑)

## 概述

AttenLink 采用 **Clean Architecture**（整洁架构）结合 **Layered Architecture**（分层架构）的设计理念，实现高内聚、低耦合的代码结构。

### 设计目标

- **可测试性**：业务逻辑独立于框架、UI和数据库
- **独立性**：业务规则不依赖任何外部资源
- **可维护性**：清晰的依赖关系，易于理解和修改
- **可扩展性**：方便添加新功能和新数据源

## 架构原则

### 依赖规则

依赖关系只能向内指向核心领域：

```
Presentation Layer (UI) → Domain Layer ← Data Layer
                              ↑
                         Core Layer
```

- **外层**（UI、数据）依赖于**内层**（领域、核心）
- **内层**不依赖于外层
- 通过接口和依赖注入实现解耦

### SOLID 原则应用

| 原则 | 应用方式 |
|------|----------|
| S - 单一职责 | 每个类只负责一个功能 |
| O - 开闭原则 | 通过接口扩展新功能 |
| L - 里氏替换 | 数据源可互换 |
| I - 接口隔离 | 细粒度接口定义 |
| D - 依赖倒置 | 依赖抽象而非具体实现 |

## 系统架构

### 整体架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   Explore   │  │   Search    │  │       Settings          │  │
│  │    Page     │  │    Page     │  │        Page             │  │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬─────────────┘  │
│         │                │                      │                │
│         └────────────────┼──────────────────────┘                │
│                          │                                       │
│                   ┌──────┴──────┐                                │
│                   │  Riverpod   │                                │
│                   │  Providers  │                                │
│                   └──────┬──────┘                                │
└──────────────────────────┼──────────────────────────────────────┘
                           │
┌──────────────────────────┼──────────────────────────────────────┐
│                          ▼                                       │
│                        Domain Layer                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │  Entities   │  │  Use Cases  │  │    Algorithms           │  │
│  │             │  │             │  │  (Weight Algorithm)     │  │
│  └─────────────┘  └──────┬──────┘  └─────────────────────────┘  │
│                          │                                       │
└──────────────────────────┼──────────────────────────────────────┘
                           │
┌──────────────────────────┼──────────────────────────────────────┐
│                          ▼                                       │
│                         Data Layer                               │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                      Repository                          │   │
│  │         (Abstract Data Access Interface)                 │   │
│  └─────────────────────────┬────────────────────────────────┘   │
│                            │                                     │
│         ┌──────────────────┼──────────────────┐                 │
│         │                  │                  │                 │
│         ▼                  ▼                  ▼                 │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────────┐       │
│  │   Remote    │   │    Local    │   │   AI Adapters   │       │
│  │ DataSources │   │ DataSources │   │                 │       │
│  │             │   │             │   │  - OpenAI       │       │
│  │ - RSS/Atom  │   │  - Isar DB  │   │  - Gemini       │       │
│  │ - HN/Reddit │   │  - Hive     │   │  - Claude       │       │
│  │ - JSON Feed │   │  - SharedPref│  │  - Kimi/GLM     │       │
│  └─────────────┘   └─────────────┘   └─────────────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 模块依赖关系

```
lib/
├── main.dart
├── app.dart
│
├── core/                    # 无依赖（除Flutter SDK）
│   ├── theme/
│   ├── constants/
│   ├── extensions/
│   ├── services/
│   ├── skills/
│   └── utils/
│
├── domain/                  # 仅依赖 core/
│   ├── entities/
│   ├── algorithms/
│   └── usecases/
│
├── data/                    # 依赖 core/ 和 domain/
│   ├── adapters/
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── features/                # 依赖所有下层
│   ├── explore/
│   ├── search/
│   └── settings/
│
└── shared/                  # 依赖所有下层
    ├── providers/
    └── widgets/
```

## 数据流

### 新闻获取流程

```
┌─────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  User   │────▶│  FeedSource │────▶│  Remote DS  │────▶│  External   │
│ Request │     │  Config     │     │  (RSS/HN/   │     │  APIs       │
│         │     │             │     │  Reddit)    │     │             │
└─────────┘     └─────────────┘     └──────┬──────┘     └─────────────┘
                                           │
                                           ▼
                                    ┌─────────────┐
                                    │  FeedParser │
                                    │  (webfeed)  │
                                    └──────┬──────┘
                                           │
                                           ▼
┌─────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   UI    │◀────│  Repository │◀────│  Local DS   │◀────│  NewsArticle│
│ Display │     │             │     │  (Isar)     │     │  Model      │
└─────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### AI 查证流程

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  User Like  │────▶│  Verification│────▶│  AI Adapter │────▶│  AI Service │
│   Action    │     │   Use Case  │     │  (OpenAI/   │     │  (API Call) │
│             │     │             │     │  Gemini)    │     │             │
└─────────────┘     └─────────────┘     └──────┬──────┘     └──────┬──────┘
                                               │                    │
                                               │                    ▼
                                               │             ┌─────────────┐
                                               │             │  AI Response│
                                               │             │  (Fact Check)│
                                               │             └──────┬──────┘
                                               │                    │
                                               ▼                    ▼
                                        ┌─────────────┐     ┌─────────────┐
                                        │  Verification│◀────│  Result     │
                                        │   Result    │     │  Parser     │
                                        │  (Stored)   │     │             │
                                        └──────┬──────┘     └─────────────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │  Push to UI │
                                        │  (News Card)│
                                        └─────────────┘
```

### 权重算法流程

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  User Action │────▶│   Weight    │────▶│  User Pref  │
│ (Like/Dislike│     │  Algorithm  │     │  Update     │
│ /Skip)      │     │             │     │             │
└─────────────┘     └──────┬──────┘     └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  Category   │
                    │   Scores    │
                    │  (Adjusted) │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  Next News  │
                    │  Selection  │
                    │  (Personalized)│
                    └─────────────┘
```

## 分层设计

### Core Layer（核心层）

包含应用的基础设置和工具，不依赖业务逻辑。

```dart
// core/theme/app_theme.dart
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(...),
  );
}

// core/utils/logger.dart
class AppLogger {
  static void d(String message) => logger.d(message);
}
```

### Domain Layer（领域层）

包含业务逻辑的核心，独立于框架和外部资源。

```dart
// domain/entities/feed_source.dart
abstract class FeedSource {
  String get id;
  String get name;
  String get url;
  FeedType get type;
}

// domain/algorithms/weight_algorithm.dart
class WeightAlgorithm {
  double calculateCategoryScore(
    List<UserAction> actions,
    Category category,
  ) {
    // 业务逻辑实现
  }
}
```

### Data Layer（数据层）

负责数据的获取和存储，实现 Repository 接口。

```dart
// data/repositories/article_repository.dart
class ArticleRepository implements IArticleRepository {
  final RemoteDataSource _remote;
  final LocalDataSource _local;
  
  ArticleRepository(this._remote, this._local);
  
  @override
  Future<List<NewsArticle>> getArticles() async {
    // 实现：先查本地，再同步远程
  }
}

// data/datasources/remote/rss_feed_data_source.dart
class RssFeedDataSource implements FeedDataSource {
  final Dio _dio;
  
  @override
  Future<List<NewsArticle>> fetchFeed(String url) async {
    final response = await _dio.get(url);
    return _parseRss(response.data);
  }
}
```

### Presentation Layer（表现层）

UI 层，使用 Riverpod 管理状态。

```dart
// features/explore/explore_page.dart
class ExplorePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(articlesProvider);
    
    return articles.when(
      data: (data) => NewsCardList(data),
      loading: () => LoadingWidget(),
      error: (err, _) => ErrorWidget(err),
    );
  }
}
```

## 核心模块

### 1. Feed 聚合模块

| 组件 | 职责 |
|------|------|
| `FeedAggregator` | 协调多个数据源，统一获取新闻 |
| `FeedParallelFetcher` | 并行获取多个 Feed，提高性能 |
| `FeedDataSource` | 抽象接口，统一不同 Feed 类型 |
| `RssFeedDataSource` | RSS 源实现 |
| `AtomFeedDataSource` | Atom 源实现 |
| `JsonFeedDataSource` | JSON Feed 实现 |
| `HackerNewsDataSource` | HN API 实现 |
| `RedditDataSource` | Reddit API 实现 |

### 2. AI 服务模块

| 组件 | 职责 |
|------|------|
| `AIProviderFactory` | 创建对应 AI 提供商的适配器 |
| `AIProviderAdapter` | 抽象接口，统一 AI 调用 |
| `OpenAIAdapter` | OpenAI API 适配 |
| `GeminiAdapter` | Gemini API 适配 |
| `VerificationUseCase` | 事实查证业务逻辑 |

### 3. 权重算法模块

| 组件 | 职责 |
|------|------|
| `WeightAlgorithm` | 计算用户偏好分数 |
| `UserPreferences` | 存储用户偏好数据 |
| `CategoryScore` | 分类分数模型 |

### 4. 本地存储模块

| 组件 | 职责 |
|------|------|
| `IsarService` | Isar 数据库服务 |
| `ArticleLocalDataSource` | 文章本地存储 |
| `FeedSourceLocalDataSource` | Feed 源配置存储 |
| `UserPreferencesDataSource` | 用户偏好存储 |

## 技术选型

### 状态管理

| 技术 | 版本 | 选择理由 |
|------|------|----------|
| Riverpod | ^2.6.1 | 编译时安全、支持代码生成、测试友好 |

### 网络请求

| 技术 | 版本 | 选择理由 |
|------|------|----------|
| Dio | ^5.8.0+1 | 功能强大、拦截器支持、性能优秀 |

### 本地存储

| 技术 | 版本 | 用途 |
|------|------|------|
| Isar | ^3.1.0+1 | 主要数据库，高性能 NoSQL |
| Hive | ^2.2.3 | 轻量级键值存储 |
| SharedPreferences | 内置 | 简单配置存储 |

### Feed 解析

| 技术 | 版本 | 选择理由 |
|------|------|----------|
| webfeed | ^0.7.0 | 支持 RSS/Atom，维护活跃 |

### UI 动画

| 技术 | 版本 | 选择理由 |
|------|------|----------|
| flutter_animate | ^4.5.2 | 声明式动画、易于使用 |

## 数据模型

### 核心实体关系

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   NewsArticle   │       │   FeedSource    │       │   Category      │
├─────────────────┤       ├─────────────────┤       ├─────────────────┤
│ - id            │   ┌──▶│ - id            │       │ - id            │
│ - title         │   │   │ - name          │       │ - name          │
│ - summary       │   │   │ - url           │       │ - weight        │
│ - content       │   │   │ - type          │       └─────────────────┘
│ - url           │   │   │ - categories[]  │
│ - imageUrl      │   │   └─────────────────┘
│ - publishedAt   │   │
│ - sourceId      │───┘
│ - categories[]  │
│ - isVerified    │       ┌─────────────────┐       ┌─────────────────┐
│ - verificationId│──────▶│ Verification    │       │   AIProvider    │
└─────────────────┘       ├─────────────────┤       ├─────────────────┤
                          │ - id            │       │ - id            │
                          │ - articleId     │       │ - name          │
                          │ - status        │       │ - type          │
                          │ - result        │       │ - apiKey        │
                          │ - checkedAt     │       │ - config        │
                          └─────────────────┘       └─────────────────┘
```

### 关键模型定义

```dart
// data/models/news_article.dart
@collection
class NewsArticle {
  Id id = Isar.autoIncrement;
  
  late String title;
  late String summary;
  String? content;
  late String url;
  String? imageUrl;
  late DateTime publishedAt;
  
  final source = IsarLink<FeedSource>();
  List<String> categories = [];
  
  bool isVerified = false;
  final verification = IsarLink<VerificationResult>();
}

// data/models/verification_result.dart
@embedded
class VerificationResult {
  late String status; // "verified", "questionable", "false"
  String? explanation;
  List<String> sources = [];
  late DateTime checkedAt;
}
```

## 安全设计

### 数据安全

| 措施 | 说明 |
|------|------|
| API Key 加密 | 用户配置的 AI Key 使用 AES 加密存储 |
| 本地数据库加密 | Isar 支持数据库加密 |
| HTTPS 通信 | 所有网络请求使用 HTTPS |

### 隐私保护

| 措施 | 说明 |
|------|------|
| 本地优先 | 用户数据优先存储在本地 |
| 最小权限 | 仅请求必要的系统权限 |
| 无追踪 | 不包含第三方追踪代码 |

## 性能考虑

### 优化策略

| 策略 | 实现方式 |
|------|----------|
| 懒加载 | 使用 `ListView.builder` |
| 图片缓存 | `cached_network_image` |
| 并行请求 | `FeedParallelFetcher` |
| 增量更新 | 仅同步新文章 |
| 后台调度 | `BackgroundScheduler` |

### 性能指标目标

| 指标 | 目标 |
|------|------|
| 应用启动时间 | < 2 秒 |
| 页面切换 | < 100ms |
| 新闻加载 | < 500ms |
| 滑动帧率 | 60 FPS |

---

## 附录

### 目录结构详细说明

```
lib/
├── main.dart                    # 应用入口，初始化
├── app.dart                     # MaterialApp 配置，主题，路由
│
├── core/                        # 核心基础设施
│   ├── constants/               # 应用常量
│   │   └── app_constants.dart
│   ├── extensions/              # Dart/Flutter 扩展
│   │   ├── context_extensions.dart
│   │   └── string_extensions.dart
│   ├── mcp/                     # MCP 工具桥接
│   │   └── playwright_mcp_bridge.js
│   ├── services/                # 后台服务
│   │   └── background_scheduler.dart
│   ├── skills/                  # Skill 管理
│   │   ├── skill_manager.dart
│   │   └── skill_sync_service.dart
│   ├── theme/                   # Material Design 3.1 主题
│   │   └── app_theme.dart
│   └── utils/                   # 工具类
│       └── logger.dart
│
├── data/                        # 数据层
│   ├── adapters/                # 外部服务适配器
│   │   └── ai/
│   │       ├── ai_provider_factory.dart
│   │       ├── gemini_adapter.dart
│   │       └── openai_adapter.dart
│   ├── datasources/             # 数据源
│   │   ├── local/               # 本地数据源
│   │   │   ├── ai_provider_local_data_source.dart
│   │   │   ├── article_local_data_source.dart
│   │   │   ├── feed_source_local_data_source.dart
│   │   │   ├── isar_entities.dart
│   │   │   ├── isar_service.dart
│   │   │   ├── local_datasources.dart
│   │   │   ├── user_preferences_data_source.dart
│   │   │   └── verification_local_data_source.dart
│   │   └── remote/              # 远程数据源
│   │       ├── atom_feed_data_source.dart
│   │       ├── feed_aggregator.dart
│   │       ├── feed_parallel_fetcher.dart
│   │       ├── hackernews_data_source.dart
│   │       ├── json_feed_data_source.dart
│   │       ├── reddit_data_source.dart
│   │       ├── remote_datasources.dart
│   │       └── rss_feed_data_source.dart
│   ├── models/                  # 数据模型
│   │   ├── ai_provider_config.dart
│   │   ├── feed_source_config.dart
│   │   ├── models.dart
│   │   ├── news_article.dart
│   │   └── verification_result.dart
│   └── repositories/            # 仓库实现
│       ├── ai_provider_repository.dart
│       ├── article_repository.dart
│       ├── feed_source_repository.dart
│       ├── repositories.dart
│       └── verification_repository.dart
│
├── domain/                      # 领域层
│   ├── algorithms/              # 算法
│   │   └── weight_algorithm.dart
│   ├── entities/                # 领域实体
│   │   ├── ai_service_provider.dart
│   │   └── feed_source.dart
│   └── usecases/                # 用例
│       └── subagent_coordinator.dart
│
├── features/                    # 功能模块（UI层）
│   ├── explore/                 # 探索页面
│   │   ├── widgets/
│   │   │   ├── ai_summary_panel.dart
│   │   │   └── immersive_news_card.dart
│   │   └── explore_page.dart
│   ├── search/                  # 搜索页面
│   │   └── search_page.dart
│   └── settings/                # 设置页面
│       ├── ai_provider_page.dart
│       ├── feed_source_page.dart
│       └── settings_page.dart
│
└── shared/                      # 共享组件
    ├── providers/               # Riverpod Providers
    │   ├── data_providers.dart
    │   └── providers.dart
    └── widgets/                 # 共享 Widgets
        └── state_widgets.dart
```

### 参考资料

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Riverpod Documentation](https://riverpod.dev/docs/concepts/about_code_generation)
