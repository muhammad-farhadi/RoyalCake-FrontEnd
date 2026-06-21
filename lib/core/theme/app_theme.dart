import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Samim',
      scaffoldBackgroundColor: const Color(0xFFFDFBF7),

      // کرم خیلی ملایم
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6F4E37), // رنگ قهوه‌ای شکلاتی بیس
        primary: const Color(0xFFD4A373), // قهوه‌ای طلایی/کرمی گرم
        secondary: const Color(0xFFE29578), // صورتی/هلویی ملایم
        surface: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFDFBF7),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF4A3E3D)),
        titleTextStyle: TextStyle(
          fontFamily: 'Samim',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A3E3D),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A3E3D),
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4A3E3D),
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF5C504E)),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF7A6E6B)),
      ),
    );
  }
}
