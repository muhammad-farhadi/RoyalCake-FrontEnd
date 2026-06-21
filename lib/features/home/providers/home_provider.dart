import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

// ------------------------------------------------------------------
// 1. پرووایدر دریافت لیست دوره‌ها
// ------------------------------------------------------------------
final coursesProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  // دریافت ۱۰ دوره اول
  final response = await dio.get('/courses/?skip=0&limit=10');
  return response.data as List<dynamic>;
});

// ------------------------------------------------------------------
// 2. پرووایدر دریافت گالری هنرجویان (با قابلیت Shuffle رندوم)
// ------------------------------------------------------------------
final galleryProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  // دریافت ۱۲ تصویر اول
  final response = await dio.get('/gallery/?skip=0&limit=12');

  List<dynamic> galleryList = List<dynamic>.from(response.data);
  // به هم ریختن (Shuffle) لیست برای اینکه هر بار تکراری نباشد
  galleryList.shuffle(Random());

  return galleryList;
});

// ------------------------------------------------------------------
// 3. تابع کمکی برای تبدیل قیمت عددی به فرمت پولی فارسی (مثلا ۱,۰۰۰,۰۰۰ تومان)
// ------------------------------------------------------------------
String formatPrice(dynamic price) {
  if (price == null || price == 0) return 'رایگان';

  final strPrice = price.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );

  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  String farsiPrice = strPrice;
  for (int i = 0; i < english.length; i++) {
    farsiPrice = farsiPrice.replaceAll(english[i], farsi[i]);
  }

  return '$farsiPrice تومان';
}
