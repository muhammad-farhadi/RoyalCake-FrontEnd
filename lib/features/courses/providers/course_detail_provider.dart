import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

// پرووایدر جزئیات دوره (از قبل داشتید)
final courseDetailProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  courseId,
) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/courses/$courseId');
  return response.data as Map<String, dynamic>;
});

// پرووایدر جدید برای دریافت لیست دوره‌های خریداری‌شده کاربر
final myCoursesProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  // هدر Authorization و توکن به صورت خودکار توسط AuthInterceptor تزریق می‌شود
  final response = await dio.get('/orders/my-courses');
  return response.data as List<dynamic>;
});
