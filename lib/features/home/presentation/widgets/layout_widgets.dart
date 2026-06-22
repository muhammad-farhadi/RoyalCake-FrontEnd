import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/home_provider.dart';
import 'home_widgets.dart'; // برای BottomNavShortcut

// ==========================================
// ۱. پاپ‌آپ درخواست لاگین (متمرکز برای استفاده در همه جا)
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
                      Navigator.pop(context);
                      ref.read(authStateProvider.notifier).state =
                          true; // تغییر وضعیت لاگین از طریق ریورپاد
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'شما با موفقیت وارد شدید!',
                            style: TextStyle(fontFamily: 'Samim'),
                          ),
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
    final isLoggedIn = ref.watch(authStateProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // جایگزینی DrawerHeader محدود با Container منعطف و رسپانسیو
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: EdgeInsets.only(
              top:
                  MediaQuery.of(context).padding.top +
                  20, // ایجاد فاصله امن از نوار آنتن و باتری
              bottom: 20,
              left: 16,
              right: 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 34, // کمی بهینه‌تر برای سایزهای مختلف
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
                  isLoggedIn ? 'هنرجوی گرامی، خوش آمدید' : 'رویال کیک',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Samim',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isLoggedIn
                      ? 'مشاهده و مدیریت دوره‌ها'
                      : 'آکادمی تخصصی آموزش کیک و شیرینی',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontFamily: 'Samim',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8), // یک فاصله کوچک برای تنفس ظاهر منو

          ListTile(
            leading: const Icon(Icons.login_rounded, color: AppColors.primary),
            title: Text(
              isLoggedIn ? 'پروفایل کاربری' : 'ورود و ثبت‌نام',
              style: const TextStyle(
                fontFamily: 'Samim',
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              if (!isLoggedIn) showLoginRequiredBottomSheet(context, ref);
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
              Navigator.pop(context);
              if (!isLoggedIn) showLoginRequiredBottomSheet(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.bookmark_border_rounded,
              color: AppColors.primary,
            ),
            title: const Text(
              'علاقه‌مندی‌ها',
              style: TextStyle(fontFamily: 'Samim'),
            ),
            onTap: () {
              Navigator.pop(context);
              if (!isLoggedIn) showLoginRequiredBottomSheet(context, ref);
            },
          ),
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
    final isLoggedIn = ref.watch(authStateProvider);

    void handleProtected(VoidCallback action) {
      if (isLoggedIn)
        action();
      else
        showLoginRequiredBottomSheet(context, ref);
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
            label: 'Home',
            color: Colors.grey.shade400,
            isActive: currentTab == 0,
            onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 0,
          ),
          BottomNavShortcut(
            icon: Icons.chrome_reader_mode_outlined,
            label: 'Courses',
            color: Colors.grey.shade400,
            isActive: currentTab == 1,
            onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
          ),
          BottomNavShortcut(
            icon: Icons.image_rounded,
            label: 'Gallery',
            color: Colors.grey.shade400,
            isActive: currentTab == 2,
            onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 2,
          ),
          BottomNavShortcut(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Q&A',
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
