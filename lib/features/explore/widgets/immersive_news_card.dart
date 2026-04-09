import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/news_article.dart';

class ImmersiveNewsCard extends StatelessWidget {
  final NewsArticle article;
  final double swipeOffset; // -1.0 to 1.0

  const ImmersiveNewsCard({
    super.key,
    required this.article,
    this.swipeOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        // 1. Blurred Background Image
        Positioned.fill(
          child: article.imageUrl.isNotEmpty
              ? Image.network(
                  article.imageUrl,
                  fit: BoxFit.cover,
                )
              : Container(color: colorScheme.surface),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
        ),

        // 2. Clear Foreground Image (Center Card)
        Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: article.imageUrl.isNotEmpty
                    ? Image.network(article.imageUrl, fit: BoxFit.cover)
                    : Container(color: colorScheme.surfaceVariant),
              ),
            ),
          ),
        ),

        // 3. Gradient Garnish & Text Info
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 400,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source & Verification Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        article.sourceName,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildVerificationBadge(article.verificationStatus, theme),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  article.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Summary
                Text(
                  article.summary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 40), // Space for navigation
              ],
            ),
          ),
        ),

        // 4. Swipe Feedback Overlay
        if (swipeOffset != 0)
          Center(
            child: Opacity(
              opacity: swipeOffset.abs().clamp(0.0, 0.8),
              child: Icon(
                swipeOffset > 0 ? Icons.favorite : Icons.close,
                size: 150,
                color: swipeOffset > 0 ? Colors.green : Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVerificationBadge(VerificationStatus status, ThemeData theme) {
    IconData icon;
    Color color;
    String label = status.label;

    switch (status) {
      case VerificationStatus.verified:
        icon = Icons.verified_user;
        color = Colors.greenAccent;
        break;
      case VerificationStatus.disputed:
        icon = Icons.report_problem;
        color = Colors.redAccent;
        break;
      case VerificationStatus.verifying:
        icon = Icons.sync;
        color = Colors.blueAccent;
        break;
      default:
        icon = Icons.history;
        color = Colors.amberAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
