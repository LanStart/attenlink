import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:webfeed_revised/domain/rss_item.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/rss_service.dart';
import '../../data/services/ai_service_factory.dart';
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

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoading = true);
    final urls = await _settingsRepository.getRssUrls();
    final items = await _rssService.fetchAllFeeds(urls);
    
    _swipeItems.clear();
    for (var item in items) {
      _swipeItems.add(SwipeItem(
        content: item,
        likeAction: () => _handleLike(item),
        nopeAction: () => _handleNope(item),
        superlikeAction: () => _handleLike(item),
      ));
    }
    
    if (_swipeItems.isNotEmpty) {
      _matchEngine = MatchEngine(swipeItems: _swipeItems);
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _handleLike(RssItem item) async {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已喜欢: ${item.title}，正在核查事实...')));
    _verifyFact(item);
  }

  Future<void> _handleNope(RssItem item) async {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已忽略: ${item.title}')));
  }

  Future<void> _verifyFact(RssItem item) async {
    final aiService = await AIServiceFactory.create();
    if (aiService == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未配置AI服务，无法进行事实核查。请前往设置页面配置。')),
        );
      }
      return;
    }

    final contentToVerify = '${item.title}\n\n${item.description}';
    final result = await aiService.factCheck(contentToVerify);
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('事实核查: ${item.title}'),
          content: SingleChildScrollView(child: Text(result)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
            TextButton(
              onPressed: () {
                if (item.link != null) {
                  launchUrl(Uri.parse(item.link!));
                }
              },
              child: const Text('阅读原文'),
            ),
          ],
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('探索 (AI 驱动)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNews,
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
                  final item = _swipeItems[index].content as RssItem;
                  return Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title ?? 'No Title',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                item.description ?? 'No description available',
                                style: const TextStyle(fontSize: 16, height: 1.5),
                              ),
                            ),
                          ),
                          const Divider(),
                          Text(
                            '向左滑忽略，向右滑喜欢(自动核查)',
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
