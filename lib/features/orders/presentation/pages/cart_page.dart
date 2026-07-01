import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart'; // حتماً این پکیج را به پابس‌پک اضافه کنید
import '../../../../core/theme/app_colors.dart';
import '../../providers/cart_provider.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage>
    with WidgetsBindingObserver {
  final TextEditingController _discountController = TextEditingController();
  bool _isProcessing = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // پایش برگشت کاربر به اپلیکیشن
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _discountController.dispose();
    super.dispose();
  }

  // وقتی کاربر بعد از تراکنش مروگر را می‌بندد و به اپلیکیشن برمی‌گردد، سبد خرید آپدیت می‌شود
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(cartProvider.notifier).fetchCart();
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

  // مدیریت اتصال به درگاه واقعی زرین‌پال
  Future<void> _handleCheckout() async {
    setState(() => _isProcessing = true);
    try {
      // ۱. ارسال درخواست ثبت فاکتور به بک‌باند
      final checkoutResult = await ref
          .read(cartProvider.notifier)
          .checkout(_discountController.text);

      final String? paymentUrl = checkoutResult['payment_url'];

      if (!mounted) return;

      // ۲. وضعیت فاکتور رایگان (بدون نیاز به لینک درگاه)
      if (paymentUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              checkoutResult['message'] ?? 'سفارش رایگان شما با موفقیت ثبت شد.',
            ),
          ),
        );
        ref.read(cartProvider.notifier).fetchCart();
        Navigator.pop(context);
        return;
      }

      // ۳. ارجاع کاربر به مرورگر جهت پرداخت فاکتور غیر رایگان در زرین‌پال
      final Uri url = Uri.parse(paymentUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('در حال انتقال به درگاه پرداخت زرین‌پال...'),
          ),
        );
      } else {
        throw Exception('امکان باز کردن مرورگر جهت اتصال به درگاه وجود ندارد.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(e.toString().replaceAll('Exception: ', '')),
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
            content: Text('دوره با موفقیت از سبد خرید شما حذف شد.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(e.toString().replaceAll('Exception: ', '')),
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
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: cartState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, stack) =>
              Center(child: Text('خطا در دریافت سبد خرید: $err')),
          data: (cart) {
            if (cart == null ||
                cart['items'] == null ||
                (cart['items'] as List).isEmpty) {
              return const Center(
                child: Text(
                  'سبد خرید شما در حال حاضر خالی است.',
                  style: TextStyle(fontSize: 16),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            _formatPrice(item['price']),
                            style: const TextStyle(color: AppColors.primary),
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
                                  hintStyle: const TextStyle(fontSize: 13),
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
                              ),
                            ),
                            Text(
                              _formatPrice(totalPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
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
