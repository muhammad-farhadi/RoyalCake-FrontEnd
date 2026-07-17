class BannerModel {
  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final int courseId;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.courseId,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      imageUrl: json['image_url'] ?? '',
      courseId: json['course_id'] ?? 0,
    );
  }
}
