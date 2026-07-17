import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/courses/presentation/pages/course_detail_page.dart'; // 🔴 ایمپورت صفحه جزئیات دوره

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Royal Cake',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey,

      // 🔴 به جای پارامتر home، از مدیریت مسیر هوشمند (Routing) استفاده می‌کنیم
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // نام مسیر (آدرسی که در مرورگر یا دیپ‌لینک دریافت شده)
        final uri = Uri.parse(settings.name ?? '/');

        // 🔴 بررسی الگوی آدرس برای جزئیات دوره (مثلاً /course/13)
        if (uri.pathSegments.length == 2 &&
            uri.pathSegments.first == 'course') {
          final courseIdStr = uri.pathSegments[1];
          final courseId = int.tryParse(courseIdStr);

          // اگر آیدی دوره عدد معتبری بود، کاربر را مستقیم به صفحه همان دوره می‌بریم
          if (courseId != null) {
            return MaterialPageRoute(
              builder: (context) => CourseDetailPage(courseId: courseId),
            );
          }
        }

        // 🔴 مسیر پیش‌فرض (صفحه اصلی) برای تمامی آدرس‌های دیگر
        return MaterialPageRoute(builder: (context) => const HomePage());
      },
    );
  }
}
