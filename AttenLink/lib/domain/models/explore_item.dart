enum ExploreItemType { news, factReport, correction }

class ExploreItemModel {
  final ExploreItemType type;
  final String title;
  final String description;
  final String? link;
  
  ExploreItemModel({
    required this.type,
    required this.title,
    required this.description,
    this.link,
  });
}
