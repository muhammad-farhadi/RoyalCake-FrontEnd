import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

// مدل اطلاعات کاربر نویسنده
class ReviewUser {
  final String fullName;

  ReviewUser({required this.fullName});

  factory ReviewUser.fromJson(Map<String, dynamic> json) =>
      ReviewUser(fullName: json['full_name'] ?? '');
}

// مدل اصلی نظر
class CourseReviewModel {
  final int id;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final ReviewUser user;

  CourseReviewModel({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.user,
  });

  factory CourseReviewModel.fromJson(Map<String, dynamic> json) {
    return CourseReviewModel(
      id: json['id'],
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      user: ReviewUser.fromJson(json['user'] ?? {}),
    );
  }
}

// مدیریت وضعیت نظرات با ریورپاد
class CourseReviewsNotifier
    extends StateNotifier<AsyncValue<List<CourseReviewModel>>> {
  final Ref ref;

  CourseReviewsNotifier(this.ref) : super(const AsyncValue.loading());

  // دریافت نظرات تایید شده یک دوره خاص
  Future<void> fetchReviews(int courseId) async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/courses/$courseId/reviews');
      final List data = response.data;
      final reviews = data.map((e) => CourseReviewModel.fromJson(e)).toList();
      state = AsyncValue.data(reviews);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // ارسال نظر جدید همراه با عکس اختیاری
  Future<bool> submitReview({
    required int courseId,
    required String content,
    MultipartFile? imageFile,
  }) async {
    try {
      final dio = ref.read(dioProvider);

      final formData = FormData.fromMap({
        'content': content,
        if (imageFile != null) 'image': imageFile,
      });

      await dio.post('/courses/$courseId/reviews', data: formData);
      // بروزرسانی مجدد لیست نظرات بعد از ثبت موفق
      fetchReviews(courseId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final courseReviewsProvider =
    StateNotifierProvider<
      CourseReviewsNotifier,
      AsyncValue<List<CourseReviewModel>>
    >((ref) {
      return CourseReviewsNotifier(ref);
    });
