import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';

// 🔴 ورژن فعلی اپلیکیشن (مطابق با pubspec.yaml شما)
const String kCurrentAppVersion = "1.1.7";

class AppUpdateChecker {
  // متد مقایسه هوشمند دو رشته نسخه (مثلاً 1.1.3 با 1.1.4)
  static bool _isVersionOlder(String current, String target) {
    try {
      List<int> currentParts = current
          .split('+')[0]
          .split('.')
          .map((e) => int.parse(e.trim()))
          .toList();
      List<int> targetParts = target
          .split('+')[0]
          .split('.')
          .map((e) => int.parse(e.trim()))
          .toList();

      int maxLength = currentParts.length > targetParts.length
          ? currentParts.length
          : targetParts.length;

      for (int i = 0; i < maxLength; i++) {
        int c = i < currentParts.length ? currentParts[i] : 0;
        int t = i < targetParts.length ? targetParts[i] : 0;
        if (c < t) return true;
        if (c > t) return false;
      }
    } catch (_) {}
    return false;
  }

  // متد اصلی استعلام از سرور
  static Future<void> check(BuildContext context, WidgetRef ref) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/app-config'); // روتر دریافت کانفیگ

      if (response.statusCode == 200 && response.data != null) {
        final versionInfo = response.data['version_info'];
        if (versionInfo == null) return;

        final String latestVersion =
            versionInfo['latest_version'] ?? kCurrentAppVersion;
        final String minVersion =
            versionInfo['min_version'] ?? kCurrentAppVersion;
        final String downloadUrl =
            versionInfo['download_url'] ?? 'https://royalcakes.ir';
        final String title =
            versionInfo['update_title'] ?? 'نسخه جدید رویال کیک!';
        final String message =
            versionInfo['update_message'] ??
            'لطفاً اپلیکیشن را به روزرسانی کنید.';
        final bool serverForceUpdate = versionInfo['force_update'] ?? false;

        // بررسی اینکه آیا ورژن جدیدی ارائه شده است؟
        final bool hasNewVersion = _isVersionOlder(
          kCurrentAppVersion,
          latestVersion,
        );
        // بررسی اجباری بودن (یا طبق دیتای سرور یا به علت کمتر بودن از حداقل ورژن)
        final bool isForceUpdate =
            serverForceUpdate ||
            _isVersionOlder(kCurrentAppVersion, minVersion);

        if (hasNewVersion && context.mounted) {
          _showUpdateDialog(
            context: context,
            title: title,
            message: message,
            downloadUrl: downloadUrl,
            isForceUpdate: isForceUpdate,
          );
        }
      }
    } catch (_) {
      // در صورت قطع بودن اینترنت یا خطا در سرور، اپلیکیشن بدون افت فریم اجرا می‌شود
    }
  }

  // نمایش دیالوگ به‌روزرسانی شکیل و فارسی
  static void _showUpdateDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String downloadUrl,
    required bool isForceUpdate,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      // اگر اجباری باشد با کلیک بیرون بسته نمی‌شود
      builder: (context) {
        return PopScope(
          canPop: !isForceUpdate,
          // غیرفعال کردن دکمه بازگشت گوشی در آپدیت اجباری
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.system_update_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Samim',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'Samim',
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isForceUpdate)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '⚠️ استفاده از این نسخه دیگر امکان‌پذیر نیست. لطفاً حتماً برنامه را به روزرسانی کنید.',
                        style: TextStyle(
                          fontFamily: 'Samim',
                          fontSize: 11,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                if (!isForceUpdate)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'بعداً / فعلاً نه',
                      style: TextStyle(
                        fontFamily: 'Samim',
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    final Uri url = Uri.parse(downloadUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'دانلود و بروزرسانی 🚀',
                    style: TextStyle(
                      fontFamily: 'Samim',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
