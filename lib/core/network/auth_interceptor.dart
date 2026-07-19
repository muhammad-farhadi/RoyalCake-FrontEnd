import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../main.dart'; // برای دسترسی به navigatorKey
import '../../features/auth/presentation/pages/login_page.dart';
import '../constants/app_constants.dart';
import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  // 🔴 قفل‌ها و مکانیزم کنترل همزمانی برای حل مشکل کنترل وضعیت خروج ناخواسته
  static bool _isRefreshing = false;
  static Completer<String?>? _refreshCompleter;

  AuthInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 🔴 جادوی حل باگ: اگر در درخواست گفته شده بود که اینترسپتور دخالت نکند (مثل لاگین)، ارور را مستقیم پاس بده
    if (err.requestOptions.extra['skipAuthInterceptor'] == true) {
      return handler.next(err);
    }

    if (err.response?.statusCode == 401) {
      // 1️⃣ اگر فرآیند رفرش توکن از قبل توسط یک درخواست دیگر شروع شده، بقیه همینجا منتظر می‌مانند
      if (_isRefreshing) {
        final newAccessToken = await _refreshCompleter?.future;
        if (newAccessToken != null) {
          try {
            // تکرار درخواست فعلی با توکن جدیدی که توسط درخواست قبلی گرفته شده
            final response = await _retryRequest(
              err.requestOptions,
              newAccessToken,
            );
            return handler.resolve(response);
          } catch (e) {
            return handler.next(err);
          }
        }
        return handler.next(err);
      }

      // 2️⃣ این اولین درخواستی است که به خطای 401 خورده؛ فرآیند رفرش توکن را استارت می‌زنیم
      _isRefreshing = true;
      _refreshCompleter = Completer<String?>();

      final refreshToken = await TokenStorage.getRefreshToken();

      if (refreshToken != null) {
        try {
          final refreshDio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

          final response = await refreshDio.post(
            '/api/v1/users/refresh',
            data: {'refresh_token': refreshToken},
          );

          final newAccessToken = response.data['access_token'];
          final newRefreshToken = response.data['refresh_token'];

          await TokenStorage.saveTokens(newAccessToken, newRefreshToken);

          // 3️⃣ توکن با موفقیت تمدید شد؛ قفل را باز کرده و به بقیه درخواست‌های منتظر در صف اطلاع می‌دهیم
          _refreshCompleter?.complete(newAccessToken);
          _isRefreshing = false;

          // تکرار همین درخواست اول با توکن جدید
          final retryResponse = await _retryRequest(
            err.requestOptions,
            newAccessToken,
          );
          return handler.resolve(retryResponse);
        } catch (e) {
          // در صورت بروز هرگونه خطا در تمدید، صف آزاد شده و لاگ‌اوت واقعی انجام می‌شود
          _refreshCompleter?.complete(null);
          _isRefreshing = false;

          await TokenStorage.clearTokens();
          _showLogoutDialog(err, handler);
          return;
        }
      } else {
        _isRefreshing = false;
        _refreshCompleter = null;
        await TokenStorage.clearTokens();
        _showLogoutDialog(err, handler);
        return;
      }
    }
    return handler.next(err);
  }

  // متد کمکی بر پایه دپندرسی اصلی برای تکرار امن درخواست‌ها
  Future<Response> _retryRequest(
    RequestOptions requestOptions,
    String accessToken,
  ) {
    requestOptions.headers['Authorization'] = 'Bearer $accessToken';
    final retryOptions = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return dio.request(
      requestOptions.path,
      options: retryOptions,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );
  }

  // مدیریت یکپارچه نمایش دیالوگ خروج از حساب
  void _showLogoutDialog(DioException err, ErrorInterceptorHandler handler) {
    const errorMessage =
        "نشست شما منقضی شده است. در صورت نیاز مجدد وارد حساب کاربری خود شوید.";
    final context = navigatorKey.currentContext;

    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "خروج از حساب کاربری",
              textAlign: TextAlign.right, // اینجا اصلاح شد
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Samim',
              ),
            ),
            content: const Text(
              errorMessage,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 15, fontFamily: 'Samim'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text(
                  "ورود مجدد",
                  style: TextStyle(
                    color: Color(0xff0c4d3b),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Samim',
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
    handler.next(err);
  }
}
