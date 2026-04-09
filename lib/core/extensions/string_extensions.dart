import 'package:uuid/uuid.dart';

/// Extension on DateTime for formatting
extension DateTimeExtensions on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    final minutes = diff.inMinutes;
    final hours = diff.inHours;
    final days = diff.inDays;

    if (minutes < 1) return '刚刚';
    if (minutes < 60) return '$minutes分钟前';
    if (hours < 24) return '$hours小时前';
    if (days < 7) return '$days天前';
    return '$month月$day日';
  }

  String get formattedDate => '$year年$month月$day日';

  String get formattedDateTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$year年$month月$day日 $h:$m';
  }
}

/// Extension on String for validation
extension StringExtensions on String {
  bool get isValidUrl {
    try {
      final uri = Uri.parse(this);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  bool get isValidApiKey => length >= 8;

  String get truncated => length > 100 ? '${substring(0, 100)}...' : this;
}

/// Extension for generating UUID
extension UuidExtensions on Never {
  static const _uuid = Uuid();

  static String generate() => _uuid.v4();
}
