# AttenLink

**专注事实的AI资讯聚合工具**

AttenLink 是一款 AI 驱动的事实资讯聚合应用，基于 Flutter 打造，支持 Android、iOS、Linux、macOS 和 Windows 全平台。

## 核心特性

- 🤖 **AI 智能推送** - 基于权重算法个性化推荐新闻
- ✅ **事实查证** - 喜欢的新闻自动触发 AI 查证，持续追踪事实
- 👆 **沉浸式交互** - 左滑不喜欢，右滑喜欢，下滑查看详情
- 🔍 **智能搜索** - 关键词搜索 + 语义搜索（需接入图像识别模型）
- 📰 **多源聚合** - RSS / Atom / JSON Feed / HackerNews / Reddit
- 🧠 **多AI服务商** - OpenAI / Claude / Gemini / Kimi / GLM 自由切换
- 🔗 **MCP 工具** - 内置搜索、推理等 MCP 工具
- 🌙 **深色模式** - 完整的 Material Design 3.1 主题

## 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.x + Dart |
| 设计语言 | Material Design 3.1 |
| 状态管理 | Riverpod |
| 本地存储 | Hive |
| 网络请求 | Dio |
| Feed解析 | webfeed |
| UI动画 | flutter_animate |

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # MaterialApp 配置 + 底部导航
├── core/                        # 核心基础设施
│   ├── theme/                   # MD3.1 主题定义
│   ├── constants/               # 常量
│   ├── extensions/              # 扩展方法
│   └── utils/                   # 工具类
├── data/                        # 数据层
│   └── models/                  # 数据模型
├── domain/                      # 领域层
│   ├── entities/                # 抽象接口
│   └── algorithms/              # 权重算法
├── features/                    # 功能模块
│   ├── explore/                 # 探索页面
│   ├── search/                  # 搜索页面
│   └── settings/                # 设置页面
└── shared/                      # 共享组件
```

## 开始使用

### 环境要求

- Flutter SDK 3.x
- Dart 3.x

### 安装

```bash
# 克隆项目
git clone https://github.com/user/attenlink.git
cd attenlink

# 安装依赖
flutter pub get

# 运行（Windows）
flutter run -d windows

# 运行（其他平台）
flutter run -d <device>
```

## 三个核心界面

### 探索（Explore）
- 全屏新闻卡片沉浸式体验
- 右滑喜欢 → 触发 AI 查证
- 左滑不喜欢 → 降低权重
- 下滑查看详细内容
- 查证结果以标准新闻卡片推送

### 搜索（Search）
- 关键词全文搜索
- 语义搜索（需图像识别模型）
- 按来源/时间/查证状态筛选
- 实时搜索结果

### 设置（Settings）
- 资讯源管理（RSS/Atom/JSON Feed/HN/Reddit）
- AI 服务商配置（OpenAI/Claude/Gemini/Kimi/GLM）
- 主题切换、通知偏好

## License

MIT
