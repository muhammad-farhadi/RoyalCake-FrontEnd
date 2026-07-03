import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../main.dart'; // 🔴 حتماً هدر یا فایل main.dart را برای دسترسی به navigatorKey ایمپورت کنید
import '../../features/auth/presentation/pages/login_page.dart'; // 🔴 ایمپورت صفحه لاگین برای انتقال کاربر
import '../constants/app_constants.dart';
import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

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
    if (err.response?.statusCode == 401) {
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

          err.requestOptions.headers['Authorization'] =
              'Bearer $newAccessToken';

          final retryOptions = Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
          );

          final retryResponse = await dio.request(
            err.requestOptions.path,
            options: retryOptions,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );

          return handler.resolve(retryResponse);
        } catch (e) {
          await TokenStorage.clearTokens();
          String errorMessage =
              "نشست شما منقضی شده است.در صورت نیاز مجدد وارد حساب کاربری خود شوید.";
          if (e is DioException && e.response?.data != null) {
            final data = e.response?.data;
            if (data is Map && data.containsKey('detail')) {
              errorMessage = data['detail'].toString();
            }
          }
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
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  content: Text(
                    errorMessage,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 15),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "ورود مجدد",
                        style: TextStyle(
                          color: Color(0xff0c4d3b),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }

          return handler.next(err);
        }
      }
    }
    return handler.next(err);
  }
}
