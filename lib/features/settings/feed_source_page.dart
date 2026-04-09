import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions/context_extensions.dart';

/// Feed Source Management Page
class FeedSourcePage extends ConsumerStatefulWidget {
  const FeedSourcePage({super.key});

  @override
  ConsumerState<FeedSourcePage> createState() => _FeedSourcePageState();
}

class _FeedSourcePageState extends ConsumerState<FeedSourcePage> {
  // Demo feed sources
  final List<_FeedSourceItem> _sources = [
    _FeedSourceItem(
      name: 'Hacker News',
      url: 'https://hnrss.org/frontpage',
      type: _FeedType.rss,
      isEnabled: true,
      lastFetched: DateTime.now().subtract(const Duration(minutes: 15)),
      articleCount: 156,
    ),
    _FeedSourceItem(
      name: 'TechCrunch',
      url: 'https://techcrunch.com/feed/',
      type: _FeedType.rss,
      isEnabled: true,
      lastFetched: DateTime.now().subtract(const Duration(hours: 1)),
      articleCount: 89,
    ),
    _FeedSourceItem(
      name: 'The Verge',
      url: 'https://www.theverge.com/rss/index.xml',
      type: _FeedType.atom,
      isEnabled: true,
      lastFetched: DateTime.now().subtract(const Duration(hours: 2)),
      articleCount: 67,
    ),
    _FeedSourceItem(
      name: 'Reddit - r/technology',
      url: 'https://www.reddit.com/r/technology/.json',
      type: _FeedType.reddit,
      isEnabled: false,
      lastFetched: DateTime.now().subtract(const Duration(days: 1)),
      articleCount: 234,
    ),
    _FeedSourceItem(
      name: 'Hacker News API',
      url: 'https://hacker-news.firebaseio.com/v0/',
      type: _FeedType.hackerNews,
      isEnabled: true,
      lastFetched: DateTime.now().subtract(const Duration(minutes: 30)),
      articleCount: 312,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('资讯源管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '添加资讯源',
            onPressed: _showAddSourceDialog,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _sources.length,
        itemBuilder: (context, index) {
          final source = _sources[index];
          return _FeedSourceCard(
            source: source,
            onToggle: (value) {
              setState(() {
                _sources[index] = source.copyWith(isEnabled: value);
              });
            },
            onDelete: () {
              setState(() {
                _sources.removeAt(index);
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSourceDialog,
        icon: const Icon(Icons.add),
        label: const Text('添加资讯源'),
      ),
    );
  }

  void _showAddSourceDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddSourceSheet(),
    );
  }
}

/// Feed source card
class _FeedSourceCard extends StatelessWidget {
  final _FeedSourceItem source;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _FeedSourceCard({
    required this.source,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Type icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTypeColor().withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(),
                    color: _getTypeColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Name & URL
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.name,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        source.url,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Toggle
                Switch.adaptive(
                  value: source.isEnabled,
                  onChanged: onToggle,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Info row
            Row(
              children: [
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    source.type.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Article count
                Text(
                  '${source.articleCount} 篇文章',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                // Last fetched
                Text(
                  '上次更新: ${_formatTimeAgo(source.lastFetched)}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(8),
                  child: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (source.type) {
      case _FeedType.rss:
        return Icons.rss_feed;
      case _FeedType.atom:
        return Icons.rss_feed;
      case _FeedType.jsonFeed:
        return Icons.data_object;
      case _FeedType.hackerNews:
        return Icons.code;
      case _FeedType.reddit:
        return Icons.forum;
      case _FeedType.custom:
        return Icons.api;
    }
  }

  Color _getTypeColor() {
    switch (source.type) {
      case _FeedType.rss:
        return Colors.orange;
      case _FeedType.atom:
        return Colors.blue;
      case _FeedType.jsonFeed:
        return Colors.green;
      case _FeedType.hackerNews:
        return Colors.amber;
      case _FeedType.reddit:
        return Colors.deepOrange;
      case _FeedType.custom:
        return Colors.purple;
    }
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}

/// Add source bottom sheet
class _AddSourceSheet extends StatefulWidget {
  const _AddSourceSheet();

  @override
  State<_AddSourceSheet> createState() => _AddSourceSheetState();
}

class _AddSourceSheetState extends State<_AddSourceSheet> {
  final _urlController = TextEditingController();
  final _nameController = TextEditingController();
  _FeedType _selectedType = _FeedType.rss;
  bool _isTesting = false;

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '添加资讯源',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          // URL input
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              hintText: '输入 RSS/Atom/JSON Feed URL',
              prefixIcon: Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 12),
          // Name input
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: '名称（可选，自动识别）',
              prefixIcon: Icon(Icons.label),
            ),
          ),
          const SizedBox(height: 16),
          // Type selection
          Text(
            '源类型',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _FeedType.values.map((type) {
              return ChoiceChip(
                label: Text(type.label),
                selected: _selectedType == type,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedType = type);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isTesting ? null : _testConnection,
                  child: _isTesting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('测试连接'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _addSource,
                  child: const Text('添加'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _testConnection() {
    setState(() => _isTesting = true);
    // Simulate testing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isTesting = false);
        context.showSnackBar('连接测试成功！');
      }
    });
  }

  void _addSource() {
    if (_urlController.text.isEmpty) {
      context.showSnackBar('请输入URL');
      return;
    }
    Navigator.pop(context);
    context.showSnackBar('资讯源已添加');
  }
}

/// Feed type enum
enum _FeedType {
  rss('RSS'),
  atom('Atom'),
  jsonFeed('JSON Feed'),
  hackerNews('HackerNews'),
  reddit('Reddit'),
  custom('自定义');

  final String label;
  const _FeedType(this.label);
}

/// Feed source item
class _FeedSourceItem {
  final String name;
  final String url;
  final _FeedType type;
  final bool isEnabled;
  final DateTime lastFetched;
  final int articleCount;

  const _FeedSourceItem({
    required this.name,
    required this.url,
    required this.type,
    required this.isEnabled,
    required this.lastFetched,
    required this.articleCount,
  });

  _FeedSourceItem copyWith({
    String? name,
    String? url,
    _FeedType? type,
    bool? isEnabled,
    DateTime? lastFetched,
    int? articleCount,
  }) {
    return _FeedSourceItem(
      name: name ?? this.name,
      url: url ?? this.url,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      lastFetched: lastFetched ?? this.lastFetched,
      articleCount: articleCount ?? this.articleCount,
    );
  }
}
