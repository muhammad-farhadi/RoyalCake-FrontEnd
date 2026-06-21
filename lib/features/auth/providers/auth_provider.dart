import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/token_storage.dart';

enum LoginStatus { success, unverified, error }

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  AuthState({this.isLoading = false, this.error, this.isSuccess = false});

  AuthState copyWith({bool? isLoading, String? error, bool? isSuccess}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState());

  // ۱. ورود با شماره موبایل و رمز عبور
  Future<LoginStatus> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/users/login',
        data: {
          'grant_type': 'password',
          'username': phone,
          'password': password,
          'scope': '',
          'client_id': 'string',
          'client_secret': 'string',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      // ذخیره توکن‌ها پس از لاگین موفق
      final access = response.data['access_token'];
      final refresh = response.data['refresh_token'];
      await TokenStorage.saveTokens(access, refresh);

      state = state.copyWith(isLoading: false, isSuccess: true);
      return LoginStatus.success;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 &&
          e.response?.data['detail'] ==
              'لطفا ابتدا حساب کاربری خود را تایید کنید.') {
        state = state.copyWith(isLoading: false);
        return LoginStatus.unverified;
      }
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['detail']?.toString() ?? 'خطا در ورود',
      );
      return LoginStatus.error;
    }
  }

  Future<bool> resendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);

      // نکته: این مسیر را بر اساس Swagger خود تنظیم کنید (مسیر درخواست مجدد کد)
      await dio.post('/users/resend-otp', data: {'phone_number': phone});

      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      final errorMsg = e.response?.data['detail'] ?? 'خطا در ارسال مجدد کد.';
      state = state.copyWith(isLoading: false, error: errorMsg.toString());
      return false;
    }
  }

  // ۲. ثبت‌نام و درخواست OTP
  Future<bool> register(String fullName, String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);

      await dio.post(
        '/users/register', // مسیر دقیق ثبت‌نام از Swagger
        data: {
          'full_name': fullName,
          'phone_number': phone,
          'password': password,
        },
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['detail'] ??
          'خطا در ثبت‌نام. شاید این شماره قبلاً ثبت شده باشد.';
      state = state.copyWith(isLoading: false, error: errorMsg);
      return false;
    }
  }

  // ۳. تایید OTP و فعال‌سازی حساب
  Future<bool> verifyOtpAndLogin(
    String phone,
    String code,
    String password,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);

      // ۱. ابتدا تایید حساب کاربری
      await dio.post(
        '/users/verify-otp',
        data: {'phone_number': phone, 'otp_code': code},
      );

      // ۲. در صورت تایید موفق، به صورت خودکار لاگین می‌کنیم
      final loginResult = await login(phone, password);

      if (loginResult == LoginStatus.success) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['detail']?.toString() ?? 'کد نامعتبر است.',
      );
      return false;
    }
  }

  Future<bool> forgotPassword(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);

      await dio.post(
        '/users/forgot-password',
        data: {'phone_number': phone},
      );

      state = state.copyWith(isLoading: false);
      return true; // پیامک ارسال شد یا روت با موفقیت پاسخ داد
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['detail'] ?? 'خطا در ارسال درخواست فراموشی رمز عبور';
      state = state.copyWith(isLoading: false, error: errorMsg.toString());
      return false;
    }
  }

  // ۴. بازنشانی رمز عبور و ورود خودکار بلافاصله پس از آن
  Future<bool> resetPasswordAndLogin(
    String phone,
    String code,
    String newPassword,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);

      // تغییر رمز عبور در سرور
      await dio.post(
        '/users/reset-password',
        data: {
          'phone_number': phone,
          'otp_code': code,
          'new_password': newPassword,
        },
      );

      // ورود خودکار بلافاصله با اطلاعات جدید
      final loginStatus = await login(phone, newPassword);
      return loginStatus == LoginStatus.success;
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['detail'] ??
          'خطا در بازنشانی رمز عبور یا کد نامعتبر است.';
      state = state.copyWith(isLoading: false, error: errorMsg.toString());
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
