import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:webfeed_revised/domain/rss_item.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/rss_service.dart';
import '../../data/services/ai_service_factory.dart';
import '../../data/services/search_service.dart';
import '../../data/services/tracking_service.dart';
import '../../domain/models/explore_item.dart';
import 'package:url_launcher/url_launcher.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<SwipeItem> _swipeItems = [];
  MatchEngine? _matchEngine;
  bool _isLoading = true;
  
  final RssService _rssService = RssService();
  final SettingsRepository _settingsRepository = SettingsRepository();
  final SearchService _searchService = SearchService();
  final TrackingService _trackingService = TrackingService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    _swipeItems.clear();

    // 1. Check tracked topics for daily updates (Correction/Fact checking)
    await _checkTrackedTopics();

    // 2. Load regular RSS news
    final urls = await _settingsRepository.getRssUrls();
    final items = await _rssService.fetchAllFeeds(urls);
    
    for (var item in items) {
      final model = ExploreItemModel(
        type: ExploreItemType.news,
        title: item.title ?? 'No Title',
        description: item.description ?? 'No description available',
        link: item.link,
      );
      
      _addSwipeItem(model);
    }
    
    if (_swipeItems.isNotEmpty) {
      _matchEngine = MatchEngine(swipeItems: _swipeItems);
    }
    
    setState(() => _isLoading = false);
  }

  void _addSwipeItem(ExploreItemModel model) {
    _swipeItems.add(SwipeItem(
      content: model,
      likeAction: () => _handleLike(model),
      nopeAction: () => _handleNope(model),
      superlikeAction: () => _handleLike(model),
    ));
  }

  Future<void> _checkTrackedTopics() async {
    final topics = await _trackingService.getTrackedTopics();
    final now = DateTime.now();
    final aiService = await AIServiceFactory.create();

    for (var topic in topics) {
      // Check if older than 24 hours
      if (now.difference(topic.lastCheckedAt).inHours >= 24) {
        if (aiService != null) {
          final searchResult = await _searchService.search(topic.title);
          final verifyContent = '标题：${topic.title}\n历史报告：${topic.initialFactReport}\n最新进展：$searchResult';
          
          final result = await aiService.factCheck(
            verifyContent, 
            searchContext: searchResult
          );
          
          // Insert a correction card if needed (here we always show it as an update)
          final model = ExploreItemModel(
            type: ExploreItemType.correction,
            title: '事件追踪更新: ${topic.title}',
            description: result,
          );
          
          // Add to the front of the deck
          _swipeItems.insert(0, SwipeItem(
            content: model,
            likeAction: () => _trackingService.updateTopicCheckTime(topic.title),
            nopeAction: () => _trackingService.updateTopicCheckTime(topic.title),
          ));
        }
      }
    }
  }

  Future<void> _handleLike(ExploreItemModel item) async {
    if (item.type == ExploreItemType.news) {
      // Create fact report card
      _generateFactReportCard(item);
    } else if (item.type == ExploreItemType.factReport) {
      // User believes the fact report -> Track it
      await _trackingService.trackTopic(item.title, item.description, item.description);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已相信并开启每日追踪核查')));
      }
    } else if (item.type == ExploreItemType.correction) {
      await _trackingService.updateTopicCheckTime(item.title.replaceAll('事件追踪更新: ', ''));
    }
  }

  Future<void> _handleNope(ExploreItemModel item) async {
    if (item.type == ExploreItemType.factReport) {
      // User disbelieves the fact report -> Still track it to prove/disprove later
      await _trackingService.trackTopic(item.title, item.description, item.description);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('不相信，系统将持续追踪核查该事件')));
      }
    } else if (item.type == ExploreItemType.correction) {
      await _trackingService.updateTopicCheckTime(item.title.replaceAll('事件追踪更新: ', ''));
    }
  }

  Future<void> _generateFactReportCard(ExploreItemModel item) async {
    final aiService = await AIServiceFactory.create();
    if (aiService == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未配置AI服务，无法进行事实核查。')),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('正在搜索与核查事实...')));
    }

    final searchResult = await _searchService.search(item.title);
    final contentToVerify = '${item.title}\n\n${item.description}';
    final result = await aiService.factCheck(contentToVerify, searchContext: searchResult);
    
    final factModel = ExploreItemModel(
      type: ExploreItemType.factReport,
      title: item.title,
      description: result,
      link: item.link,
    );

    // Add dynamically to the engine
    final newItem = SwipeItem(
      content: factModel,
      likeAction: () => _handleLike(factModel),
      nopeAction: () => _handleNope(factModel),
    );
    
    _swipeItems.insert(_matchEngine!.currentItemIndex + 1, newItem);
    setState(() {}); // refresh UI to show the card exists
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('探索 (AI 驱动)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
          )
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _matchEngine == null || _swipeItems.isEmpty
          ? const Center(child: Text('没有可用的新闻，请在设置中添加RSS源。'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SwipeCards(
                matchEngine: _matchEngine!,
                itemBuilder: (BuildContext context, int index) {
                  final item = _swipeItems[index].content as ExploreItemModel;
                  
                  Color cardColor = Colors.white;
                  String headerText = '新闻资讯';
                  IconData headerIcon = Icons.article;
                  
                  if (item.type == ExploreItemType.factReport) {
                    cardColor = Colors.blue.shade50;
                    headerText = 'AI 事实报告';
                    headerIcon = Icons.verified;
                  } else if (item.type == ExploreItemType.correction) {
                    cardColor = Colors.orange.shade50;
                    headerText = '事实追踪与纠正';
                    headerIcon = Icons.update;
                  }

                  return Card(
                    color: cardColor,
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(headerIcon, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(headerText, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item.title,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                item.description,
                                style: const TextStyle(fontSize: 16, height: 1.5),
                              ),
                            ),
                          ),
                          const Divider(),
                          if (item.type == ExploreItemType.news)
                            Text(
                              '向左滑忽略，向右滑喜欢(触发AI核查)',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              textAlign: TextAlign.center,
                            )
                          else if (item.type == ExploreItemType.factReport)
                            Text(
                              '向左滑不相信，向右滑相信 (均将加入每日追踪)',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              textAlign: TextAlign.center,
                            )
                          else 
                            Text(
                              '向左或向右滑动以继续',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              textAlign: TextAlign.center,
                            )
                        ],
                      ),
                    ),
                  );
                },
                onStackFinished: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已浏览完所有新闻！'))
                  );
                },
              ),
            ),
    );
  }
}
