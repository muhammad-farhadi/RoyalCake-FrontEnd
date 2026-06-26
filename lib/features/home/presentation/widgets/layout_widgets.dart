import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../orders/presentation/pages/cart_page.dart';
import '../../../orders/providers/cart_provider.dart';
import '../../providers/home_provider.dart';
import 'home_widgets.dart'; // برای BottomNavShortcut
import '../../../auth/presentation/pages/login_page.dart'; // صفحه لاگین
import '../../../auth/providers/auth_provider.dart'; // ایمپورت پرووایدر جدید لاگین
import '../../../courses/presentation/pages/my_courses_page.dart';

// ==========================================
// ۱. پاپ‌آپ درخواست لاگین
// ==========================================
void showLoginRequiredBottomSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.lock_person_outlined,
              color: AppColors.accent,
              size: 50,
            ),
            const SizedBox(height: 16),
            const Text(
              'نیاز به ورود به حساب کاربری',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Samim',
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'برای انجام این عملیات، لطفاً ابتدا وارد حساب کاربری خود شوید.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontFamily: 'Samim',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // بستن پاپ‌آپ
                      // هدایت به صفحه واقعی لاگین
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'ورود و ثبت‌نام',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Samim',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'انصراف',
                      style: TextStyle(
                        color: AppColors.darkText,
                        fontFamily: 'Samim',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

// ==========================================
// ۲. منوی کشویی (Drawer)
// ==========================================
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // خواندن وضعیت از پرووایدر اصلی احراز هویت
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isAuthenticated;
    final userInfo = authState.userInfo;

    // استخراج اسم و موبایل برای نمایش (در صورت لاگین بودن)
    final userName = userInfo?['full_name'] ?? 'هنرجوی گرامی';
    final userPhone = userInfo?['phone_number'] ?? '';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(
                    isLoggedIn
                        ? 'assets/images/user_avatar.png'
                        : 'assets/images/logo.png',
                  ),
                  child: isLoggedIn
                      ? null
                      : const Icon(
                          Icons.cake_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  // اگر لاگین بود اسم کاربر رو نشون بده
                  isLoggedIn ? userName : 'رویال کیک',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Samim',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  // اگر لاگین بود شماره موبایل کاربر رو نشون بده
                  isLoggedIn ? userPhone : 'آکادمی تخصصی آموزش کیک و شیرینی',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontFamily: 'Samim',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          ListTile(
            leading: const Icon(Icons.person_outline, color: AppColors.primary),
            title: Text(
              isLoggedIn ? 'پروفایل کاربری' : 'ورود و ثبت‌نام',
              style: const TextStyle(
                fontFamily: 'Samim',
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              if (!isLoggedIn) {
                // اگر لاگین نیست، مستقیم بره به صفحه لاگین
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } else {
                // TODO: هدایت به صفحه پروفایل (اگر در آینده اضافه کردید)
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.school_outlined,
              color: AppColors.primary,
            ),
            title: const Text(
              'دوره‌های من',
              style: TextStyle(fontFamily: 'Samim'),
            ),
            onTap: () {
              Navigator.pop(context); // بستن منوی کشویی
              if (!isLoggedIn) {
                showLoginRequiredBottomSheet(context, ref);
              } else {
                // به جای باز کردن صفحه جدید، تب را روی 4 تنظیم می‌کنیم
                ref.read(bottomNavIndexProvider.notifier).state = 4;
              }
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.receipt_long_outlined, // آیکون رسید/پرداخت
              color: AppColors.primary,
            ),
            title: const Text(
              'پرداختی‌های من',
              style: TextStyle(fontFamily: 'Samim'),
            ),
            onTap: () {
              Navigator.pop(context); // بستن دراور
              if (!isLoggedIn) {
                showLoginRequiredBottomSheet(context, ref);
              } else {
                // تنظیم ایندکس روی عدد 5 (صفحه پرداختی‌ها)
                ref.read(bottomNavIndexProvider.notifier).state = 5;
              }
            },
          ),

          // اضافه کردن دکمه خروج اگر کاربر لاگین بود
          if (isLoggedIn) ...[
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              title: const Text(
                'خروج از حساب',
                style: TextStyle(fontFamily: 'Samim', color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        ],
      ),
    );
  }
}

// ==========================================
// ۳. نوار ناوبری پایین (Bottom Navigation)
// ==========================================
class MainBottomNav extends ConsumerWidget {
  const MainBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(bottomNavIndexProvider);

    // اینجا از پرووایدر اصلی که ساختیم وضعیت رو میخونیم
    final isLoggedIn = ref.watch(authProvider).isAuthenticated;

    void handleProtected(VoidCallback action) {
      if (isLoggedIn) {
        action();
      } else {
        showLoginRequiredBottomSheet(context, ref);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BottomNavShortcut(
            icon: Icons.home_filled,
            label: 'خانه',
            color: Colors.grey.shade400,
            isActive: currentTab == 0,
            onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 0,
          ),
          BottomNavShortcut(
            icon: Icons.chrome_reader_mode_outlined,
            label: 'دوره ها',
            color: Colors.grey.shade400,
            isActive: currentTab == 1,
            onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
          ),
          BottomNavShortcut(
            icon: Icons.image_rounded,
            label: 'گالری تصاویر',
            color: Colors.grey.shade400,
            isActive: currentTab == 2,
            onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 2,
          ),
          BottomNavShortcut(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'پرسش و پاسخ',
            color: Colors.grey.shade400,
            isActive: currentTab == 3,
            onTap: () => handleProtected(
              () => ref.read(bottomNavIndexProvider.notifier).state = 3,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// ۴. اپ‌بار اصلی (Main AppBar) - قابل استفاده در همه صفحات
// ==========================================
class MainAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;

  const MainAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider).isAuthenticated;

    final cartState = ref.watch(cartProvider);
    int cartItemCount = 0;

    if (isLoggedIn &&
        cartState.valueOrNull != null &&
        cartState.valueOrNull!['items'] != null) {
      cartItemCount = (cartState.valueOrNull!['items'] as List).length;
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: AppColors.primary,
                size: 26,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Samim',
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
      actions: [
        IconButton(
          // استفاده از ویجت Badge فلاتر برای نمایش دایره قرمز
          icon: Badge(
            isLabelVisible: cartItemCount > 0,
            // بج فقط زمانی که آیتم هست نمایش داده شود
            backgroundColor: Colors.redAccent,
            label: Text(
              cartItemCount.toString(),
              style: const TextStyle(
                fontFamily: 'Samim',
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          onPressed: () {
            if (isLoggedIn) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            } else {
              showLoginRequiredBottomSheet(context, ref);
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
