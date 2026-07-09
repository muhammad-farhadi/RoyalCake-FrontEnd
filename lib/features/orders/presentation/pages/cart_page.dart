import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../providers/cart_provider.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

// 👈 اضافه شدن WidgetsBindingObserver برای شنیدن وضعیت بازگشت به اپلیکیشن
class _CartPageState extends ConsumerState<CartPage>
    with WidgetsBindingObserver {
  final TextEditingController _discountController = TextEditingController();
  bool _isProcessing = false;
  bool _isDeleting = false;

  // دو متغیر جدید برای مدیریت هوشمندانه وضعیت درگاه
  bool _wentToPayment = false;
  bool _isCheckingPayment = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // روشن کردن گوش‌زنگ
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // خاموش کردن گوش‌زنگ
    _discountController.dispose();
    super.dispose();
  }

  // ===================================================================
  // جادوی بررسی موفق یا ناموفق بودن پرداخت پس از بسته شدن درگاه
  // ===================================================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verifyPaymentStatus();
    }
  }

  Future<void> _verifyPaymentStatus() async {
    if (!_wentToPayment) return;
    if (_isCheckingPayment) return;

    setState(() => _isCheckingPayment = true);

    // ۱. پاک کردن فوری اسنک‌بار قبلی
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // ۲. آپدیت سبد خرید از بک‌اند
    await ref.read(cartProvider.notifier).fetchCart();

    if (!mounted) return;

    // ۳. پیام کوتاه و سرراست
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 4), // زمان رو هم کمتر کردیم
        content: Text(
          'در صورت پرداخت موفق، دوره به بخش «دوره‌های من» اضافه شد.',
          style: TextStyle(fontFamily: 'Samim', fontSize: 14),
        ),
      ),
    );

    // ۴. هدایت به داشبورد
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );

    if (mounted) {
      setState(() {
        _wentToPayment = false;
        _isCheckingPayment = false;
      });
    }
  }

  String _formatPrice(dynamic price) {
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

  Future<void> _handleCheckout() async {
    setState(() => _isProcessing = true);
    try {
      final checkoutResult = await ref
          .read(cartProvider.notifier)
          .checkout(_discountController.text);

      final String? paymentUrl = checkoutResult['payment_url'];

      if (!mounted) return;

      // وضعیت فاکتور رایگان
      if (paymentUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              checkoutResult['message'] ?? 'سفارش رایگان شما با موفقیت ثبت شد.',
              style: const TextStyle(fontFamily: 'Samim'),
            ),
          ),
        );
        ref.read(cartProvider.notifier).fetchCart();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
        return;
      }

      final Uri url = Uri.parse(paymentUrl);

      try {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.primary,
              content: Text(
                'در حال انتقال به درگاه پرداخت...',
                style: TextStyle(fontFamily: 'Samim'),
              ),
              duration: Duration(
                seconds: 15,
              ), // به قدری بالا می‌بریم تا مرورگر باز بشه، بعداً خودمون دستی پاکش میکنیم
            ),
          );
        }

        // علامت‌گذاری اینکه کاربر رسماً وارد فاز پرداخت شد
        setState(() => _wentToPayment = true);

        // باز کردن لینک درگاه
        await launchUrl(
          url,
          mode: kIsWeb
              ? LaunchMode.platformDefault
              : LaunchMode.inAppBrowserView,
        );

        // 👈 توجه: اینجا دیگه دستور Navigator.push نداریم!
        // کاربر تو همین صفحه زیرِ مرورگر میمونه تا کارش تموم بشه و تابع didChangeAppLifecycleState بالا اجرا بشه
      } catch (_) {
        await launchUrl(url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(fontFamily: 'Samim'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleDeleteFromCard(int courseId) async {
    setState(() => _isDeleting = true);
    try {
      final success = await ref
          .read(cartProvider.notifier)
          .deleteOrder(courseId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'دوره با موفقیت از سبد خرید شما حذف شد.',
              style: TextStyle(fontFamily: 'Samim'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(fontFamily: 'Samim'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text(
            'سبد خرید شما',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontFamily: 'Samim',
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: cartState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, stack) => Center(
            child: Text(
              'خطا در دریافت سبد خرید: $err',
              style: const TextStyle(fontFamily: 'Samim'),
            ),
          ),
          data: (cart) {
            if (cart == null ||
                cart['items'] == null ||
                (cart['items'] as List).isEmpty) {
              return const Center(
                child: Text(
                  'سبد خرید شما در حال حاضر خالی است.',
                  style: TextStyle(fontSize: 16, fontFamily: 'Samim'),
                ),
              );
            }
            final items = cart['items'] as List;
            final totalPrice = cart['total_price'] ?? 0;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            item['course_title'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Samim',
                            ),
                          ),
                          subtitle: Text(
                            _formatPrice(item['price']),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontFamily: 'Samim',
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: _isDeleting
                                ? null
                                : () {
                                    final int targetId =
                                        item['course_id'] ?? item['id'];
                                    _handleDeleteFromCard(targetId);
                                  },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _discountController,
                                decoration: InputDecoration(
                                  hintText: 'کد تخفیف دارید؟ وارد کنید...',
                                  hintStyle: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Samim',
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'مبلغ قابل پرداخت:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Samim',
                              ),
                            ),
                            Text(
                              _formatPrice(totalPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Samim',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _handleCheckout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'اتصال به درگاه پرداخت',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Samim',
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
