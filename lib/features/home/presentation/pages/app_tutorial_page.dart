import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AppTutorialPage extends StatelessWidget {
  const AppTutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        appBar: AppBar(
          title: const Text(
            'راهنمای نصب و استفاده',
            style: TextStyle(
              fontFamily: 'Samim',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 0.5,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // هدر کارتونی و جذاب صفحه
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.add_to_home_screen_rounded,
                      size: 65,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'رویال کیک همیشه همراه شماست!',
                      style: TextStyle(
                        fontFamily: 'Samim',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'با اضافه کردن وب‌اپلیکیشن به صفحه اصلی گوشی، بدون نیاز به مرورگر و شبیه به یک اپلیکیشن بومی از دوره‌ها استفاده کنید.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Samim',
                        fontSize: 12.5,
                        color: Colors.black54,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 🍏 تب راهنمای اختصاصی آیفون (Safari)
              const Text(
                'راهنمای نصب در گوشی‌های آیفون (iOS)',
                style: TextStyle(
                  fontFamily: 'Samim',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              const SizedBox(height: 12),

              _buildStepCard(
                stepNumber: '۱',
                icon: Icons.open_in_browser,
                iconColor: Colors.blueAccent,
                text:
                    'وب‌سایت رویال کیک را حتماً در مرورگر خودِ آیفون یعنی Safari باز کنید.',
              ),
              _buildStepCard(
                stepNumber: '۲',
                icon: Icons.ios_share, // آیکون معروف شیر آیفون
                iconColor: Colors.blue,
                text:
                    'در نوار پایین مرورگر سافاری، روی دکمه اشتراک‌گذاری (Share) که به شکل یک مربع با فلش رو به بالا است ضربه بزنید.',
              ),
              _buildStepCard(
                stepNumber: '۳',
                icon: Icons.add_box_outlined,
                iconColor: AppColors.primary,
                text:
                    'در منوی باز شده، کمی به پایین اسکرول کنید و گزینه "Add to Home Screen" (یا افزودن به صفحه اصلی) را انتخاب کنید.',
              ),
              _buildStepCard(
                stepNumber: '۴',
                icon: Icons.check_circle_outline_rounded,
                iconColor: Colors.green,
                text:
                    'در نهایت در بالای صفحه روی دکمه Add (یا افزودن) بزنید. آیکون آکادمی به صفحه اصلی گوشی شما اضافه شد!',
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // 🤖 تب راهنمای اندروید (Chrome) برای حرفه‌ای بودن کار
              const Text(
                'راهنمای نصب در گوشی‌های اندروید',
                style: TextStyle(
                  fontFamily: 'Samim',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 12),

              _buildStepCard(
                stepNumber: '۱',
                icon: Icons.more_vert_rounded,
                iconColor: Colors.grey,
                text:
                    'سایت را در مرورگر Google Chrome باز کرده و روی سه نقطه بالای صفحه سمت چپ ضربه بزنید.',
              ),
              _buildStepCard(
                stepNumber: '۲',
                icon: Icons.install_mobile_rounded,
                iconColor: Colors.teal,
                text:
                    'گزینه "Install App" یا همان "افزودن به صفحه اصلی" (Add to Home screen) را انتخاب کنید تا برنامه نصب شود.',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ویجت باکس گام‌های آموزشی
  Widget _buildStepCard({
    required String stepNumber,
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // دایره شماره گام
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: TextStyle(
                  fontFamily: 'Samim',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // آیکون گرافیکی راهنما
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 14),
          // متن گام
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Samim',
                fontSize: 13,
                color: AppColors.darkText,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
