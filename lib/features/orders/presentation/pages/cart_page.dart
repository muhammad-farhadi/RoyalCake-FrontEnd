import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/cart_provider.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final TextEditingController _discountController = TextEditingController();
  bool _isProcessing = false;
  bool _isDeleting = false;

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
      // ۱. ثبت فاکتور و اعمال تخفیف
      final order = await ref
          .read(cartProvider.notifier)
          .checkout(_discountController.text);

      // در دنیای واقعی اینجا باید کاربر را به لینک درگاه (زرین‌پال) بفرستید.
      // اما الان طبق بک‌اند، ما شبیه‌سازی پرداخت را صدا می‌زنیم:

      final orderId = order['id'];
      final success = await ref
          .read(cartProvider.notifier)
          .verifyMockPayment(orderId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'پرداخت موفق! دوره‌ها به حساب شما اضافه شد.',
              style: TextStyle(fontFamily: 'Samim'),
            ),
          ),
        );
        Navigator.pop(context); // برگشت به صفحه قبل
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
              'با موفقیت از سبد خرید حذف شد',
              style: TextStyle(fontFamily: 'Samim'),
            ),
          ),
        );
        // توجه: خط Navigator.pop حذف شد تا با یک حذف، صفحه بسته نشود
      }
    } catch (e) {
      // حالا اگر اروری رخ دهد، اینجا دریافت و به کاربر نشان داده می‌شود
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
            'سبد خرید',
            style: TextStyle(
              fontFamily: 'Samim',
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: cartState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, stack) => Center(child: Text('خطا: $err')),
          data: (cart) {
            if (cart == null ||
                cart['items'] == null ||
                (cart['items'] as List).isEmpty) {
              return const Center(
                child: Text(
                  'سبد خرید شما خالی است.',
                  style: TextStyle(fontFamily: 'Samim', fontSize: 16),
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
                            item['course_title'] ?? 'دوره آموزشی',
                            style: const TextStyle(
                              fontFamily: 'Samim',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            _formatPrice(item['price']),
                            style: const TextStyle(
                              fontFamily: 'Samim',
                              color: AppColors.primary,
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
                              final int targetId = item['course_id'] ?? item['id'];
                              _handleDeleteFromCard(targetId);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // بخش ورود کد تخفیف و پرداخت
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
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
                        // فیلد کد تخفیف
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _discountController,
                                decoration: InputDecoration(
                                  hintText: 'کد تخفیف دارید؟',
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Samim',
                                    fontSize: 13,
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

                        // قیمت کل
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'مبلغ کل:',
                              style: TextStyle(
                                fontFamily: 'Samim',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatPrice(totalPrice),
                              style: const TextStyle(
                                fontFamily: 'Samim',
                                fontSize: 18,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // دکمه پرداخت
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
                                    'تایید و پرداخت',
                                    style: TextStyle(
                                      fontFamily: 'Samim',
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
