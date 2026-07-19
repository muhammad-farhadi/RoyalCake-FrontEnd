import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart'; // برای kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../courses/presentation/pages/course_detail_page.dart';
import '../../../gallery/presentation/pages/fullScreenPage.dart';
import '../../../gallery/presentation/pages/gallery_page.dart';
import '../../../gallery/presentation/pages/universal_image.dart';
import '../../providers/banners_provider.dart';
import '../widgets/highlights_bar.dart';
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
          const HighlightsBar(),
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
              ],
            ),
          ),

          // ===================================================================
          // بخش دایره‌های دسته‌بندی وب‌سایت (intro-courses-section)
          // ===================================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔴 دایره آموزش رایگان -> اتصال به آیدی 13
                        _buildIntroCourseItem(
                          imageUrl:
                              '/static/img/20230829_150959_E3E8C2F7-32A7-47DB-B707-8A377F5B7F2D.webp',
                          title: 'آموزش رایگان',
                          ref: ref,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CourseDetailPage(courseId: 13),
                              ),
                            );
                          },
                        ),
                        // 🔴 دایره کیک و کوکی -> اتصال به آیدی 10
                        _buildIntroCourseItem(
                          imageUrl:
                              '/static/img/20230829_151140_89E97E06-CE04-4BBA-9BFB-9E110BC9FEC8.webp',
                          title: 'دوره کیک و کوکی',
                          ref: ref,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CourseDetailPage(courseId: 10),
                              ),
                            );
                          },
                        ),
                        // 🔴 دایره چیزکیک -> اتصال به آیدی 11
                        _buildIntroCourseItem(
                          imageUrl:
                              '/static/img/20230829_153101_E074A852-5758-4302-B7E0-203B36B34DCD.webp',
                          title: 'دوره چیز کیک',
                          ref: ref,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CourseDetailPage(courseId: 11),
                              ),
                            );
                          },
                        ),
                        // 🔴 دایره شیرینی نوروز -> اتصال به آیدی 9
                        _buildIntroCourseItem(
                          imageUrl:
                              '/static/img/20230829_095147_72A432F7-3E40-48F7-A618-4FFCBC50095B.webp',
                          title: 'دوره شیرینی نوروز',
                          ref: ref,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CourseDetailPage(courseId: 9),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(courseFilterProvider.notifier).state = null;
                      ref.read(bottomNavIndexProvider.notifier).state = 1;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
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

          // ردیف دوره‌های تخصصی (پولی) روی داشبورد
          _buildCourseSection(
            title: 'آخرین دوره‌های تخصصی',
            coursesState: ref.watch(homePaidCoursesProvider),
            context: context,
            onShowAll: () {
              ref.read(courseFilterProvider.notifier).state = false;
              ref.read(bottomNavIndexProvider.notifier).state = 1;
            },
          ),

          const SizedBox(height: 16),

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
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
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
                        onTap: () {
                          if (kIsWeb)
                            PaintingBinding.instance.imageCache.clear();
                          Navigator.push(
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
                          );
                        },
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
                              child: UniversalImage(
                                imageUrl: fullImageUrl,
                                fit: BoxFit.cover,
                                cacheWidth: 200,
                                errorWidget: const Center(
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

  Widget _buildCourseSection({
    required String title,
    required AsyncValue<List<dynamic>> coursesState,
    required VoidCallback onShowAll,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Samim',
                  color: AppColors.darkText,
                ),
              ),
              TextButton.icon(
                onPressed: onShowAll,
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
          child: coursesState.when(
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
                    'دوره‌ای در این بخش یافت نشد',
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
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: onShowAll,
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
                    final bool isDiscount =
                        course['is_discount_active'] == true;

                    return CourseCard(
                      title: course['title'] ?? '',
                      // قیمت اصلی نمایش داده شده (اگر تخفیف فعال بود، قیمت تخفیف خورده ارسال می‌شود)
                      price: isDiscount
                          ? formatPrice(course['final_price'])
                          : formatPrice(course['price']),
                      oldPrice: formatPrice(course['price']),
                      isDiscountActive: isDiscount,
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
      ],
    );
  }

  Widget _buildIntroCourseItem({
    required String imageUrl,
    required String title,
    required WidgetRef ref,
    VoidCallback? onTap,
  }) {
    final fullUrl = AppConstants.getFullImageUrl(imageUrl);

    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final circleSize = (screenWidth * 0.21).clamp(75.0, 140.0);
        final horizontalPadding = (screenWidth * 0.02).clamp(6.0, 16.0);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(100),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accent,
                      width: circleSize * 0.03,
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
                    child: UniversalImage(
                      imageUrl: fullUrl,
                      fit: BoxFit.cover,
                      cacheWidth: 250,
                      errorWidget: const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFamily: 'Samim',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BannerSlider extends ConsumerStatefulWidget {
  const BannerSlider({super.key});

  @override
  ConsumerState<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends ConsumerState<BannerSlider> {
  final PageController _bannerController = PageController(initialPage: 0);
  int _currentBannerPage = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    // راه‌اندازی تایمر چرخشی هوشمند و هماهنگ با دیتای پویای سرور
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      // خواندن تعداد بنرهای لود شده در لحظه بدون خراب کردن initState
      final bannersValue = ref.read(bannersProvider).valueOrNull;
      if (bannersValue == null || bannersValue.isEmpty) return;

      if (_currentBannerPage < bannersValue.length - 1) {
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
    // گوش به زنگ بودن برای دریافت بنرهای پویا از سرور
    final bannersState = ref.watch(bannersProvider);

    return SizedBox(
      height: 260,
      child: bannersState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => const Center(
          child: Text(
            'خطا در بارگذاری بنرها',
            style: TextStyle(
              fontFamily: 'Samim',
              fontSize: 13,
              color: Colors.black45,
            ),
          ),
        ),
        data: (banners) {
          if (banners.isEmpty) return const SizedBox.shrink();

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _bannerController,
                  itemCount: banners.length,
                  onPageChanged: (index) =>
                      setState(() => _currentBannerPage = index),
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    // تبدیل آدرس نسبی سرور به آدرس کامل و مطلق وب‌سایت
                    final fullBannerImageUrl = AppConstants.getFullImageUrl(
                      banner.imageUrl,
                    );

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
                        child: InkWell(
                          // انتقال مستقیم هنرجو به صفحه جزئیات دوره لینک شده به بنر
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CourseDetailPage(courseId: banner.courseId),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              // 🔴 لود لایو تصویر از شبکه به جای اسِت‌های محلی قدیمی
                              Image.network(
                                fullBannerImageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                          color: Colors.black26,
                                        ),
                                      ),
                                    ),
                              ),
                              // گرادینت تیره برای خوانایی بهتر متن‌های روی بنر
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
                                      banner.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
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
                                      banner.subtitle,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
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

                              // دکمه مینی‌مال شیشه‌ای ورود به دوره
                              Positioned(
                                left: 24,
                                bottom: 24,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'ورود به دوره',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Samim',
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // نقطه‌های نشانگر پایین اسلایدر (ایندیکیتورها) متناسب با تعداد دیتای سرور
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  banners.length,
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
          );
        },
      ),
    );
  }
}
