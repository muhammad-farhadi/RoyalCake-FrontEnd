import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/courses/presentation/pages/course_detail_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');

        if (uri.pathSegments.length == 2 &&
            uri.pathSegments.first == 'course') {
          final courseIdStr = uri.pathSegments[1];
          final courseId = int.tryParse(courseIdStr);

          if (courseId != null) {
            return MaterialPageRoute(
              builder: (context) => CourseDetailPage(courseId: courseId),
            );
          }
        }

        return MaterialPageRoute(builder: (context) => const HomePage());
      },
    );
  }
}
