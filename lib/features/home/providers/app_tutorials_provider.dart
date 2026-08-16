import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

class AppTutorialItem {
  final int id;
  final String title;
  final String? caption;
  final String videoUrl;
  final String? coverUrl;
  final int sortOrder;

  AppTutorialItem({
    required this.id,
    required this.title,
    this.caption,
    required this.videoUrl,
    this.coverUrl,
    required this.sortOrder,
  });

  factory AppTutorialItem.fromJson(Map<String, dynamic> json) {
    return AppTutorialItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      caption: json['caption'],
      videoUrl: json['video_url'] ?? '',
      coverUrl: json['cover_url'],
      sortOrder: json['sort_order'] ?? 1,
    );
  }
}

final appTutorialsProvider = FutureProvider<List<AppTutorialItem>>((ref) async {
  final dio = ref.read(dioProvider);

  final response = await dio.get(
    '/app-tutorials/',
    options: Options(
      extra: {'skipAuthInterceptor': true}, // بدون نیاز به توکن/احراز هویت
    ),
  );

  final List data = response.data;
  final tutorials = data.map((json) => AppTutorialItem.fromJson(json)).toList();

  // مرتب‌سازی بر اساس sort_order
  tutorials.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  return tutorials;
});
