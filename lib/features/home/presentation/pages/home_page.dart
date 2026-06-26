import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../courses/presentation/pages/my_courses_page.dart';
import '../../../gallery/presentation/pages/gallery_page.dart';
import '../../../courses/presentation/pages/courses_page.dart';
import '../../../orders/presentation/pages/my_payments_page.dart';
import '../../providers/home_provider.dart';
import '../widgets/layout_widgets.dart'; // حاوی Drawer، BottomNav، AuthSheet و MainAppBar
import 'dashboard_view.dart'; // حاوی محتوای اصلی داشبورد

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(bottomNavIndexProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        appBar: MainAppBar(
          title: currentTab == 5
              ? 'پرداختی‌های من'     // <--- اضافه شدن شرط تب 5
              : currentTab == 4
              ? 'دوره‌های من'
              : currentTab == 2
              ? 'گالری هنرجویان'
              : currentTab == 1
              ? 'دوره‌های آموزشی'
              : 'رویال کیک',
        ),
        drawer: const AppDrawer(),
        body: currentTab == 5
            ? const MyPaymentsPage() // <--- نمایش صفحه پرداختی‌ها در تب 5
            : currentTab == 4
            ? const MyCoursesPage()
            : currentTab == 2
            ? const GalleryPage()
            : currentTab == 1
            ? const CoursesPage()
            : const DashboardView(),
        bottomNavigationBar: const MainBottomNav(),
      ),
    );
  }
}