import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions/context_extensions.dart';

/// AI Provider Configuration Page
class AiProviderPage extends ConsumerStatefulWidget {
  const AiProviderPage({super.key});

  @override
  ConsumerState<AiProviderPage> createState() => _AiProviderPageState();
}

class _AiProviderPageState extends ConsumerState<AiProviderPage> {
  // Demo providers
  final List<_ProviderConfig> _providers = [
    _ProviderConfig(
      id: 'openai',
      name: 'OpenAI',
      description: 'GPT-4o, GPT-4o-mini, o1, o3',
      icon: Icons.smart_toy,
      color: Colors.green,
      models: ['gpt-4o', 'gpt-4o-mini', 'o1', 'o3-mini'],
      defaultModel: 'gpt-4o',
      defaultBaseUrl: 'https://api.openai.com/v1',
      isConnected: true,
      apiKey: 'sk-****...****',
      supportsVision: true,
      supportsToolUse: true,
    ),
    _ProviderConfig(
      id: 'claude',
      name: 'Claude',
      description: 'Claude 3.5 Sonnet, Claude 3 Opus',
      icon: Icons.psychology,
      color: Colors.orange,
      models: ['claude-3-5-sonnet-20241022', 'claude-3-opus-20240229'],
      defaultModel: 'claude-3-5-sonnet-20241022',
      defaultBaseUrl: 'https://api.anthropic.com/v1',
      isConnected: false,
      apiKey: '',
      supportsVision: true,
      supportsToolUse: true,
    ),
    _ProviderConfig(
      id: 'gemini',
      name: 'Gemini',
      description: 'Gemini 2.0 Flash, Gemini 1.5 Pro',
      icon: Icons.auto_awesome,
      color: Colors.blue,
      models: ['gemini-2.0-flash', 'gemini-1.5-pro'],
      defaultModel: 'gemini-2.0-flash',
      defaultBaseUrl: 'https://generativelanguage.googleapis.com/v1beta',
      isConnected: false,
      apiKey: '',
      supportsVision: true,
      supportsToolUse: true,
    ),
    _ProviderConfig(
      id: 'kimi',
      name: 'Kimi',
      description: 'Moonshot-v1, 长文本处理专家',
      icon: Icons.nightlight,
      color: Colors.purple,
      models: ['moonshot-v1-8k', 'moonshot-v1-32k', 'moonshot-v1-128k'],
      defaultModel: 'moonshot-v1-8k',
      defaultBaseUrl: 'https://api.moonshot.cn/v1',
      isConnected: false,
      apiKey: '',
      supportsVision: false,
      supportsToolUse: false,
    ),
    _ProviderConfig(
      id: 'glm',
      name: 'GLM',
      description: 'GLM-4, GLM-4V, 智谱AI',
      icon: Icons.hub,
      color: Colors.teal,
      models: ['glm-4', 'glm-4v', 'glm-4-flash'],
      defaultModel: 'glm-4',
      defaultBaseUrl: 'https://open.bigmodel.cn/api/paas/v4',
      isConnected: false,
      apiKey: '',
      supportsVision: true,
      supportsToolUse: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 服务配置'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _providers.length,
        itemBuilder: (context, index) {
          return _ProviderCard(
            provider: _providers[index],
            onConfigure: () => _showConfigDialog(_providers[index]),
            onToggle: (value) {
              setState(() {
                _providers[index] = _providers[index].copyWith(isConnected: value);
              });
            },
          );
        },
      ),
    );
  }

  void _showConfigDialog(_ProviderConfig provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ProviderConfigSheet(provider: provider),
    );
  }
}

/// Provider card
class _ProviderCard extends StatelessWidget {
  final _ProviderConfig provider;
  final VoidCallback onConfigure;
  final ValueChanged<bool> onToggle;

