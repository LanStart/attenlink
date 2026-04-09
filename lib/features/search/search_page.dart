import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions/context_extensions.dart';

/// Search Page - Keyword search + article feed
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  bool _isSemanticSearch = false;
  String _searchQuery = '';

  // Demo data for UI
  final List<_DemoArticle> _demoArticles = [
    _DemoArticle(
      title: 'GPT-5发布：推理能力大幅提升',
      summary: 'OpenAI正式发布GPT-5模型，在复杂推理、数学和编程任务上展现出显著进步，同时引入了新的安全机制。',
      source: 'TechCrunch',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      category: 'AI',
    ),
    _DemoArticle(
      title: 'SpaceX星舰第七次试飞成功回收',
      summary: 'SpaceX星舰在第七次试飞中成功完成超重型助推器回收，标志着可重复使用火箭技术取得重大突破。',
      source: 'Space News',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      category: '航天',
    ),
    _DemoArticle(
      title: '全球首款2nm芯片量产：台积电领先三星',
      summary: '台积电宣布2nm制程芯片进入量产阶段，预计将用于下一代iPhone和AI加速器，性能提升30%同时功耗降低25%。',
      source: 'Reuters',
      time: DateTime.now().subtract(const Duration(hours: 5)),
      category: '半导体',
    ),
    _DemoArticle(
      title: 'WHO宣布猴痘疫情不再构成国际关注的突发公共卫生事件',
      summary: '世界卫生组织宣布，鉴于全球猴痘病例数持续下降，不再将其列为国际关注的突发公共卫生事件。',
      source: 'WHO',
      time: DateTime.now().subtract(const Duration(hours: 7)),
      category: '医疗',
    ),
    _DemoArticle(
      title: '欧盟通过全球首部全面AI监管法案',
      summary: '欧洲议会以压倒性多数通过《人工智能法案》，对高风险AI应用实施严格监管，违规企业最高罚款年营收6%。',
      source: 'BBC',
      time: DateTime.now().subtract(const Duration(hours: 9)),
      category: '政策',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Title bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Text(
                      '搜索',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    // Semantic search toggle
                    _SemanticSearchToggle(
                      isEnabled: _isSemanticSearch,
                      onToggle: (value) {
                        setState(() => _isSemanticSearch = value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: SearchBar(
                  controller: _searchController,
                  hintText: _isSemanticSearch ? '语义搜索：描述你想找的内容...' : '搜索关键词...',
                  hintStyle: WidgetStateProperty.all(
                    TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontFamily: 'NotoSansSC',
                    ),
                  ),
                  leading: Icon(
                    Icons.search,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  trailing: _searchQuery.isNotEmpty
                      ? [
                          IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          ),
                        ]
                      : null,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  elevation: WidgetStateProperty.all(0),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ),

            // Filter chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(label: '全部', isSelected: true, onSelected: () {}),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'AI', isSelected: false, onSelected: () {}),
                      const SizedBox(width: 8),
                      _FilterChip(label: '科技', isSelected: false, onSelected: () {}),
                      const SizedBox(width: 8),
                      _FilterChip(label: '医疗', isSelected: false, onSelected: () {}),
                      const SizedBox(width: 8),
                      _FilterChip(label: '已查证', isSelected: false, onSelected: () {}),
                      const SizedBox(width: 8),
                      _FilterChip(label: '待查证', isSelected: false, onSelected: () {}),
                    ],
                  ),
                ),
              ),
            ),

            // Article list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final article = _demoArticles[index];
                  return _ArticleListItem(article: article);
                },
                childCount: _demoArticles.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Semantic search toggle
class _SemanticSearchToggle extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const _SemanticSearchToggle({
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return InkWell(
      onTap: () => onToggle(!isEnabled),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isEnabled
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 16,
              color: isEnabled
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '语义搜索',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'NotoSansSC',
                color: isEnabled
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter chip
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        fontFamily: 'NotoSansSC',
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected
            ? colorScheme.onSecondaryContainer
            : colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Article list item
class _ArticleListItem extends StatelessWidget {
  final _DemoArticle article;

  const _ArticleListItem({required this.article});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to article detail
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source & category
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            article.source,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          article.category,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        // Verification badge
                        Icon(
                          Icons.verified_user,
                          size: 14,
                          color: Colors.orange.shade700,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      article.title,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Summary
                    Text(
                      article.summary,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Time
                    Text(
                      _formatTimeAgo(article.time),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.article,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
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

/// Demo article
class _DemoArticle {
  final String title;
  final String summary;
  final String source;
  final DateTime time;
  final String category;

  const _DemoArticle({
    required this.title,
    required this.summary,
    required this.source,
    required this.time,
    this.category = '',
  });
}
