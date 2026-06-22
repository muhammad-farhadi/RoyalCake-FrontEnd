import 'dart:async';
import 'dart:ui'; // برای استفاده از PointerDeviceKind
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../gallery/presentation/pages/gallery_page.dart';
import '../widgets/home_widgets.dart';
import '../../providers/home_provider.dart';

// کلاس سفارشی برای فعال‌سازی قطعی اسکرول افقی با لمس و ماوس روی تمامی دیوایس‌ها
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isLoggedIn = false;

  final PageController _bannerController = PageController(initialPage: 0);
  int _currentBannerPage = 0;
  Timer? _bannerTimer;

  final List<Map<String, String>> _banners = [
    {
      'title': 'رویال کیک',
      'subtitle': 'تخفیف ویژه دوره‌های جدید',
      'image': 'assets/images/banner5.png',
    },
    {
      'title': 'چیز کیک',
      'subtitle': 'آموزش تکنیک‌های مدرن و روز دنیا',
      'image': 'assets/images/banner2.png',
    },
    {
      'title': 'شیرینی‌های عید',
      'subtitle': 'پکیج تخصصی با رسپی‌های تست شده',
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

  void _handleProtectedRoute(VoidCallback onAuthorizedAction) {
    if (_isLoggedIn) {
      onAuthorizedAction();
    } else {
      _showLoginRequiredBottomSheet();
    }
  }

  void _showLoginRequiredBottomSheet() {
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
                'برای مشاهده جزئیات، خرید دوره‌ها و دسترسی به سبد خرید، لطفا ابتدا وارد حساب کاربری خود شوید.',
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
                        setState(() {
                          _isLoggedIn = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'شما با موفقیت وارد شدید! حالا می‌توانید دوره‌ها را باز کنید.',
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

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(bottomNavIndexProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: AppColors.primary),
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(
                          _isLoggedIn
                              ? 'assets/images/user_avatar.png'
                              : 'assets/images/logo.png',
                        ),
                        child: _isLoggedIn
                            ? null
                            : const Icon(
                                Icons.cake_rounded,
                                color: AppColors.primary,
                                size: 32,
                              ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isLoggedIn ? 'هنرجوی گرامی، خوش آمدید' : 'رویال کیک',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Samim',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isLoggedIn
                            ? 'مشاهده و مدیریت دوره‌ها'
                            : 'آکادمی تخصصی آموزش کیک و شیرینی',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontFamily: 'Samim',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.login_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  _isLoggedIn ? 'پروفایل کاربری' : 'ورود و ثبت‌نام',
                  style: const TextStyle(
                    fontFamily: 'Samim',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (!_isLoggedIn) _showLoginRequiredBottomSheet();
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
                  _handleProtectedRoute(() {});
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
                  _handleProtectedRoute(() {});
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.black54,
                ),
                title: const Text(
                  'پشتیبانی',
                  style: TextStyle(fontFamily: 'Samim'),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
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
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.cake_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentTab == 2 ? 'گالری هنرجویان' : 'رویال کیک',
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
                _handleProtectedRoute(() {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'در حال انتقال به سبد خرید...',
                        style: TextStyle(fontFamily: 'Samim'),
                      ),
                    ),
                  );
                });
              },
            ),
          ],
        ),

        body: currentTab == 2 ? const GalleryPage() : _buildHomeBody(),

        bottomNavigationBar: Container(
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
                onTap: () =>
                    ref.read(bottomNavIndexProvider.notifier).state = 0,
              ),
              BottomNavShortcut(
                icon: Icons.chrome_reader_mode_outlined,
                label: 'Courses',
                color: Colors.grey.shade400,
                isActive: currentTab == 1,
                onTap: () => _handleProtectedRoute(
                  () => ref.read(bottomNavIndexProvider.notifier).state = 1,
                ),
              ),
              BottomNavShortcut(
                icon: Icons.image_rounded,
                label: 'Gallery',
                color: Colors.grey.shade400,
                isActive: currentTab == 2,
                onTap: () =>
                    ref.read(bottomNavIndexProvider.notifier).state = 2,
              ),
              BottomNavShortcut(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Q&A',
                color: Colors.grey.shade400,
                isActive: currentTab == 3,
                onTap: () => _handleProtectedRoute(
                  () => ref.read(bottomNavIndexProvider.notifier).state = 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ۱. اسلایدر بنرها
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _bannerController,
                    itemCount: _banners.length,
                    onPageChanged: (index) => setState(() {
                      _currentBannerPage = index;
                    }),
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
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.primary.withValues(
                                              alpha: 0.85,
                                            ),
                                          ],
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          size: 50,
                                        ),
                                      ),
                                    ),
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
                  children: List.generate(_banners.length, (index) {
                    return AnimatedContainer(
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
                    );
                  }),
                ),
              ],
            ),
          ),

          // ۲. بخش ویژگی‌های متمایز
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
                  title: 'رسپی‌های تست شده',
                ),
                FeatureItem(
                  icon: Icons.support_agent_rounded,
                  title: 'پشتیبانی دائمی هنرجو',
                ),
                FeatureItem(
                  icon: Icons.workspace_premium_outlined,
                  title: 'آموزش کاملاً بازارکاری',
                ),
              ],
            ),
          ),

          // ۳. دسته‌بندی‌های محبوب
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
            child: Text(
              'دسته‌بندی‌های محبوب',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Samim',
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 105,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: const [
                CategoryItem(icon: Icons.cake_rounded, title: 'کیک‌های مدرن'),
                CategoryItem(
                  icon: Icons.cookie_outlined,
                  title: 'شیرینی و کوکی',
                ),
                CategoryItem(
                  icon: Icons.bakery_dining_rounded,
                  title: 'دسر و چیزکیک',
                ),
                CategoryItem(
                  icon: Icons.menu_book_rounded,
                  title: 'رسپی‌های رایگان',
                ),
              ],
            ),
          ),

          // ۴. باکس پیشنهاد شگفت‌انگیز
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xff1b6350)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: -20,
                  top: -20,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text(
                                'تخفیف ۵۰٪',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Samim',
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'جشنواره شیرینی‌های عید رویال',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Samim',
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          _handleProtectedRoute(() {});
                        },
                        child: const Text(
                          'مشاهده دوره',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Samim',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ================= ۵. لیست دوره‌ها =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'دوره‌های آموزشی رویال کیک',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Samim',
                    color: AppColors.darkText,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _handleProtectedRoute(() {});
                  },
                  child: const Text(
                    'View All',
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
                      'خطا در دریافت دوره‌ها',
                      style: TextStyle(fontFamily: 'Samim'),
                    ),
                  ),
                  data: (courses) {
                    if (courses.isEmpty)
                      return const Center(
                        child: Text(
                          'دوره‌ای یافت نشد',
                          style: TextStyle(fontFamily: 'Samim'),
                        ),
                      );

                    // اضافه کردن حل مشکل اسکرول و کارت نهایی
                    return ScrollConfiguration(
                      behavior: AppScrollBehavior(),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: courses.length + 1,
                        // افزایش یک فیلد برای دکمه انتها
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
                                onTap: () {
                                  _handleProtectedRoute(() {});
                                },
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
                                      'مشاهده همه\nدوره‌ها',
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
                            title: course['title'] ?? 'بدون عنوان',
                            price: formatPrice(course['price']),
                            imageUrl: course['image_url'] ?? '',
                            onTap: () {
                              _handleProtectedRoute(() {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'در حال باز کردن صفحه ${course['title']}...',
                                      style: const TextStyle(
                                        fontFamily: 'Samim',
                                      ),
                                    ),
                                  ),
                                );
                              });
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
          ),

          // ================= ۶. مینی گالری خروجی هنرجویان =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'خروجی هنرجویان رویال کیک',
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
                    'مشاهده گالری',
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
                if (galleryState.error != null && galleryState.images.isEmpty) {
                  return const Center(
                    child: Text(
                      'خطا در دریافت گالری',
                      style: TextStyle(fontFamily: 'Samim'),
                    ),
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
                    // افزایش یک فیلد برای کارت نهایی گالری
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
                                  'مشاهده کامل\nگالری',
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
                      final title =
                          image['title'] ?? image['alt_text'] ?? 'اثر هنرجو';
                      final homeHeroTag =
                          'home_gallery_image_${image['id'] ?? index}';

                      return GestureDetector(
                        onTap: () {
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
}