  const _ProviderCard({
    required this.provider,
    required this.onConfigure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onConfigure,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: provider.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  provider.icon,
                  color: provider.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          provider.name,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Connection status
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: provider.isConnected
                                ? Colors.green
                                : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.description,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Capability badges
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (provider.supportsVision)
                          _CapabilityBadge(
                            icon: Icons.visibility,
                            label: '图像识别',
                            color: colorScheme.tertiary,
                          ),
                        if (provider.supportsToolUse)
                          _CapabilityBadge(
                            icon: Icons.build,
                            label: '工具调用',
                            color: colorScheme.primary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Configure button
              FilledButton.tonal(
                onPressed: onConfigure,
                child: Text(
                  provider.isConnected ? '已配置' : '配置',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Capability badge
class _CapabilityBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CapabilityBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Provider configuration sheet
class _ProviderConfigSheet extends StatefulWidget {
  final _ProviderConfig provider;

  const _ProviderConfigSheet({required this.provider});

  @override
  State<_ProviderConfigSheet> createState() => _ProviderConfigSheetState();
}

class _ProviderConfigSheetState extends State<_ProviderConfigSheet> {
  late TextEditingController _apiKeyController;
  late TextEditingController _baseUrlController;
  late String _selectedModel;
  late double _temperature;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: widget.provider.apiKey);
    _baseUrlController = TextEditingController(text: widget.provider.defaultBaseUrl);
    _selectedModel = widget.provider.defaultModel;
    _temperature = 0.7;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
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
      child: SingleChildScrollView(
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
            // Provider header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.provider.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.provider.icon,
                    color: widget.provider.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '配置 ${widget.provider.name}',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // API Key
            TextField(
              controller: _apiKeyController,
              obscureText: _obscureApiKey,
              decoration: InputDecoration(
                hintText: '输入 API Key',
                prefixIcon: const Icon(Icons.key),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscureApiKey = !_obscureApiKey);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Base URL
            TextField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                hintText: 'API Base URL',
                prefixIcon: Icon(Icons.dns),
              ),
            ),
            const SizedBox(height: 16),
            // Model selection
            Text(
              '选择模型',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.provider.models.map((model) {
                return ChoiceChip(
                  label: Text(model),
                  selected: _selectedModel == model,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedModel = model);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Temperature slider
            Row(
              children: [
                Text(
                  'Temperature',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  _temperature.toStringAsFixed(1),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Slider.adaptive(
              value: _temperature,
              min: 0.0,
              max: 2.0,
              divisions: 20,
              onChanged: (value) {
                setState(() => _temperature = value);
              },
            ),
            const SizedBox(height: 20),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _testConnection,
                    child: const Text('测试连接'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saveConfig,
                    child: const Text('保存配置'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _testConnection() {
    context.showSnackBar('正在测试 ${widget.provider.name} 连接...');
  }

  void _saveConfig() {
    if (_apiKeyController.text.isEmpty) {
      context.showSnackBar('请输入 API Key');
      return;
    }
    Navigator.pop(context);
    context.showSnackBar('${widget.provider.name} 配置已保存');
  }
}

/// Provider config
class _ProviderConfig {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> models;
  final String defaultModel;
  final String defaultBaseUrl;
  final bool isConnected;
  final String apiKey;
  final bool supportsVision;
  final bool supportsToolUse;

  const _ProviderConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.models,
    required this.defaultModel,
    required this.defaultBaseUrl,
    required this.isConnected,
    required this.apiKey,
    required this.supportsVision,
    required this.supportsToolUse,
  });

  _ProviderConfig copyWith({
    bool? isConnected,
    String? apiKey,
  }) {
    return _ProviderConfig(
      id: id,
      name: name,
      description: description,
      icon: icon,
      color: color,
      models: models,
      defaultModel: defaultModel,
      defaultBaseUrl: defaultBaseUrl,
      isConnected: isConnected ?? this.isConnected,
      apiKey: apiKey ?? this.apiKey,
      supportsVision: supportsVision,
      supportsToolUse: supportsToolUse,
    );
  }
}
