import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Skill {
  final String id;
  final String name;
  final String description;
  final String sop; // Standard Operating Procedure in Markdown/JSON
  final String version;

  Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.sop,
    required this.version,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      sop: json['sop'],
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'sop': sop,
    'version': version,
  };
}

class SkillManager {
  List<Skill> _activeSkills = [];

  List<Skill> get activeSkills => _activeSkills;

  Future<void> loadSkills() async {
    final directory = await getApplicationDocumentsDirectory();
    final skillsFile = File('${directory.path}/skills_cache.json');
    
    if (await skillsFile.exists()) {
      final content = await skillsFile.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      _activeSkills = jsonList.map((e) => Skill.fromJson(e)).toList();
    }
    
    // Load built-in skills if cache empty
    if (_activeSkills.isEmpty) {
      _activeSkills = _getBuiltInSkills();
    }
  }

  /// Skill Creator logic: allows AI to generate and save new skills
  Future<void> saveGeneratedSkill(Skill newSkill) async {
    _activeSkills.add(newSkill);
    final directory = await getApplicationDocumentsDirectory();
    final skillsFile = File('${directory.path}/skills_cache.json');
    await skillsFile.writeAsString(jsonEncode(_activeSkills.map((e) => e.toJson()).toList()));
  }

  List<Skill> _getBuiltInSkills() {
    return [
      Skill(
        id: 'finance-verify',
        name: 'Finance Data Verifier',
        description: 'Verifies financial figures and stock data',
        sop: '1. Identify ticker symbols. 2. Cross-reference with Yahoo Finance/Bloomberg. 3. Check for recent SEC filings.',
        version: '1.0.0',
      ),
      Skill(
        id: 'geopolitics-verify',
        name: 'Geopolitical Analyst',
        description: 'Cross-references news from multiple international sources',
        sop: '1. Search for same news in Reuters, AP, and local sources. 2. Identify conflicting narratives. 3. Check official government statements.',
        version: '1.0.0',
      ),
    ];
  }
}
