import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../data/models/verification_result.dart';

class AiSummaryPanel extends StatelessWidget {
  final VerificationResult? result;

  const AiSummaryPanel({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.7),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI 事实总结',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    _buildVerdictChip(result?.verdict ?? Verdict.unverified, theme),
                  ],
                ),
                const SizedBox(height: 24),

                // AI Summary
                Text(
                  result?.aiSummary ?? '正在分析中...',
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 32),

                // Cross References
                Text(
                  '交叉验证来源',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (result?.crossReferences.isNotEmpty == true)
                  ...result!.crossReferences.map((ref) => _buildReferenceTile(ref, theme))
                else
                  Text('尚无交叉引用数据', style: theme.textTheme.bodySmall),

                const SizedBox(height: 32),

                // Follow-up Timeline (Placeholder)
                Text(
                  '每日跟进时间线',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTimelineItem('2026-04-09', '初始核查完成', true, theme),
                _buildTimelineItem('2026-04-10', '追踪到最新进展 (计划中)', false, theme),
                
                const SizedBox(height: 48), // Padding at bottom
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerdictChip(Verdict verdict, ThemeData theme) {
    Color color;
    switch (verdict) {
      case Verdict.verified: color = Colors.green; break;
      case Verdict.disputed: color = Colors.red; break;
      case Verdict.outdated: color = Colors.grey; break;
      default: color = Colors.amber;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        verdict.label,
        style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildReferenceTile(SourceReference ref, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.link, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ref.sourceName, style: theme.textTheme.labelSmall),
                Text(
                  ref.title,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String date, String event, bool completed, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                ),
              ),
              Container(width: 2, height: 20, color: theme.colorScheme.outlineVariant),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: theme.textTheme.labelSmall),
              Text(event, style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
