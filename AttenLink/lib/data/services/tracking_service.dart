import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TrackedTopic {
  final String title;
  final String description;
  final String initialFactReport;
  final DateTime lastCheckedAt;

  TrackedTopic({
    required this.title,
    required this.description,
    required this.initialFactReport,
    required this.lastCheckedAt,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'initialFactReport': initialFactReport,
    'lastCheckedAt': lastCheckedAt.toIso8601String(),
  };

  factory TrackedTopic.fromJson(Map<String, dynamic> json) {
    return TrackedTopic(
      title: json['title'],
      description: json['description'],
      initialFactReport: json['initialFactReport'],
      lastCheckedAt: DateTime.parse(json['lastCheckedAt']),
    );
  }
}

class TrackingService {
  static const String _trackedKey = 'tracked_topics';

  Future<void> trackTopic(String title, String description, String factReport) async {
    final topics = await getTrackedTopics();
    
    // Update if exists, otherwise add new
    topics.removeWhere((t) => t.title == title);
    
    topics.add(TrackedTopic(
      title: title,
      description: description,
      initialFactReport: factReport,
      lastCheckedAt: DateTime.now(),
    ));

    await _saveTopics(topics);
  }

  Future<List<TrackedTopic>> getTrackedTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_trackedKey);
    if (jsonList == null) return [];

    return jsonList.map((str) => TrackedTopic.fromJson(jsonDecode(str))).toList();
  }

  Future<void> _saveTopics(List<TrackedTopic> topics) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = topics.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_trackedKey, jsonList);
  }
  
  Future<void> updateTopicCheckTime(String title) async {
    final topics = await getTrackedTopics();
    final index = topics.indexWhere((t) => t.title == title);
    if (index != -1) {
      final topic = topics[index];
      topics[index] = TrackedTopic(
        title: topic.title,
        description: topic.description,
        initialFactReport: topic.initialFactReport,
        lastCheckedAt: DateTime.now(),
      );
      await _saveTopics(topics);
    }
  }
}
