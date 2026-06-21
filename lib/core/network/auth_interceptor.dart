import 'package:dio/dio.dart';
import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // قبل از ارسال هر ریکوئست، توکن را به هدر اضافه می‌کنیم
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // اگر خطای 401 (منقضی شدن توکن) دریافت کردیم
    if (err.response?.statusCode == 401) {
      final refreshToken = await TokenStorage.getRefreshToken();

      if (refreshToken != null) {
        try {
          // یک نمونه جدید دیو می‌سازیم تا توی لوپ بی‌نهایت نیفتیم
          final refreshDio = Dio(BaseOptions(baseUrl: 'http://royalcakes.ir'));

          // درخواست رفرش توکن
          final response = await refreshDio.post(
            '/api/v1/users/refresh',
            data: {'refresh_token': refreshToken},
          );

          // گرفتن توکن‌های جدید
          final newAccessToken = response.data['access_token'];
          final newRefreshToken = response.data['refresh_token'];

          // ذخیره توکن‌های جدید در حافظه
          await TokenStorage.saveTokens(newAccessToken, newRefreshToken);

          // آپدیت کردن هدر درخواست فیلد شده با توکن جدید
          err.requestOptions.headers['Authorization'] =
              'Bearer $newAccessToken';

          // ارسال مجدد همان درخواستی که فیلد شده بود
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

          // برگرداندن دیتای موفق به اپلیکیشن (کاربر اصلاً متوجه ارور 401 نمیشه)
          return handler.resolve(retryResponse);
        } catch (e) {
          // اگر رفرش توکن هم منقضی شده بود -> خروج اجباری کاربر
          await TokenStorage.clearTokens();
          // اینجا می‌توانید یک رویداد بفرستید تا کاربر به صفحه لاگین پرتاب شود
          return handler.next(err);
        }
      }
    }
    return handler.next(err);
  }
}
