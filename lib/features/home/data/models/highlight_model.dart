class HighlightCategoryModel {
  final int id;
  final String title;
  final String coverUrl;
  final DateTime createdAt;
  final List<HighlightItemModel> items;

  HighlightCategoryModel({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.createdAt,
    required this.items,
  });

  factory HighlightCategoryModel.fromJson(Map<String, dynamic> json) {
    return HighlightCategoryModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      coverUrl: json['cover_url'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      items:
          (json['items'] as List?)
              ?.map((item) => HighlightItemModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class HighlightItemModel {
  final int id;
  final String imageUrl;
  final DateTime createdAt;

  HighlightItemModel({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
  });

  factory HighlightItemModel.fromJson(Map<String, dynamic> json) {
    return HighlightItemModel(
      id: json['id'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
