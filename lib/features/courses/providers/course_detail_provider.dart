import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

// پرووایدر جزئیات دوره همراه با مرتب‌سازی و محاسبه هوشمند زمان و تعداد جلسات
final courseDetailProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  courseId,
) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/courses/$courseId');

  // تبدیل دیتای دریافتی به یک مپ قابل تغییر
  final courseData = Map<String, dynamic>.from(response.data);
  final lessons = List<dynamic>.from(courseData['lessons'] ?? []);

  // ۱. جادوی مرتب‌سازی جلسات بر اساس sort_order (از کوچک به بزرگ)
  lessons.sort((a, b) {
    final int orderA = a['sort_order'] ?? 0;
    final int orderB = b['sort_order'] ?? 0;

    // اگر sort_orderها برابر بودند، بر اساس شناسه (id) مرتبش کن
    if (orderA == orderB) {
      final int idA = a['id'] ?? 0;
      final int idB = b['id'] ?? 0;
      return idA.compareTo(idB);
    }
    return orderA.compareTo(orderB);
  });

  // ۲. محاسبه خودکار و داینامیک تعداد جلسات
  final int dynamicSessionCount = lessons.length;

  // ۳. محاسبه هوشمند کل زمان دوره (جمع دقیقه‌ها و تبدیل به ساعت)
  final int totalMinutes = lessons.fold<int>(0, (sum, lesson) {
    return sum + (lesson['duration'] as int? ?? 0);
  });

  // تبدیل دقیقه به ساعت (به همراه اعشار در صورت نیاز، مثلاً ۳.۶ ساعت)
  final double hoursCalculated = totalMinutes / 60;
  // حذف اعشار صفر اضافی برای زیبایی لایوت (مثلاً تبدیل ۴.۰ به ۴)
  final String dynamicTotalHours = hoursCalculated
      .toStringAsFixed(1)
      .replaceAll('.0', '');

  // تزریق داده‌های پردازش‌شده و جدید به مپ اصلی برای استفاده در UI
  courseData['lessons'] = lessons;
  courseData['session_count'] = dynamicSessionCount;
  courseData['total_hours'] = dynamicTotalHours;

  return courseData;
});

// پرووایدر دریافت لیست دوره‌های خریداری‌شده کاربر
final myCoursesProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/orders/my-courses');
  return response.data as List<dynamic>;
});
