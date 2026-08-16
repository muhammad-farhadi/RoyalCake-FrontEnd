import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/token_storage.dart';

enum LoginStatus { success, unverified, error }

// 🔴 تابع کمکی سراسری برای تبدیل خودکار اعداد فارسی/عربی به انگلیسی
String toEnglishDigits(String input) {
  const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  for (int i = 0; i < 10; i++) {
    input = input
        .replaceAll(farsi[i], english[i])
        .replaceAll(arabic[i], english[i]);
  }
  return input;
}

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final bool isAuthenticated;
  final Map<String, dynamic>? userInfo;

  String? get phoneNumber => userInfo?['phone_number'];

  AuthState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.isAuthenticated = false,
    this.userInfo,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isSuccess,
    bool? isAuthenticated,
    Map<String, dynamic>? userInfo,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userInfo: userInfo ?? this.userInfo,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState()) {
    checkAuthStatus();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // 🔴 پارسر اختصاصی خطاها: تبدیل تمامی خطاهای خامی/جیسون سرور به فارسی روان
  String _handleDioError(DioException e) {
    if (e.response != null) {
      final status = e.response!.statusCode;
      final data = e.response!.data;

      if (status == 401) {
        return '❌ شماره موبایل یا کلمه عبور (رمز) اشتباه است!';
      } else if (status == 404) {
        return '⚠️ حسابی با این شماره یافت نشد! لطفاً ابتدا ثبت‌نام کنید.';
      } else if (status == 422) {
        return '⚠️ اطلاعات وارد شده معتبر نیست. شماره موبایل را بررسی کنید.';
      } else if (status == 500) {
        return '❌ خطای موقت سرور. لطفاً دقایقی دیگر مجدداً تلاش کنید.';
      }

      if (data is Map && data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) {
          return '❌ $detail';
        } else if (detail is List) {
          // جادوی اصلی: جلوگیری از رندر شدن لیست جیسون Pydantic
          return '⚠️ فرمت اطلاعات وارد شده معتبر نیست. لطفاً شماره موبایل و رمز عبور را چک کنید.';
        }
      }
    } else {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return '❌ زمان پاسخگویی سرور به پایان رسید. لطفاً اینترنت خود را چک کنید.';
      }
      return '❌ ارتباط با سرور برقرار نشد! اتصال اینترنت خود را بررسی کنید.';
    }
    return '❌ خطایی در انجام عملیات رخ داد.';
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final accessToken = await TokenStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      await fetchMe();
    } else {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
    }
  }

  Future<void> fetchMe() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/users/me');

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userInfo: response.data,
      );
    } catch (e) {
      await TokenStorage.clearTokens();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        userInfo: null,
      );
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearTokens();
    state = AuthState(isAuthenticated: false, userInfo: null, isSuccess: false);
  }

  Future<LoginStatus> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    // تبدیل خودکار اعداد فارسی به انگلیسی
    final cleanPhone = toEnglishDigits(phone.trim());
    final cleanPassword = toEnglishDigits(password.trim());

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/users/login',
        data: {
          'grant_type': 'password',
          'username': cleanPhone,
          'password': cleanPassword,
          'scope': '',
          'client_id': 'string',
          'client_secret': 'string',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          extra: {'skipAuthInterceptor': true},
        ),
      );

      final access = response.data['access_token'];
      final refresh = response.data['refresh_token'];
      await TokenStorage.saveTokens(access, refresh);

      await fetchMe();

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        isAuthenticated: true,
      );
      return LoginStatus.success;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 &&
          e.response?.data['detail'] ==
              'لطفا ابتدا حساب کاربری خود را تایید کنید.') {
        state = state.copyWith(isLoading: false);
        return LoginStatus.unverified;
      }

      state = state.copyWith(isLoading: false, error: _handleDioError(e));
      return LoginStatus.error;
    }
  }

  Future<bool> resendOtp(String phone) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);
    final cleanPhone = toEnglishDigits(phone.trim());

    try {
      final dio = ref.read(dioProvider);
      await dio.post(
        '/users/resend-otp',
        data: {'phone_number': cleanPhone},
        options: Options(extra: {'skipAuthInterceptor': true}),
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _handleDioError(e));
      return false;
    }
  }

  Future<bool> register(String fullName, String phone, String password) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    final cleanPhone = toEnglishDigits(phone.trim());
    final cleanPassword = toEnglishDigits(password.trim());

    try {
      final dio = ref.read(dioProvider);

      await dio.post(
        '/users/register',
        data: {
          'full_name': fullName.trim(),
          'phone_number': cleanPhone,
          'password': cleanPassword,
        },
        options: Options(extra: {'skipAuthInterceptor': true}),
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _handleDioError(e));
      return false;
    }
  }

  Future<bool> verifyOtpAndLogin(
    String phone,
    String code,
    String password,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    final cleanPhone = toEnglishDigits(phone.trim());
    final cleanCode = toEnglishDigits(code.trim());
    final cleanPassword = toEnglishDigits(password.trim());

    try {
      final dio = ref.read(dioProvider);

      await dio.post(
        '/users/verify-otp',
        data: {'phone_number': cleanPhone, 'otp_code': cleanCode},
        options: Options(extra: {'skipAuthInterceptor': true}),
      );

      final loginResult = await login(cleanPhone, cleanPassword);
      return loginResult == LoginStatus.success;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _handleDioError(e));
      return false;
    }
  }

  Future<bool> forgotPassword(String phone) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);
    final cleanPhone = toEnglishDigits(phone.trim());

    try {
      final dio = ref.read(dioProvider);

      await dio.post(
        '/users/forgot-password',
        data: {'phone_number': cleanPhone},
        options: Options(extra: {'skipAuthInterceptor': true}),
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _handleDioError(e));
      return false;
    }
  }

  Future<bool> resetPasswordAndLogin(
    String phone,
    String code,
    String newPassword,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true, isSuccess: false);

    final cleanPhone = toEnglishDigits(phone.trim());
    final cleanCode = toEnglishDigits(code.trim());
    final cleanPassword = toEnglishDigits(newPassword.trim());

    try {
      final dio = ref.read(dioProvider);

      await dio.post(
        '/users/reset-password',
        data: {
          'phone_number': cleanPhone,
          'otp_code': cleanCode,
          'new_password': cleanPassword,
        },
        options: Options(extra: {'skipAuthInterceptor': true}),
      );

      final loginStatus = await login(cleanPhone, cleanPassword);
      return loginStatus == LoginStatus.success;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _handleDioError(e));
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
