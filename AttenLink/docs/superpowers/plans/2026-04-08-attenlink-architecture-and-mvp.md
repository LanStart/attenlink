# AttenLink Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a cross-platform (Android, iOS, Linux, MacOS, Windows) Flutter news aggregation app named AttenLink with 3 tabs (Explore, Search, Settings), RSS integration, multi-LLM support (Claude, OpenAI, Gemini, GLM), and AI-driven fact-checking exploration.

**Architecture:** The app will use Flutter for the UI. We'll use `provider` or `riverpod` for state management, `sqflite` or `hive` for local storage, and `dio` for networking. The architecture will be divided into data layer (repositories/services), domain layer (models), and presentation layer (UI). We will implement adapters for different AI providers and use an MCP-like tool calling pattern for the AI's fact-checking capabilities.

**Tech Stack:** Flutter, Dart, Riverpod (State Management), Hive (Local DB), Webfeed (RSS Parsing), Dio (Networking).

---

### Task 1: Initialize Flutter Project and Base Structure

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`
- Create: `lib/presentation/home/home_screen.dart`

- [ ] **Step 1: Write pubspec.yaml**
```yaml
name: attenlink
description: AI-driven RSS news aggregator.
publish_to: 'none'
version: 1.0.0+1
environment:
  sdk: '>=3.0.0 <4.0.0'
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  dio: ^5.4.0
  webfeed_revised: ^0.5.0
  shared_preferences: ^2.2.2
  swipe_cards: ^2.0.0
  url_launcher: ^6.2.1
  flutter_markdown: ^0.6.18
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  uses-material-design: true
```

- [ ] **Step 2: Create basic `main.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/home/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: AttenLinkApp()));
}

class AttenLinkApp extends StatelessWidget {
  const AttenLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AttenLink',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
```

- [ ] **Step 3: Create `home_screen.dart` with bottom navigation**
```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const Center(child: Text('探索 (Explore)')),
    const Center(child: Text('搜索 (Search)')),
    const Center(child: Text('设置 (Settings)')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore), label: '探索'),
          NavigationDestination(icon: Icon(Icons.search), label: '搜索'),
          NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}
```

### Task 2: Settings Tab - RSS & AI Configuration

**Files:**
- Create: `lib/presentation/settings/settings_screen.dart`
- Create: `lib/domain/models/ai_config.dart`
- Create: `lib/data/repositories/settings_repository.dart`

- [ ] **Step 1: Define AI Config Model**
```dart
// lib/domain/models/ai_config.dart
enum AIProvider { openai, claude, gemini, glm }

class AIConfig {
  final AIProvider provider;
  final String apiKey;
  final String baseUrl;
  
  AIConfig({required this.provider, required this.apiKey, this.baseUrl = ''});
}
```

- [ ] **Step 2: Create Settings Repository using SharedPreferences**
```dart
// lib/data/repositories/settings_repository.dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  Future<void> saveRssUrls(List<String> urls) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('rss_urls', urls);
  }
  
  Future<List<String>> getRssUrls() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('rss_urls') ?? [];
  }
  
  // Implement similar methods for AI configs...
}
```

- [ ] **Step 3: Create Settings Screen UI**
```dart
// lib/presentation/settings/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('RSS 源管理'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { /* Navigate to RSS manager */ },
          ),
          ListTile(
            title: const Text('AI 服务配置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { /* Navigate to AI config */ },
          ),
        ],
      ),
    );
  }
}
```

### Task 3: Multi-LLM Access Layer

**Files:**
- Create: `lib/data/services/ai_service.dart`
- Create: `lib/data/services/llm/openai_client.dart`
- Create: `lib/data/services/llm/claude_client.dart`
- Create: `lib/data/services/llm/gemini_client.dart`
- Create: `lib/data/services/llm/glm_client.dart`

- [ ] **Step 1: Abstract AI Service Interface**
```dart
// lib/data/services/ai_service.dart
abstract class AIService {
  Future<String> generateSummary(String text);
  Future<String> factCheck(String articleContent);
}
```

- [ ] **Step 2: Implement Provider Clients (e.g., OpenAI)**
```dart
// lib/data/services/llm/openai_client.dart
import 'package:dio/dio.dart';
import '../ai_service.dart';

class OpenAIClient implements AIService {
  final String apiKey;
  final Dio _dio = Dio();
  
  OpenAIClient(this.apiKey) {
    _dio.options.baseUrl = 'https://api.openai.com/v1';
    _dio.options.headers['Authorization'] = 'Bearer $apiKey';
  }
  
  @override
  Future<String> generateSummary(String text) async {
    // Basic implementation
    return "Summary placeholder";
  }
  
  @override
  Future<String> factCheck(String articleContent) async {
    return "Fact check placeholder";
  }
}
```

### Task 4: RSS Parsing and Search Tab

**Files:**
- Create: `lib/data/services/rss_service.dart`
- Create: `lib/presentation/search/search_screen.dart`

- [ ] **Step 1: RSS Service**
```dart
// lib/data/services/rss_service.dart
import 'package:dio/dio.dart';
import 'package:webfeed_revised/webfeed_revised.dart';

class RssService {
  final Dio _dio = Dio();
  
  Future<RssFeed?> fetchFeed(String url) async {
    try {
      final response = await _dio.get(url);
      return RssFeed.parse(response.data.toString());
    } catch (e) {
      return null;
    }
  }
}
```

- [ ] **Step 2: Search Screen UI**
```dart
// lib/presentation/search/search_screen.dart
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(hintText: '搜索文章关键词...'),
          onChanged: (val) => setState(() => _query = val),
        ),
      ),
      body: const Center(child: Text('RSS 文章列表')),
    );
  }
}
```

### Task 5: Explore Tab (Swipe Cards & AI Verification)

**Files:**
- Create: `lib/presentation/explore/explore_screen.dart`

- [ ] **Step 1: Tinder-style Swipe Cards UI**
```dart
// lib/presentation/explore/explore_screen.dart
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;
  
  @override
  void initState() {
    super.initState();
    // Initialize dummy items
    for (int i = 0; i < 5; i++) {
      _swipeItems.add(SwipeItem(
        content: "News Article $i",
        likeAction: () { /* Trigger AI Fact Check */ },
        nopeAction: () { /* Discard */ },
      ));
    }
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('探索')),
      body: SwipeCards(
        matchEngine: _matchEngine,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Center(child: Text(_swipeItems[index].content)),
          );
        },
        onStackFinished: () {
          // Load more
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Update Main Screen to use the new tabs**
Modify `home_screen.dart` to use `ExploreScreen`, `SearchScreen`, and `SettingsScreen`.
