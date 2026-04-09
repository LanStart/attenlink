import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/news_article.dart';
import '../../data/datasources/remote/feed_parallel_fetcher.dart';
import 'widgets/immersive_news_card.dart';
import 'widgets/ai_summary_panel.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final PageController _pageController = PageController();
  List<NewsArticle> _articles = [];
  bool _isLoading = true;
  double _swipeOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _loadInitialFeeds();
  }

  Future<void> _loadInitialFeeds() async {
    final fetcher = FeedParallelFetcher();
    final bootstrap = FeedParallelFetcher.getBootstrapSources();
    final results = await fetcher.fetchAll(bootstrap);
    
    if (mounted) {
      setState(() {
        _articles = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _articles.length,
        onPageChanged: (index) {
          // Trigger any analytics or preloading here
        },
        itemBuilder: (context, index) {
          final article = _articles[index];
          return GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _swipeOffset = details.localPosition.dx / MediaQuery.of(context).size.width;
              });
            },
            onHorizontalDragEnd: (details) {
              if (_swipeOffset.abs() > 0.4) {
                _handleSwipeAction(article, _swipeOffset > 0);
              }
              setState(() {
                _swipeOffset = 0.0;
              });
            },
            onVerticalDragUpdate: (details) {
              if (details.delta.dy < -10) {
                _showSummaryPanel(context, article);
              }
            },
            child: ImmersiveNewsCard(
              article: article,
              swipeOffset: _swipeOffset,
            ),
          );
        },
      ),
    );
  }

  void _handleSwipeAction(NewsArticle article, bool liked) {
    final snackBar = SnackBar(
      content: Text(liked ? '已收藏并启动 AI 事实查证' : '已减少此类内容推荐'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    
    if (liked) {
      // Logic to trigger Verification Sub-agent would go here
    }
  }

  void _showSummaryPanel(BuildContext context, NewsArticle article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: const AiSummaryPanel(),
      ),
    );
  }
}
