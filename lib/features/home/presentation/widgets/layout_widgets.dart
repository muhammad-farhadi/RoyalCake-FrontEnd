import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../orders/presentation/pages/cart_page.dart';
import '../../../orders/providers/cart_provider.dart';
import '../../../support/providers/chat_provider.dart';
import '../../providers/home_provider.dart';
import '../pages/about_us_page.dart';
import '../pages/app_tutorial_page.dart';
import 'home_widgets.dart'; // برای BottomNavShortcut
import '../../../auth/presentation/pages/login_page.dart'; // صفحه لاگین
import '../../../auth/providers/auth_provider.dart'; // ایمپورت پرووایدر جدید لاگین

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
// ۲. منوی کشویی (Drawer) - نسخه شکیل و طبقه‌بندی شده
// ==========================================
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isAuthenticated;
    final userInfo = authState.userInfo;

    final userName =
        userInfo?['full_name'] ?? 'کاربر مهمان'; // 🔴 نمایش هوشمند کاربر مهمان
    final userPhone =
        userInfo?['phone_number'] ?? 'آکادمی تخصصی آموزش کیک و شیرینی';

    // تابع کمکی برای بستن دراور و رفتن به تب‌های اصلی لایوت پایین صفحه
    void switchToTab(int index) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      ref.read(bottomNavIndexProvider.notifier).state = index;
    }

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ------------ هدر شیک و مدرن دراور ------------
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.lightBg,
                    backgroundImage: AssetImage(
                      isLoggedIn
                          ? 'assets/images/user_avatar.png'
                          : 'assets/images/logo.png',
                    ),
                    child: isLoggedIn
                        ? null
                        : const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primary,
                            size: 32,
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Samim',
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  userPhone,
                  textDirection: isLoggedIn
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: 'Samim',
                    fontSize: 12,
                    letterSpacing: isLoggedIn ? 0.5 : 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ------------ ۱. دراپ‌داون اطلاعات شخصی ------------
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            // حذف خطوط جداکننده پیش‌فرض
            child: ExpansionTile(
              leading: const Icon(
                Icons.account_circle_outlined,
                color: Colors.blueAccent,
                size: 24,
              ),
              title: const Text(
                'اطلاعات شخصی',
                style: TextStyle(
                  fontFamily: 'Samim',
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              iconColor: AppColors.primary,
              childrenPadding: const EdgeInsets.only(right: 16),
              // راست‌چین کردن زیرمنوها
              children: [
                if (!isLoggedIn)
                  ListTile(
                    leading: const Icon(
                      Icons.login_rounded,
                      color: Colors.blue,
                      size: 20,
                    ),
                    title: const Text(
                      'ورود یا ثبت‌نام',
                      style: TextStyle(fontFamily: 'Samim', fontSize: 13),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                  ),
                if (isLoggedIn) ...[
                  ListTile(
                    leading: const Icon(
                      Icons.badge_outlined,
                      color: Colors.teal,
                      size: 20,
                    ),
                    title: const Text(
                      'مشاهده پروفایل کاربری',
                      style: TextStyle(fontFamily: 'Samim', fontSize: 13),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: روت پروفایل در آینده
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    title: const Text(
                      'خروج از حساب کاربری',
                      style: TextStyle(
                        fontFamily: 'Samim',
                        fontSize: 13,
                        color: Colors.redAccent,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(authProvider.notifier).logout();
                    },
                  ),
                ],
              ],
            ),
          ),

          // ------------ ۲. دراپ‌داون آموزش و یادگیری ------------
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: const Icon(
                Icons.school_outlined,
                color: Colors.amber,
                size: 24,
              ),
              title: const Text(
                'یادگیری و آکادمی',
                style: TextStyle(
                  fontFamily: 'Samim',
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              iconColor: AppColors.primary,
              childrenPadding: const EdgeInsets.only(right: 16),
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.auto_stories_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  title: const Text(
                    'دوره‌های من',
                    style: TextStyle(fontFamily: 'Samim', fontSize: 13),
                  ),
                  onTap: () {
                    if (!isLoggedIn) {
                      Navigator.pop(context);
                      showLoginRequiredBottomSheet(context, ref);
                    } else {
                      switchToTab(4); // تب دوره‌های من
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.article_outlined,
                    color: Colors.deepOrangeAccent,
                    size: 20,
                  ),
                  title: const Text(
                    'مقالات آموزشی و وبلاگ',
                    style: TextStyle(fontFamily: 'Samim', fontSize: 13),
                  ),
                  onTap: () async {
                    Navigator.pop(context); // بستن دراور
                    final Uri url = Uri.parse('https://royalcakes.ir/blog');

                    // باز کردن وبلاگ به صورت امن در مرورگر خارجی گوشی
                    if (!await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    )) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'خطا در باز کردن وبلاگ رویال کیک',
                              style: TextStyle(fontFamily: 'Samim'),
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.workspace_premium_outlined,
                    color: Colors.purpleAccent,
                    size: 20,
                  ),
                  title: const Text(
                    'نتایج و کارهای هنرجویان',
                    style: TextStyle(fontFamily: 'Samim', fontSize: 13),
                  ),
                  onTap: () => switchToTab(6), // تب نظرات و نتایج هنرجویان
                ),
              ],
            ),
          ),

          // ------------ ۳. دراپ‌داون مالی و خرید ------------
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              title: const Text(
                'مالی و خریدها',
                style: TextStyle(
                  fontFamily: 'Samim',
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              iconColor: AppColors.primary,
              childrenPadding: const EdgeInsets.only(right: 16),
              children: [
                ListTile(
                  leading: Icon(
                    Icons.shopping_cart_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  title: const Text(
                    'سبد خرید من',
                    style: TextStyle(fontFamily: 'Samim', fontSize: 13),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (isLoggedIn) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    } else {
                      showLoginRequiredBottomSheet(context, ref);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.receipt_long_outlined,
                    color: Colors.lightGreen,
                    size: 20,
                  ),
                  title: const Text(
                    'لیست پرداخت‌های قبلی',
                    style: TextStyle(fontFamily: 'Samim', fontSize: 13),
                  ),
                  onTap: () {
                    if (!isLoggedIn) {
                      Navigator.pop(context);
                      showLoginRequiredBottomSheet(context, ref);
                    } else {
                      switchToTab(5); // تب فاکتورها و تراکنش‌ها
                    }
                  },
                ),
              ],
            ),
          ),

          // ------------ ۴. دراپ‌داون ارتباطات و راهنما ------------
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: const Icon(
                Icons.contact_support_outlined,
                color: Colors.teal,
                size: 24,
              ),
              title: const Text(
                'راه‌های ارتباطی و راهنما',
                style: TextStyle(
                  fontFamily: 'Samim',
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              iconColor: AppColors.primary,
              childrenPadding: const EdgeInsets.only(right: 16),
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.teal,
                    size: 20,
                  ),
                  title: const Text(
                    'چت آنلاین با پشتیبانی',
                    style: TextStyle(fontFamily: 'Samim', fontSize: 13),
                  ),
                  onTap: () {
                    if (!isLoggedIn) {
                      Navigator.pop(context);
                      showLoginRequiredBottomSheet(context, ref);
                    } else {
                      switchToTab(3); // تب چت زنده
                      ref.read(chatProvider.notifier).markAsRead();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.smart_display_outlined,
                    color: Colors.pinkAccent,
                    size: 20,
                  ),
                  title: const Text(
                    'آموزش کار با اپلیکیشن',
                    style: TextStyle(fontFamily: 'Samim', fontSize: 13),
                  ),
                  onTap: () {
                    Navigator.pop(context); // بستن دراور

                    // هدایت مستقیم و بسیار شکیل به صفحه آموزش دکمه شیر و هوم اسکرین آیفون
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppTutorialPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.cyan,
                    size: 20,
                  ),
                  title: const Text(
                    'درباره ما و شبکه‌های اجتماعی',
                    style: TextStyle(fontFamily: 'Samim', fontSize: 13),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutUsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
    final isLoggedIn = ref.watch(authProvider).isAuthenticated;

    final unreadCount = ref.watch(
      chatProvider.select((state) => state.unreadCount),
    );

    void handleProtected(VoidCallback action) {
      if (isLoggedIn) {
        action();
      } else {
        showLoginRequiredBottomSheet(context, ref);
      }
    }

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
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
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BottomNavShortcut(
              icon: Icons.home_filled,
              label: 'خانه',
              color: Colors.grey.shade400,
              isActive: currentTab == 0,
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                ref.read(courseFilterProvider.notifier).state = null;
                ref.read(bottomNavIndexProvider.notifier).state = 0;
              },
            ),
            BottomNavShortcut(
              icon: Icons.chrome_reader_mode_outlined,
              label: 'دوره ها',
              color: Colors.grey.shade400,
              isActive: currentTab == 1,
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                ref.read(courseFilterProvider.notifier).state = null;
                ref.read(bottomNavIndexProvider.notifier).state = 1;
              },
            ),
            BottomNavShortcut(
              icon: Icons.rate_review_outlined,
              label: 'نتایج هنرجویان',
              color: Colors.grey.shade400,
              isActive: currentTab == 6,
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                ref.read(bottomNavIndexProvider.notifier).state = 6;
              },
            ),
            BottomNavShortcut(
              icon: Icons.image_rounded,
              label: 'گالری',
              color: Colors.grey.shade400,
              isActive: currentTab == 2,
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                ref.read(bottomNavIndexProvider.notifier).state = 2;
              },
            ),
            Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(
                unreadCount.toString(),
                style: const TextStyle(fontFamily: 'Samim', fontSize: 10),
              ),
              backgroundColor: Colors.redAccent,
              offset: const Offset(-8, -4),
              child: BottomNavShortcut(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'پشتیبانی',
                color: Colors.grey.shade400,
                isActive: currentTab == 3,
                onTap: () => handleProtected(() {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  ref.read(bottomNavIndexProvider.notifier).state = 3;
                  ref.read(chatProvider.notifier).markAsRead();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ۴. اپ‌بار اصلی (Main AppBar) - با پشتیبانی از دکمه لیدینگ سفارشی
// ==========================================
class MainAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading; // 🔴 اضافه شدن فلگ لیدینگ دلخواه

  const MainAppBar({
    super.key,
    required this.title,
    this.leading, // 🔴 مقداردهی لیدینگ
  });

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
          // 🔴 نمایش لیدینگ سفارشی (مثل دکمه بازگشت در گالری) یا منوی کشویی پیش‌فرض همبرگری
          leading ??
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
          icon: Badge(
            isLabelVisible: cartItemCount > 0,
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
