import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../gallery/presentation/pages/gallery_page.dart';
import '../../../courses/presentation/pages/courses_page.dart';
import '../../providers/home_provider.dart';
import '../widgets/layout_widgets.dart'; // حاوی Drawer، BottomNav و AuthSheet
import 'dashboard_view.dart'; // حاوی محتوای اصلی داشبورد

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // گرفتن تب فعال از پرووایدر مرکزی
    final currentTab = ref.watch(bottomNavIndexProvider);
    final isLoggedIn = ref.watch(authStateProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,

        // ۱. منوی کناری تفکیک شده
        drawer: const AppDrawer(),

        // ۲. اپ‌بار اصلی
        appBar: AppBar(
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
                    currentTab == 2
                        ? 'گالری هنرجویان'
                        : currentTab == 1
                        ? 'دوره‌های آموزشی'
                        : 'رویال کیک',
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
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              onPressed: () {
                if (isLoggedIn) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'در حال انتقال به سبد خرید...',
                        style: TextStyle(fontFamily: 'Samim'),
                      ),
                    ),
                  );
                } else {
                  showLoginRequiredBottomSheet(context, ref);
                }
              },
            ),
          ],
        ),

        // ۳. بدنه اصلی با روتینگ داخلی هوشمند
        body: currentTab == 2
            ? const GalleryPage()
            : currentTab == 1
            ? const CoursesPage()
            : const DashboardView(),

        // ۴. نوار ناوبری تفکیک شده
        bottomNavigationBar: const MainBottomNav(),
      ),
    );
  }
}
