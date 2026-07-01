import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../courses/presentation/pages/course_detail_page.dart';
import '../../../gallery/presentation/pages/gallery_page.dart';
import '../widgets/home_widgets.dart';
import '../../providers/home_provider.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const BannerSlider(),

          // بخش ویژگی‌های رویال کیک
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FeatureItem(
                  icon: Icons.verified_user_outlined,
                  title: 'اصالت طعم و کیفیت',
                ),
                FeatureItem(
                  icon: Icons.support_agent_rounded,
                  title: 'پشتیبانی دائمی',
                ),
                FeatureItem(
                  icon: Icons.workspace_premium_outlined,
                  title: 'اساتید مجرب',
                ),
              ],
            ),
          ),

          // ===================================================================
          // جایگزینی بخش "دسته بندی محبوب" با ساختار وب‌سایت (intro-courses-section)
          // ===================================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            color: Colors.white, // background-color: #ffffff;
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // استفاده از Center و Row جهت وسط‌چین کردن کامل دایره‌ها در انواع موبایل
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // وسط‌چین کردن المان‌های داخل سطر
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIntroCourseItem(
                          imageUrl: '/static/img/20230829_150959_E3E8C2F7-32A7-47DB-B707-8A377F5B7F2D.webp',
                          title: 'آموزش رایگان',
                          ref: ref,
                        ),
                        _buildIntroCourseItem(
                          imageUrl: '/static/img/20230829_151140_89E97E06-CE04-4BBA-9BFB-9E110BC9FEC8.webp',
                          title: 'دوره کیک و کوکی',
                          ref: ref,
                        ),
                        _buildIntroCourseItem(
                          imageUrl: '/static/img/20230829_153101_E074A852-5758-4302-B7E0-203B36B34DCD.webp',
                          title: 'دوره چیز کیک',
                          ref: ref,
                        ),
                        _buildIntroCourseItem(
                          imageUrl: '/static/img/20230829_095147_72A432F7-3E40-48F7-A618-4FFCBC50095B.webp',
                          title: 'دوره شیرینی نوروز',
                          ref: ref,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25), // margin-top: 25px;

                // دکمه نمایش دوره‌ها (intro-btn-container) کاملاً وسط‌چین شده
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(bottomNavIndexProvider.notifier).state = 1;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      elevation: 4,
                      shadowColor: AppColors.accent.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'نمایش دوره‌ها',
                      style: TextStyle(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'آخرین دوره‌ها',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Samim',
                    color: AppColors.darkText,
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      ref.read(bottomNavIndexProvider.notifier).state = 1,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.accent,
                  ),
                  label: const Text(
                    'مشاهده همه',
                    style: TextStyle(
                      fontFamily: 'Samim',
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: ref
                .watch(coursesProvider)
                .when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (error, stack) => const Center(
                    child: Text(
                      'خطا در بارگذاری دوره‌ها',
                      style: TextStyle(fontFamily: 'Samim'),
                    ),
                  ),
                  data: (courses) {
                    if (courses.isEmpty) {
                      return const Center(
                        child: Text(
                          'دوره‌ای یافت نشد',
                          style: TextStyle(fontFamily: 'Samim'),
                        ),
                      );
                    }
                    return ScrollConfiguration(
                      behavior: AppScrollBehavior(),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: courses.length + 1,
                        itemBuilder: (context, index) {
                          if (index == courses.length) {
                            return Container(
                              width: 140,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () =>
                                    ref
                                            .read(
                                              bottomNavIndexProvider.notifier,
                                            )
                                            .state =
                                        1,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'مشاهده\nهمه دوره‌ها',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Samim',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          final course = courses[index];
                          return CourseCard(
                            title: course['title'] ?? '',
                            price: formatPrice(course['price']),
                            imageUrl: course['image_url'] ?? '',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CourseDetailPage(courseId: course['id']),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
          ),

          // بخش گالری تصاویر رویال کیک
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'گالری رویال کیک',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Samim',
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      ref.read(bottomNavIndexProvider.notifier).state = 2,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.accent,
                  ),
                  label: const Text(
                    'مشاهده همه',
                    style: TextStyle(
                      fontFamily: 'Samim',
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 110,
            child: Builder(
              builder: (context) {
                final galleryState = ref.watch(galleryProvider);
                if (galleryState.isLoading && galleryState.images.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (galleryState.images.isEmpty) {
                  return const Center(
                    child: Text(
                      'تصویری یافت نشد',
                      style: TextStyle(fontFamily: 'Samim'),
                    ),
                  );
                }
                final displayImages = galleryState.images.take(10).toList();
                return ScrollConfiguration(
                  behavior: AppScrollBehavior(),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: displayImages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == displayImages.length) {
                        return Container(
                          width: 110,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () =>
                                ref
                                        .read(bottomNavIndexProvider.notifier)
                                        .state =
                                    2,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'مشاهده\nهمه تصاویر',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Samim',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      final image = displayImages[index];
                      final fullImageUrl = AppConstants.getFullImageUrl(
                        image['image_url'],
                      );
                      final title = image['title'] ?? image['alt_text'] ?? '';
                      final homeHeroTag =
                          'home_gallery_image_${image['id'] ?? index}';
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (context, _, __) =>
                                FullScreenImageViewer(
                                  imageUrl: fullImageUrl,
                                  title: title,
                                  heroTag: homeHeroTag,
                                ),
                            transitionsBuilder: (context, anim, __, child) =>
                                FadeTransition(opacity: anim, child: child),
                          ),
                        ),
                        child: Container(
                          width: 110,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Hero(
                              tag: homeHeroTag,
                              child: Image.network(
                                fullImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        color: Colors.black26,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 35),
        ],
      ),
    );
  }

  // متد کمکی برای ساخت تر تمیز آیتم‌های دایره‌ای وب‌سایت (intro-course-item)
  // متد اصلاح شده و کاملاً ریسپانسیو برای دایره‌های معرفی دوره‌ها
  Widget _buildIntroCourseItem({
    required String imageUrl,
    required String title,
    required WidgetRef ref,
  }) {
    // گرفتن آدرس کامل عکس‌ها به همراه بیس‌یوآرال سرور شما
    final fullUrl = AppConstants.getFullImageUrl(imageUrl);

    return Builder(
        builder: (context) {
          // محاسبه عرض صفحه برای ریسپانسیو کردن ابعاد دایره‌ها
          final screenWidth = MediaQuery.of(context).size.width;

          // اندازه دایره به صورت پویا بین ۲۰ تا ۲۲ درصد عرض صفحه تنظیم می‌شود
          // همچنین با استفاده از .clamp یک حداقل و حداکثر اندازه (بین 75 تا 1400) تعیین شده تا در تبلت یا ویندوز دفرمه نشود
          final circleSize = (screenWidth * 0.21).clamp(75.0, 140.0);

          // فاصله افقی بین آیتم‌ها نیز بر اساس عرض صفحه تنظیم می‌شود
          final horizontalPadding = (screenWidth * 0.02).clamp(6.0, 16.0);

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // دایره با ابعاد کاملاً ریسپانسیو
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accent, // لبه صورتی رنگ مانند سایت
                      width: circleSize * 0.03, // ضخامت بوردر هم متناسب با سایز دایره تغییر می‌کند
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      fullUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary
                          ),
                        );
                      },
                      errorBuilder: (context, error, stack) =>
                      const Icon(Icons.broken_image_outlined, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // عنوان دایره با سایز فونت بهینه‌شده برای موبایل
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary, // رنگ سبز اصلی
                    fontFamily: 'Samim',
                  ),
                ),
              ],
            ),
          );
        }
    );
  }
}

// کامپوننت کمکی جهت عدم تداخل در بریدگی مرزهای دایره تصویر
class ClipOAuth extends StatelessWidget {
  final Widget child;

  const ClipOAuth({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _bannerController = PageController(initialPage: 0);
  int _currentBannerPage = 0;
  Timer? _bannerTimer;

  final List<Map<String, String>> _banners = [
    {
      'title': 'دوره جامع چیزکیک',
      'subtitle': 'آموزش تخصصی منوی کافی‌شاپ',
      'image': 'assets/images/banner5.png',
    },
    {
      'title': 'دوره کیک‌های خامه ای',
      'subtitle': 'مدرن و اصول دکوراتوری کیک',
      'image': 'assets/images/banner2.png',
    },
    {
      'title': 'آموزش شیرینی‌های مدرن',
      'subtitle': 'ویژه عید و کسب درآمد خانگی',
      'image': 'assets/images/banner6.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentBannerPage < _banners.length - 1) {
        _currentBannerPage++;
      } else {
        _currentBannerPage = 0;
      }
      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          _currentBannerPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _bannerController,
              itemCount: _banners.length,
              onPageChanged: (index) =>
                  setState(() => _currentBannerPage = index),
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        Image.asset(
                          _banners[index]['image']!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.65),
                                Colors.black.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 24,
                          bottom: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _banners[index]['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Samim',
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _banners[index]['subtitle']!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontFamily: 'Samim',
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 5,
                width: _currentBannerPage == index ? 16 : 5,
                decoration: BoxDecoration(
                  color: _currentBannerPage == index
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
