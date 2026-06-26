import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/token_storage.dart';
import '../../auth/providers/auth_provider.dart';

class CartNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final Dio _dio;

  CartNotifier(this._dio) : super(const AsyncValue.loading()) {
    fetchCart();
  }

  // ۱. دریافت اطلاعات سبد خرید
  Future<void> fetchCart() async {
    try {
      // بررسی توکن قبل از ارسال درخواست
      final token = await TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        state = const AsyncValue.data(null);
        return;
      }

      state = const AsyncValue.loading();
      final response = await _dio.get('/orders/cart');
      state = AsyncValue.data(response.data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ۲. افزودن دوره به سبد خرید
  Future<bool> addToCart(int courseId) async {
    try {
      await _dio.post('/orders/cart', data: {'course_id': courseId});
      await fetchCart(); // بروزرسانی سبد خرید بعد از اضافه شدن
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(
          e.response?.data['detail'] ?? 'خطا در افزودن به سبد خرید',
        );
      }
      throw Exception('خطای ارتباط با سرور');
    }
  }

  // ۳. تبدیل سبد به فاکتور (با یا بدون کد تخفیف)
  Future<Map<String, dynamic>> checkout(String? discountCode) async {
    try {
      final response = await _dio.post(
        '/orders/checkout',
        data: discountCode != null && discountCode.isNotEmpty
            ? {'discount_code': discountCode}
            : {},
      );
      return response.data; // اطلاعات فاکتور (Order) برمی‌گردد
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'خطا در اعمال کد تخفیف یا صدور فاکتور',
      );
    }
  }

  // ۴. شبیه‌سازی پرداخت (بازگشت از درگاه)
  Future<bool> verifyMockPayment(int orderId) async {
    try {
      await _dio.post(
        '/orders/mock-verify',
        data: {
          'order_id': orderId,
          'authority':
              'mock_authority_${DateTime.now().millisecondsSinceEpoch}',
        },
      );
      await fetchCart(); // خالی شدن سبد خرید در استیت
      return true;
    } catch (e) {
      return false;
    }
  }

  // ۵. حذف از سبد خرید
  Future<bool> deleteOrder(int courseId) async {
    try {
      await _dio.delete('/orders/cart/$courseId');
      await fetchCart();
      return true;
    } on DioException catch (e) {
      // پرتاب خطای بک‌اند به سمت صفحه برای نمایش به کاربر
      throw Exception(e.response?.data['detail'] ?? 'خطا در حذف از سبد خرید');
    } catch (e) {
      throw Exception('خطای نامشخص در ارتباط با سرور');
    }
  }
} // این آکولادی بود که احتمالا پاک شده بود!

// تعریف پرووایدر
final cartProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<Map<String, dynamic>?>>((
      ref,
    ) {
      // گوش دادن به وضعیت لاگین تا به محض لاگین، سبد خرید آپدیت شود
      ref.watch(authProvider.select((state) => state.isAuthenticated));

      return CartNotifier(ref.read(dioProvider));
    });

final myPaymentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/orders/my-payments');
  return response.data as List<dynamic>;
});
