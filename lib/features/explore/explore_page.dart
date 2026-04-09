import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/extensions/context_extensions.dart';

/// Explore Page - The core immersive news card swiping experience
class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  // Demo data for UI development
  final List<_DemoArticle> _demoArticles = [
    _DemoArticle(
      title: 'AI治理框架全球峰会达成共识',
      summary: '来自32个国家的代表在日内瓦就AI安全治理框架达成历史性协议，强调AI系统透明度和可解释性。',
      source: '新华社',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800',
      tags: ['AI', '治理', '国际'],
    ),
    _DemoArticle(
      title: '量子计算突破：新型量子纠错码将错误率降至0.1%',
      summary: 'MIT研究团队发布最新量子纠错研究成果，将量子计算错误率降至前所未有的0.1%，为实用量子计算铺平道路。',
      source: 'Nature',
      time: DateTime.now().subtract(const Duration(hours: 4)),
      imageUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=800',
      tags: ['量子计算', '科研', 'MIT'],
    ),
    _DemoArticle(
      title: '全球半导体产业链重构：台积电宣布欧洲建厂计划',
      summary: '台积电确认将在德国德累斯顿投资建设先进制程晶圆厂，预计2027年投产，这将是欧洲最先进的芯片制造基地。',
      source: 'Reuters',
      time: DateTime.now().subtract(const Duration(hours: 6)),
      imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800',
      tags: ['半导体', '台积电', '欧洲'],
    ),
    _DemoArticle(
      title: '气候变化：北极冰层面积降至历史新低',
      summary: 'NASA最新卫星数据显示，北极海冰面积已降至有记录以来的最低水平，科学家警告这可能加速全球气候系统的不可逆变化。',
      source: 'NASA',
      time: DateTime.now().subtract(const Duration(hours: 8)),
      imageUrl: 'https://images.unsplash.com/photo-1580193769210-b8d1c049a7d9?w=800',
      tags: ['气候', '环境', 'NASA'],
    ),
    _DemoArticle(
      title: '新型mRNA疫苗平台可同时对抗多种呼吸道病毒',
      summary: '宾夕法尼亚大学研究团队开发的下一代mRNA疫苗平台在临床试验中展现出同时对流感、RSV和新冠的防护效果。',
      source: 'Science',
      time: DateTime.now().subtract(const Duration(hours: 10)),
      imageUrl: 'https://images.unsplash.com/photo-1584036561566-baf8f5f1b144?w=800',
      tags: ['医疗', '疫苗', 'mRNA'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _buildTopBar(),
            // Card stack
            Expanded(child: _buildCardStack()),
            // Bottom action hints
            _buildActionHints(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Text(
            '探索',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // Verification status filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user,
                  size: 16,
                  color: context.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  '事实优先',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack() {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: _demoArticles.length,
      onPageChanged: (index) {
        setState(() => _currentPage = index);
      },
      itemBuilder: (context, index) {
        return _NewsCard(
          article: _demoArticles[index],
          onLike: () => _handleLike(index),
          onDislike: () => _handleDislike(index),
        );
      },
    );
  }

  Widget _buildActionHints() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionHint(
            icon: Icons.close,
            label: '不感兴趣',
            color: context.colorScheme.error,
            onTap: () => _handleDislike(_currentPage),
          ),
          _ActionHint(
            icon: Icons.bookmark_border,
            label: '稍后阅读',
            color: context.colorScheme.tertiary,
            onTap: () {
              context.showSnackBar('已添加到稍后阅读');
            },
          ),
          _ActionHint(
            icon: Icons.favorite,
            label: '喜欢并查证',
            color: context.colorScheme.primary,
            onTap: () => _handleLike(_currentPage),
          ),
        ],
      ),
    );
  }

  void _handleLike(int index) {
    context.showSnackBar('已喜欢，正在启动AI查证...');
    // TODO: Trigger verification engine
  }

  void _handleDislike(int index) {
    context.showSnackBar('已标记不感兴趣');
    // TODO: Update weight algorithm
    if (_currentPage < _demoArticles.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }
}

/// Full-screen news card with swipe interaction
class _NewsCard extends StatefulWidget {
  final _DemoArticle article;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const _NewsCard({
    required this.article,
    required this.onLike,
    required this.onDislike,
  });

  @override
  State<_NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<_NewsCard> with SingleTickerProviderStateMixin {
  double _swipeOffset = 0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _swipeOffset += details.delta.dx;
            _isDragging = true;
          });
        },
        onHorizontalDragEnd: (details) {
          final threshold = context.screenWidth * 0.35;
          if (_swipeOffset > threshold) {
            widget.onLike();
          } else if (_swipeOffset < -threshold) {
            widget.onDislike();
          }
          setState(() {
            _swipeOffset = 0;
            _isDragging = false;
          });
        },
        child: AnimatedContainer(
          duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(_swipeOffset, 0, 0)
            ..rotateZ(_swipeOffset * 0.0003),
          curve: Curves.easeOutCubic,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                _buildBackgroundImage(),
                // Gradient overlay
                _buildGradientOverlay(),
                // Swipe indicator overlays
                if (_swipeOffset.abs() > 20) _buildSwipeIndicator(),
                // Content
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: widget.article.imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: widget.article.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: context.colorScheme.surfaceContainerHighest,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: context.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.article,
                  size: 64,
                  color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                ),
              ),
            )
          : Container(
              color: context.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.article,
                size: 64,
                color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
            ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.1),
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.8),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeIndicator() {
    final isLike = _swipeOffset > 0;
    final opacity = (_swipeOffset.abs() / (context.screenWidth * 0.35)).clamp(0.0, 1.0);

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: isLike
              ? Colors.green.withValues(alpha: opacity * 0.3)
              : Colors.red.withValues(alpha: opacity * 0.3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLike ? Icons.favorite : Icons.close,
                size: 64,
                color: isLike
                    ? Colors.green.withValues(alpha: opacity)
                    : Colors.red.withValues(alpha: opacity),
              ),
              const SizedBox(height: 8),
              Text(
                isLike ? '喜欢' : '不感兴趣',
                style: TextStyle(
                  color: isLike
                      ? Colors.green.withValues(alpha: opacity)
                      : Colors.red.withValues(alpha: opacity),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final article = widget.article;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: article.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              article.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            // Summary
            Text(
              article.summary,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            // Source & time
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    article.source,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatTimeAgo(article.time),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                // Verification badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: Colors.orange.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '待查证',
                        style: TextStyle(
                          color: Colors.orange.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}

/// Action hint button at bottom
class _ActionHint extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionHint({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Demo article for UI development
class _DemoArticle {
  final String title;
  final String summary;
  final String source;
  final DateTime time;
  final String imageUrl;
  final List<String> tags;

  const _DemoArticle({
    required this.title,
    required this.summary,
    required this.source,
    required this.time,
    this.imageUrl = '',
    this.tags = const [],
  });
}
