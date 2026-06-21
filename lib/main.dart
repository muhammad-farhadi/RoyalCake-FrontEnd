import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() {
  runApp(
    // ProviderScope برای مدیریت استیت‌های Riverpod الزامی است
    const ProviderScope(child: MyApp()),
  );
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
      home: HomePage(),
    );
  }
}
