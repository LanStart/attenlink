import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('设置'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // User Stats Header
                  _buildUserHeader(theme, colorScheme),
                  const SizedBox(height: 24),

                  // Feed Source Management
                  _buildSectionHeader('资讯源管理', theme),
                  _buildSettingTile(Icons.rss_feed, 'RSS/Atom 管理', '添加或删除您的资讯订阅', theme),
                  _buildSettingTile(Icons.category, '抓取偏好', '按主题和来源调整抓取频率', theme),
                  
                  const SizedBox(height: 24),
                  
                  // AI Provider Config
                  _buildSectionHeader('AI 查证中枢', theme),
                  _buildAiProviderCard('Gemini 3 Flash', true, theme, colorScheme),
                  _buildAiProviderCard('GPT-4o', false, theme, colorScheme),
                  _buildSettingTile(Icons.vpn_key, 'API 密钥配置', '管理各大 AI 服务商密钥', theme),

                  const SizedBox(height: 24),

                  // Preferences
                  _buildSectionHeader('偏好设置', theme),
                  SwitchListTile(
                    title: const Text('深色模式'),
                    value: theme.brightness == Brightness.dark,
                    onChanged: (val) {},
                  ),
                  _buildSettingTile(Icons.notifications, '个性化通知', '基于查证结果的智能提醒', theme),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: colorScheme.primary,
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('资讯先锋', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text('累计阅读: 1,280 | 已查证: 45', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, ThemeData theme) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _buildAiProviderCard(String name, bool connected, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: connected ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Text(connected ? '已连接' : '未连接', style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
