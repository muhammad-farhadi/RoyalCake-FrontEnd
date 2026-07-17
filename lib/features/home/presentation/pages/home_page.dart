import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../courses/presentation/pages/course_reviews_page.dart';
import '../../../courses/presentation/pages/my_courses_page.dart';
import '../../../gallery/presentation/pages/gallery_page.dart';
import '../../../courses/presentation/pages/courses_page.dart';
import '../../../orders/presentation/pages/my_payments_page.dart';
import '../../../support/presentation/pages/support_chat_page.dart';
import '../../providers/home_provider.dart';
import '../widgets/layout_widgets.dart';
import 'dashboard_view.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // 🔴 مخزن تاریخچه حرکت کاربر بین تب‌ها (شروع از تب صفر/خانه)
  final List<int> _tabHistory = [0];

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(bottomNavIndexProvider);

    // 🔴 شنود هوشمند تغییرات نوار ناوبری برای ثبت دقیق مسیر کاربر در تاریخچه
    ref.listen<int>(bottomNavIndexProvider, (previous, next) {
      if (_tabHistory.isEmpty || _historyLast() != next) {
        _tabHistory.add(next);
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: currentTab == 0 && _tabHistory.length <= 1,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          if (_tabHistory.length > 1) {
            setState(() {
              _tabHistory.removeLast();
              final previousTab = _tabHistory.last;
              ref.read(bottomNavIndexProvider.notifier).state = previousTab;
            });
          } else if (currentTab != 0) {
            ref.read(bottomNavIndexProvider.notifier).state = 0;
            _tabHistory.clear();
            _tabHistory.add(0);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.lightBg,
          appBar: MainAppBar(
            title: currentTab == 5
                ? 'پرداختی‌های من'
                : currentTab == 4
                ? 'دوره‌های من'
                : currentTab == 2
                ? 'گالری هنرجویان'
                : currentTab == 1
                ? 'دوره‌های آموزشی'
                : 'رویال کیک',

            // 🔴 فقط و فقط برای تب گالری (تب شماره ۲) دکمه بازگشتِ شکیل به خانه تزریق می‌شود
            leading: currentTab == 2
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      // فلش بازگشت راست‌چین شیک متناسب با لایوت RTL فارسی
                      color: AppColors.primary,
                      size: 22,
                    ),
                    onPressed: () {
                      // برگشتن به صفحه خانه (داشبورد)
                      ref.read(bottomNavIndexProvider.notifier).state = 0;
                    },
                  )
                : null, // برای بقیه صفحات مقدار null فرستاده می‌شود تا منوی همبرگری کشویی کار کند
          ),
          drawer: const AppDrawer(),
          body: currentTab == 6
              ? const CourseReviewsPage()
              : currentTab == 5
              ? const MyPaymentsPage()
              : currentTab == 4
              ? const MyCoursesPage()
              : currentTab == 3
              ? const SupportChatPage()
              : currentTab == 2
              ? const GalleryPage()
              : currentTab == 1
              ? const CoursesPage()
              : const DashboardView(),
          bottomNavigationBar: const MainBottomNav(),
        ),
      ),
    );
  }

  int _historyLast() {
    return _tabHistory.isNotEmpty ? _tabHistory.last : 0;
  }
}
