import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/course_detail_provider.dart';

class CourseDetailPage extends ConsumerWidget {
  final int courseId; // دریافت آیدی دوره در زمان هدایت به این صفحه

  const CourseDetailPage({super.key, required this.courseId});

  // تابع کمکی برای فرمت قیمت (مشابه چیزی که قبلا داشتیم)
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

  // تبدیل دقیقه به فرمت خوانا (مثلا 150 دقیقه -> ۲ ساعت و ۳۰ دقیقه)
  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) return '$h ساعت و $m دقیقه';
    return '$m دقیقه';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // فراخوانی پرووایدر با پاس دادن ID دوره
    final courseState = ref.watch(courseDetailProvider(courseId));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        body: courseState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 50,
                ),
                const SizedBox(height: 16),
                const Text(
                  'خطا در دریافت اطلاعات دوره',
                  style: TextStyle(fontFamily: 'Samim', fontSize: 16),
                ),
                TextButton(
                  onPressed: () => ref.refresh(courseDetailProvider(courseId)),
                  child: const Text(
                    'تلاش مجدد',
                    style: TextStyle(fontFamily: 'Samim'),
                  ),
                ),
              ],
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
                // ================= ۱. هدر متحرک (SliverAppBar) =================
                SliverAppBar(
                  expandedHeight: 280.0,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
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
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(fullImageUrl, fit: BoxFit.cover),
                        // گرادینت تیره برای خوانایی بهتر نوار بالا و پایین عکس
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.6),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.5),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ================= ۲. محتوای اصلی دوره =================
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.lightBg,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                    // کشیدن کانتینر روی عکس
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // تگ‌های بالای عنوان (سطح و دسته‌بندی)
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

                          // عنوان دوره
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

                          // اطلاعات آماری دوره (باکس‌های خاکستری)
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

                          // توضیحات دوره
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

                          // سرفصل‌ها (جلسات)
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
                              physics: const NeverScrollableScrollPhysics(),
                              // اسکرول توسط اسکرول اصلی صفحه انجام می‌شود
                              itemCount: lessons.length,
                              itemBuilder: (context, index) {
                                final lesson = lessons[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
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
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Row(
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
                                    trailing: lesson['is_free'] == true
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'رایگان',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 10,
                                                fontFamily: 'Samim',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.lock_outline_rounded,
                                            color: Colors.black26,
                                            size: 20,
                                          ),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 80),
                          // فضای خالی برای جلوگیری از رفتن محتوا زیر نوار پایین
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // ================= ۳. نوار ثابت ثبت‌نام در پایین صفحه =================
        bottomNavigationBar: courseState.maybeWhen(
          data: (course) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
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
                      onPressed: () {
                        // منطق افزودن به سبد خرید
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'دوره به سبد خرید اضافه شد.',
                              style: TextStyle(fontFamily: 'Samim'),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
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
      ),
    );
  }

  // ویجت کمکی برای تگ‌های کوچک
  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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

  // ویجت کمکی برای باکس‌های آماری
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
