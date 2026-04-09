import 'package:isar/isar.dart';

part 'isar_entities.g.dart';

@collection
class NewsArticleEntity {
  Id? isarId; // Auto-incrementing int ID for Isar

  @Index(unique: true, replace: true)
  late String originalId;

  @Index(type: IndexType.value)
  late String title;
  
  late String summary;
  late String content;
  
  @Index()
  late String url;
  
  late String imageUrl;
  
  @Index()
  late String sourceId;
  
  late String sourceName;
  
  @Index()
  late DateTime publishedAt;
  
  @Index()
  late DateTime fetchedAt;
  
  late List<String> tags;
  late String category;

  // User interaction
  @Index()
  late int userAction; // Enum index
  
  late DateTime? actionAt;

  // Verification
  @Index()
  late int verificationStatus; // Enum index
  
  late String? verificationId;

  // Weight & tracking
  @Index()
  late double weight;
  
  late bool isRead;
  late int readDurationSeconds;
  
  @Index()
  late DateTime? nextFollowUpAt;
}

@collection
class VerificationResultEntity {
  Id? isarId;

  @Index(unique: true, replace: true)
  late String originalId;

  @Index()
  late String articleId;
  
  @Index()
  late int verdict; // Enum index
  
  late String aiSummary;
  
  late DateTime verifiedAt;
  late double confidenceScore;
  late String? providerId;
  
  // Follow-ups stored as JSON strings for simplicity in Isar, 
  // or we could use Links if we wanted complex relational data.
  late List<String> followUpsJson;
  late List<String> crossReferencesJson;
}
