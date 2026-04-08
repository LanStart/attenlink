import 'package:flutter/material.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsRepository _settingsRepository = SettingsRepository();
  List<String> _rssUrls = [];
  String _aiProvider = 'openai';
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();

  String _searchProvider = 'duckduckgo';
  final TextEditingController _searchApiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final urls = await _settingsRepository.getRssUrls();
    final aiConfig = await _settingsRepository.getAIConfig();
    final searchConfig = await _settingsRepository.getSearchConfig();
    setState(() {
      _rssUrls = urls;
      _aiProvider = aiConfig['provider'] ?? 'openai';
      _apiKeyController.text = aiConfig['api_key'] ?? '';
      _baseUrlController.text = aiConfig['base_url'] ?? '';
      _searchProvider = searchConfig['provider'] ?? 'duckduckgo';
      _searchApiKeyController.text = searchConfig['api_key'] ?? '';
    });
  }

  Future<void> _saveAIConfig() async {
    await _settingsRepository.saveAIConfig(
      _aiProvider,
      _apiKeyController.text,
      _baseUrlController.text,
    );
    await _settingsRepository.saveSearchConfig(
      _searchProvider,
      _searchApiKeyController.text,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('配置已保存')),
      );
    }
  }

  void _addRssUrl(String url) async {
    if (url.isNotEmpty && !_rssUrls.contains(url)) {
      setState(() {
        _rssUrls.add(url);
      });
      await _settingsRepository.saveRssUrls(_rssUrls);
    }
  }

  void _removeRssUrl(String url) async {
    setState(() {
      _rssUrls.remove(url);
    });
    await _settingsRepository.saveRssUrls(_rssUrls);
  }

  void _showAddRssDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加RSS源'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'https://example.com/rss'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                _addRssUrl(controller.text);
                Navigator.pop(context);
              },
              child: const Text('添加'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('RSS 源管理', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._rssUrls.map((url) => ListTile(
            title: Text(url),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeRssUrl(url),
            ),
          )),
          ElevatedButton.icon(
            onPressed: _showAddRssDialog,
            icon: const Icon(Icons.add),
            label: const Text('添加RSS源'),
          ),
          const Divider(height: 32),
          const Text('AI 服务配置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _aiProvider,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
              DropdownMenuItem(value: 'claude', child: Text('Anthropic Claude')),
              DropdownMenuItem(value: 'gemini', child: Text('Google Gemini')),
              DropdownMenuItem(value: 'glm', child: Text('Zhipu GLM')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _aiProvider = val);
              }
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              labelText: 'API Key',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _baseUrlController,
            decoration: const InputDecoration(
              labelText: 'Base URL (可选, 代理用)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 32),
          const Text('搜索引擎配置 (MCP)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _searchProvider,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'duckduckgo', child: Text('DuckDuckGo (无需Key)')),
              DropdownMenuItem(value: 'bing', child: Text('Microsoft Bing')),
              DropdownMenuItem(value: 'google', child: Text('Google Search')),
              DropdownMenuItem(value: 'baidu', child: Text('Baidu')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _searchProvider = val);
              }
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchApiKeyController,
            decoration: const InputDecoration(
              labelText: 'Search API Key (可选)',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveAIConfig,
            child: const Text('保存所有配置'),
          ),
        ],
      ),
    );
  }
}
