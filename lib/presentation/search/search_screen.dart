import 'package:flutter/material.dart';
import 'package:webfeed_revised/domain/rss_item.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/rss_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final RssService _rssService = RssService();
  final SettingsRepository _settingsRepository = SettingsRepository();
  
  List<RssItem> _allItems = [];
  List<RssItem> _filteredItems = [];
  bool _isLoading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadFeeds();
  }

  Future<void> _loadFeeds() async {
    setState(() => _isLoading = true);
    final urls = await _settingsRepository.getRssUrls();
    final items = await _rssService.fetchAllFeeds(urls);
    setState(() {
      _allItems = items;
      _filteredItems = items;
      _isLoading = false;
    });
  }

  void _filterItems(String query) {
    setState(() {
      _query = query.toLowerCase();
      _filteredItems = _allItems.where((item) {
        final title = item.title?.toLowerCase() ?? '';
        final desc = item.description?.toLowerCase() ?? '';
        return title.contains(_query) || desc.contains(_query);
      }).toList();
    });
  }

  void _openArticle(String? link) async {
    if (link != null && await canLaunchUrl(Uri.parse(link))) {
      await launchUrl(Uri.parse(link));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: '搜索文章关键词...',
            border: InputBorder.none,
          ),
          onChanged: _filterItems,
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return ListTile(
                title: Text(item.title ?? 'No Title'),
                subtitle: Text(item.pubDate?.toString() ?? ''),
                onTap: () => _openArticle(item.link),
              );
            },
          ),
    );
  }
}
