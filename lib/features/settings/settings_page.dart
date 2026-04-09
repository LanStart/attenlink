import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/extensions/context_extensions.dart';
import 'feed_source_page.dart';
import 'ai_provider_page.dart';

/// Settings Page - Feed source management + AI provider configuration
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Text(
                  '设置',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // User stats card
            SliverToBoxAdapter(
              child: _UserStatsCard(),
            ),

            // Feed sources section
            SliverToBoxAdapter(
              child: _SectionHeader(
                icon: Icons.rss_feed,
                title: '资讯源管理',
                subtitle: '添加和管理你的新闻来源',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FeedSourcePage(),
                    ),
                  );
                },
              ),
            ),

            // AI providers section
            SliverToBoxAdapter(
              child: _SectionHeader(
                icon: Icons.smart_toy,
                title: 'AI 服务配置',
                subtitle: '配置AI服务商和API密钥',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AiProviderPage(),
                    ),
                  );
                },
              ),
            ),

            // Connected AI providers preview
            SliverToBoxAdapter(
              child: _AiProviderPreview(),
            ),

            // General settings
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  '通用设置',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: _SettingsSection(
                children: [
                  _SettingsTile(
                    icon: Icons.dark_mode,
                    title: '深色模式',
                    subtitle: '跟随系统设置',
                    trailing: Switch.adaptive(
                      value: true,
                      onChanged: (value) {
                        // TODO: Theme toggle
                      },
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: '推送通知',
                    subtitle: '查证结果和重要新闻提醒',
                    trailing: Switch.adaptive(
                      value: true,
                      onChanged: (value) {
                        // TODO: Notification toggle
                      },
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.translate,
                    title: '语言',
                    subtitle: '简体中文',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Language settings
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.auto_delete,
                    title: '缓存管理',
                    subtitle: '清除本地缓存数据',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Cache management
                    },
                  ),
                ],
              ),
            ),

            // About section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text(
                  '关于',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: _SettingsSection(
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: '关于 AttenLink',
                    subtitle: 'v1.0.0 · 专注事实的AI资讯聚合',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'AttenLink',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '专注事实的AI资讯聚合工具',
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.source,
                    title: '开源许可',
                    subtitle: '查看第三方开源库',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'AttenLink',
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }
}

/// User stats card
class _UserStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Card(
        color: colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: colorScheme.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AttenLink 用户',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatItem(label: '阅读', value: '128'),
                        const SizedBox(width: 24),
                        _StatItem(label: '已查证', value: '45'),
                        const SizedBox(width: 24),
                        _StatItem(label: '订阅源', value: '5'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stat item
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

/// Section header with navigation
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// AI provider preview cards
class _AiProviderPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final providers = [
      _ProviderInfo('OpenAI', 'GPT-4o', true, Colors.green),
      _ProviderInfo('Claude', 'Claude 3.5', false, Colors.orange),
      _ProviderInfo('Gemini', 'Gemini Pro', false, Colors.blue),
      _ProviderInfo('Kimi', 'Moonshot', false, Colors.purple),
      _ProviderInfo('GLM', 'GLM-4', false, Colors.teal),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI 服务商',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: providers.map((provider) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: provider.isConnected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: provider.isConnected
                        ? colorScheme.primary.withValues(alpha: 0.3)
                        : colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: provider.isConnected
                            ? provider.statusColor
                            : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'NotoSansSC',
                        color: provider.isConnected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (provider.isConnected) ...[
                      const SizedBox(width: 6),
                      Text(
                        provider.model,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Provider info
class _ProviderInfo {
  final String name;
  final String model;
  final bool isConnected;
  final Color statusColor;

  const _ProviderInfo(this.name, this.model, this.isConnected, this.statusColor);
}

/// Settings section
class _SettingsSection extends StatelessWidget {
  final List<Widget> children;

  const _SettingsSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Card(
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

/// Settings tile
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
