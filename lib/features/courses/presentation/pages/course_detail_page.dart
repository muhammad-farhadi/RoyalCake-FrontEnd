import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/layout_widgets.dart';
import '../../../orders/providers/cart_provider.dart';
import '../../providers/course_detail_provider.dart';
import '../../../auth/providers/auth_provider.dart'; // اضافه شدن پرووایدر احراز هویت

class CourseDetailPage extends ConsumerWidget {
  final int courseId;

  const CourseDetailPage({super.key, required this.courseId});

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

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) return '$h ساعت و $m دقیقه';
    return '$m دقیقه';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseState = ref.watch(courseDetailProvider(courseId));

    // --- بررسی وضعیت خرید دوره توسط کاربر ---
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isAuthenticated;

    bool isPurchased = false;
    if (isLoggedIn) {
      final myCoursesState = ref.watch(myCoursesProvider);
      myCoursesState.whenData((courses) {
        // بررسی وجود آیدی این دوره در لیست دوره‌های خریداری شده کاربر
        isPurchased = courses.any((c) => c['course_id'] == courseId);
      });
    }
    // ----------------------------------------

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,

        // --- اعمال اجزای سراسری سایت به این صفحه ---
        appBar: const MainAppBar(title: 'جزئیات دوره'),
        drawer: const AppDrawer(),
        bottomNavigationBar: const MainBottomNav(),

        // ------------------------------------------
        body: Column(
          children: [
            // بخش محتوای اسکرول‌شونده دوره
            Expanded(
              child: courseState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, stack) => const Center(
                  child: Text(
                    'خطا در دریافت اطلاعات',
                    style: TextStyle(fontFamily: 'Samim'),
                  ),
                ),
                data: (course) {
                  final fullImageUrl = AppConstants.getFullImageUrl(
                    course['image_url'],
                  );
                  final lessons = List<dynamic>.from(course['lessons'] ?? []);

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // جایگزینی SliverAppBar با هدر عکس
                      SliverToBoxAdapter(
                        child: Stack(
                          children: [
                            Image.network(
                              fullImageUrl,
                              height: 260,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              height: 260,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.5),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            // دکمه بازگشت روی عکس
                            Positioned(
                              top: 16,
                              right: 16,
                              child: IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // محتوای اصلی دوره
                      SliverToBoxAdapter(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.lightBg,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _buildBadge(
                                      Icons.trending_up_rounded,
                                      course['level'] ?? 'مبتدی تا پیشرفته',
                                      AppColors.accent,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildBadge(
                                      Icons.category_outlined,
                                      course['category'] ?? 'کیک',
                                      Colors.orange,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  course['title'] ?? 'بدون عنوان',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Samim',
                                    color: AppColors.darkText,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatBox(
                                        Icons.play_circle_outline,
                                        '${course['session_count'] ?? 0}',
                                        'جلسه آموزشی',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatBox(
                                        Icons.access_time_rounded,
                                        '${course['total_hours'] ?? 0}',
                                        'ساعت آموزش',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'درباره این دوره',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Samim',
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  course['description'] ??
                                      'توضیحاتی برای این دوره ثبت نشده است.',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                    fontFamily: 'Samim',
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                const Text(
                                  'سرفصل‌های دوره',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Samim',
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (lessons.isEmpty)
                                  const Text(
                                    'هنوز جلسه‌ای برای این دوره آپلود نشده است.',
                                    style: TextStyle(
                                      fontFamily: 'Samim',
                                      color: Colors.black45,
                                    ),
                                  )
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: lessons.length,
                                    itemBuilder: (context, index) {
                                      final lesson = lessons[index];
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '${lesson['sort_order'] ?? index + 1}',
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Samim',
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            lesson['title'] ?? 'جلسه',
                                            style: const TextStyle(
                                              fontFamily: 'Samim',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: AppColors.darkText,
                                            ),
                                          ),
                                          subtitle: Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time,
                                                size: 14,
                                                color: Colors.black45,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatDuration(
                                                  lesson['duration'] ?? 0,
                                                ),
                                                style: const TextStyle(
                                                  fontFamily: 'Samim',
                                                  fontSize: 11,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // --- نوار چسبان ثبت نام ---
            courseState.maybeWhen(
              data: (course) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  // اگر خریداری شده بود این بخش، در غیر این صورت دکمه خرید
                  child: isPurchased
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: const Text(
                            'شما دانشجوی این دوره هستید ✔',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Samim',
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'مبلغ سرمایه‌گذاری:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                    fontFamily: 'Samim',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatPrice(course['price']),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    fontFamily: 'Samim',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'در حال افزودن...',
                                        style: TextStyle(fontFamily: 'Samim'),
                                      ),
                                    ),
                                  );
                                  try {
                                    final success = await ref
                                        .read(cartProvider.notifier)
                                        .addToCart(courseId);
                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text(
                                            'به سبد خرید اضافه شد.',
                                            style: TextStyle(
                                              fontFamily: 'Samim',
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.redAccent,
                                          content: Text(
                                            e.toString().replaceAll(
                                              'Exception: ',
                                              '',
                                            ),
                                            style: const TextStyle(
                                              fontFamily: 'Samim',
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'ثبت‌نام در دوره',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Samim',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'Samim',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(IconData icon, String value, String title) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Samim',
                  color: AppColors.darkText,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                  fontFamily: 'Samim',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
