import 'package:flutter/material.dart';
import '../../data/models/news_article.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _isSemantic = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: _isSemantic ? '语义搜索 (AI 驱动)' : '搜索关键词...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: Icon(_isSemantic ? Icons.auto_awesome : Icons.short_text),
              onPressed: () => setState(() => _isSemantic = !_isSemantic),
              tooltip: '切换语义搜索',
            ),
            border: InputBorder.none,
            filled: false,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(label: const Text('全部'), selected: true, onSelected: (_) {}),
                const SizedBox(width: 8),
                FilterChip(label: const Text('科技'), onSelected: (_) {}),
                const SizedBox(width: 8),
                FilterChip(label: const Text('财经'), onSelected: (_) {}),
                const SizedBox(width: 8),
                FilterChip(label: const Text('已查证'), onSelected: (_) {}),
              ],
            ),
          ),
          
          // Result List
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                return _buildCompactArticleCard(theme, colorScheme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactArticleCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '探索 AI 在跨平台开发中的深度集成',
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('TechCrunch', style: theme.textTheme.labelSmall),
                      const SizedBox(width: 8),
                      Text('2小时前', style: theme.textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: colorScheme.surfaceContainerHighest,
              ),
              child: const Icon(Icons.image_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
