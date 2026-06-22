class AppConstants {
  AppConstants._();

  // آدرس پایه دامنه - برای تغییر کل آدرس‌ها فقط کافیست این خط عوض شود
  static const String baseUrl = 'https://royalcakes.ir';

  // آدرس پایه درخواست‌های API
  static const String apiBaseUrl = '$baseUrl/api/v1';

  // متد هوشمند برای ساخت لینک کامل تصاویر و فایل‌های استاتیک سرور
  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path; // اگر آدرس از قبل کامل بود

    // اصلاح خودکار اسلش ابتدای مسیر برای جلوگیری از خطای آدرس‌دهی
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$cleanPath';
  }
}
