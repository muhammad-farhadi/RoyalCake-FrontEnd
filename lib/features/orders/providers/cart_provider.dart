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

  // دریافت اطلاعات سبد خرید فعلی
  Future<void> fetchCart() async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (!mounted) return;
      if (token == null || token.isEmpty) {
        state = const AsyncValue.data(null);
        return;
      }
      state = const AsyncValue.loading();
      final response = await _dio.get('/orders/cart');
      if (!mounted) return;
      state = AsyncValue.data(response.data);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  // اضافه کردن دوره به سبد خرید
  Future<bool> addToCart(int courseId) async {
    try {
      await _dio.post('/orders/cart', data: {'course_id': courseId});
      await fetchCart();
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(
          e.response?.data['detail'] ?? 'خطا در اضافه کردن به سبد خرید',
        );
      }
      throw Exception('خطا در ارتباط با سرور');
    }
  }

  // فرآیند تسویه حساب و دریافت لینک درگاه زرین‌پال از بک‌باند نهایی
  Future<Map<String, dynamic>> checkout(String? discountCode) async {
    try {
      final response = await _dio.post(
        '/orders/checkout',
        data: {
          'discount_code': (discountCode != null && discountCode.isNotEmpty)
              ? discountCode
              : null,
        },
      );
      // خروجی شامل payment_url و message و order_id ارسالی از بک‌باند است
      return response.data;
    } on DioException catch (e) {
      print(e);
      throw Exception(
        e.response?.data['detail'] ?? 'خطا در ثبت سفارش و اتصال به درگاه',
      );
    }
  }

  // حذف یک دوره از سبد خرید بر اساس آدرس نهایی بک‌باند (/orders/cart/{course_id})
  Future<bool> deleteOrder(int courseId) async {
    try {
      await _dio.delete('/orders/cart/$courseId');
      await fetchCart(); // به‌روزرسانی مجدد سبد خرید پس از حذف
      return true;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? 'خطا در حذف دوره از سبد خرید',
      );
    } catch (e) {
      throw Exception('خطای نامشخص رخ داد');
    }
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<Map<String, dynamic>?>>((
      ref,
    ) {
      return CartNotifier(ref.read(dioProvider));
    });

// دریافت لیست تراکنش‌ها و پرداخت‌های موفق/ناموفق کاربر
final myPaymentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/orders/my-payments');
  return response.data as List<dynamic>;
});
