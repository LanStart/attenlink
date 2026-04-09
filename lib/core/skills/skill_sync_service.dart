import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SkillSyncService {
  final Dio _dio;
  
  // Default hubs as requested
  static const List<String> defaultHubs = [
    'https://api.ai.tencent.com/skills/hub',
    'https://api.doubao.com/v1/skills/hub',
  ];

  SkillSyncService({Dio? dio}) : _dio = dio ?? Dio();

  /// Sync skills from configured hubs
  Future<void> syncSkills(List<String> hubUrls) async {
    for (final url in hubUrls) {
      try {
        final response = await _dio.get(url);
        if (response.statusCode == 200) {
          final skills = response.data['skills'] as List;
          await _saveSkillsLocally(skills);
        }
      } catch (e) {
        print('Failed to sync from hub $url: $e');
      }
    }
  }

  Future<void> _saveSkillsLocally(List<dynamic> skills) async {
    final directory = await getApplicationDocumentsDirectory();
    final skillsFile = File('${directory.path}/skills_cache.json');
    
    // Simple implementation: overwrite with latest
    await skillsFile.writeAsString(jsonEncode(skills));
  }
}
