import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

// استفاده از family برای ارسال ID دوره به بک‌اند
final courseDetailProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  courseId,
) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/courses/$courseId');
  return response.data as Map<String, dynamic>;
});
