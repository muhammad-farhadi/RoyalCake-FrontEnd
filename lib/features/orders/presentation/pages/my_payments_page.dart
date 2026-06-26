import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/cart_provider.dart';

class MyPaymentsPage extends ConsumerWidget {
  const MyPaymentsPage({super.key});

  // متد کمکی برای فرمت کردن قیمت به تومان
  String _formatPrice(dynamic price) {
    if (price == null || price == 0) return '۰';
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

  // متد کمکی برای فرمت ساده تاریخ (جدا کردن تاریخ از ساعت)
  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'نامشخص';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsState = ref.watch(myPaymentsProvider);

    return paymentsState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, stack) => const Center(
        child: Text(
          'خطا در دریافت لیست پرداختی‌ها',
          style: TextStyle(fontFamily: 'Samim', color: AppColors.darkText),
        ),
      ),
      data: (payments) {
        if (payments.isEmpty) {
          return const Center(
            child: Text(
              'شما هنوز هیچ تراکنشی نداشته‌اید.',
              style: TextStyle(fontFamily: 'Samim', color: Colors.black45),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
            final status = payment['status']?.toString().toLowerCase() ?? '';

            // تعیین رنگ و متن وضعیت تراکنش
            final isSuccess =
                status == 'success' || status == 'paid' || status == 'موفق';
            final statusText = isSuccess ? 'موفق' : 'ناموفق / در انتظار';
            final statusColor = isSuccess ? Colors.green : Colors.orange;
            final statusIcon = isSuccess
                ? Icons.check_circle_outline
                : Icons.pending_outlined;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontFamily: 'Samim',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatDate(payment['created_at']),
                        style: const TextStyle(
                          color: Colors.black45,
                          fontFamily: 'Samim',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, thickness: 0.5),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'مبلغ پرداختی:',
                        style: TextStyle(
                          color: Colors.black54,
                          fontFamily: 'Samim',
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _formatPrice(payment['amount']),
                        style: const TextStyle(
                          color: AppColors.darkText,
                          fontFamily: 'Samim',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'شماره پیگیری (Ref ID):',
                        style: TextStyle(
                          color: Colors.black54,
                          fontFamily: 'Samim',
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        payment['ref_id'] ?? 'ندارد',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontFamily: 'Samim',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
