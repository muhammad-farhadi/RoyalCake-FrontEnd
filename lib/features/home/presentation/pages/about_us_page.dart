import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  // متد سراسری برای باز کردن امن لینک‌ها و تماس تلفنی
  Future<void> _launchURL(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'خطا در باز کردن لینک مورد نظر',
              style: TextStyle(fontFamily: 'Samim'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔴 تضمین ۱۰۰ درصدی راست‌چین بودن کل این صفحه
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // ۱. بخش لوگو و هدر مینی‌مال
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'آکادمی تخصصی رویال کیک',
                style: TextStyle(
                  fontFamily: 'Samim',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'طعم شیرینِ حرفه‌ای شدن',
                style: TextStyle(
                  fontFamily: 'Samim',
                  fontSize: 13,
                  color: AppColors.darkText.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),

              // ۲. کارت متن جذاب درباره ما
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 🔴 آیکون در سمت راست متن قرار می‌گیرد
                        Icon(
                          Icons.cake_rounded,
                          color: AppColors.accent,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'داستان رویال کیک',
                          style: TextStyle(
                            fontFamily: 'Samim',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'رویال کیک فقط یک آکادمی آموزشی نیست؛ اینجا نقطه شروع یک مسیر شیرین و درآمدزاست. ما در رویال کیک با تکیه بر سال‌ها تجربه تخصصی در دنیای قنادی و دکوراتوری مدرن کیک، فضایی را خلق کرده‌ایم تا شما بتوانید از صفر مطلق و بدون نیاز به هیچ پیش‌زمینه‌ای، مهارت‌های اصیل و تکنیک‌های به‌روز بین‌المللی را بیاموزید.\n\nتمام دوره‌های ما به صورت کاملاً کاربردی، گام‌به‌گام و بازارکاری طراحی شده‌اند تا در کوتاه‌ترین زمان ممکن، آشپزخانه خانگی خود را به یک کارگاه قنادی پردرآمد تبدیل کنید. تعهد ما، پشتیبانی دائمی و همراهی با شما تا رسیدن به اولین سفارش موفق است.',
                      style: TextStyle(
                        fontFamily: 'Samim',
                        fontSize: 13.5,
                        color: AppColors.darkText,
                        height: 1.7,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),

              // ۳. بخش راه‌های ارتباطی و دکمه‌های شکیل اجتماعی
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0, bottom: 12),
                      child: Text(
                        'راه‌های ارتباطی با ما',
                        style: TextStyle(
                          fontFamily: 'Samim',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),

                    // دکمه تماس مستقیم تلفنی (به رنگ سبز تیره تم)
                    _buildCommunicationCard(
                      context: context,
                      icon: Icons.phone_in_talk_rounded,
                      title: 'پشتیبانی و مشاوره',
                      subtitle: '09394101313',
                      color: AppColors.primary,
                      url: 'tel:09394101313',
                    ),
                    const SizedBox(height: 12),

                    // سطر دکمه‌های مینی‌مال شبکه‌های اجتماعی
                    Row(
                      children: [
                        Expanded(
                          child: _buildSocialButton(
                            context: context,
                            assetIcon: 'assets/icons/instagram.png',
                            fallbackIcon: Icons.camera_alt_rounded,
                            title: 'اینستاگرام',
                            color: const Color(0xffE1306C),
                            url: 'https://instagram.com/royalcakes.ir',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSocialButton(
                            context: context,
                            assetIcon: 'assets/icons/telegram.png',
                            fallbackIcon: Icons.telegram_rounded,
                            title: 'تلگرام',
                            color: const Color(0xff0088cc),
                            url: 'https://t.me/royalcake',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSocialButton(
                            context: context,
                            assetIcon: 'assets/icons/whatsapp.png',
                            fallbackIcon: Icons.chat,
                            title: 'واتس‌اپ',
                            color: const Color(0xff25D366),
                            url: 'https://wa.me/989394101313',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSocialButton(
                            context: context,
                            assetIcon: 'assets/icons/bale.png',
                            fallbackIcon: Icons.chat_bubble_rounded,
                            title: 'پیام‌رسان بله',
                            color: const Color(0xff14876b),
                            url: 'https://ble.ir/09394101313',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ویجت باکس تماس تلفنی
  Widget _buildCommunicationCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchURL(url, context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Samim',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                // 🔴 شماره تماس با جهت LTR تا اعداد جابجا نشوند (مهم برای فارسی)
                Text(
                  subtitle,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontFamily: 'Samim',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // 🔴 فلش به سمت چپ تنظیم شد چون در چیدمان راست‌چین، حرکت به جلو یعنی سمت چپ
            Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  // ویجت شکیل دکمه‌های شبکه‌های اجتماعی
  Widget _buildSocialButton({
    required BuildContext context,
    required String assetIcon,
    required IconData fallbackIcon,
    required String title,
    required Color color,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchURL(url, context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetIcon,
              width: 22,
              height: 22,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(fallbackIcon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Samim',
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

