import 'dart:async';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // پالت رنگی اختصاصی رویال کیک
  final Color _primaryColor = const Color(0xff0c4d3b); // سبز تیره رویال
  final Color _accentColor = const Color(0xfffc94a1); // صورتی ملایم
  final Color _lightBg = const Color(0xfffcf8f8); // پس‌زمینه ملایم و گرم
  final Color _darkText = const Color(0xff2c3e50); // رنگ متون اصلی

  // متغیر وضعیت احراز هویت
  bool _isLoggedIn = false;

  // کنترلرها و متغیرهای اسلایدر بنر
  final PageController _bannerController = PageController(initialPage: 0);
  int _currentBannerPage = 0;
  Timer? _bannerTimer;

  // لیست بنرها همراه با تصویر پس‌زمینه
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

  // لیست دوره‌های آموزشی بدون subtitle
  final List<Map<String, String>> _myCourses = [
    {
      'title': 'دوره کیک و کوکی کافی شاپی',
      'price': '۲,۵۰۰,۰۰۰ تومان',
      'image': 'assets/images/cake/cake1.png',
    },
    {
      'title': 'دوره شیرینی رویال کیک',
      'price': '۱,۸۰۰,۰۰۰ تومان',
      'image': 'assets/images/sweet/sweet11.JPG',
    },
    {
      'title': ' دوره چیز کیک رویال کیک',
      'price': '۱,۸۰۰,۰۰۰ تومان',
      'image': 'assets/images/cheesecake/cheesaeCake18.jpeg',
    },
  ];

  @override
  void initState() {
    super.initState();
    // تایمر حرکت خودکار اسلایدر بنرها (هر ۴ ثانیه)
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

  // متد هوشمند مدیریت دسترسی (صفحه اصلی باز است، اما بخش‌های حساس قفل هستند)
  void _handleProtectedRoute(VoidCallback onAuthorizedAction) {
    if (_isLoggedIn) {
      onAuthorizedAction();
    } else {
      _showLoginRequiredBottomSheet();
    }
  }

  // نمایش منوی پایین صفحه برای دعوت به ورود
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
              Icon(Icons.lock_person_outlined, color: _accentColor, size: 50),
              const SizedBox(height: 16),
              Text(
                'نیاز به ورود به حساب کاربری',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Samim',
                  color: _darkText,
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
                        backgroundColor: _primaryColor,
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
                      child: Text(
                        'انصراف',
                        style: TextStyle(color: _darkText, fontFamily: 'Samim'),
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _lightBg,

        // ۱. منوی همبرگری (Drawer)
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            // این خط باعث می‌شود هدر کاملاً زیر Status Bar برود
            children: [
              // هدر پیشرفته و استاندارد با مدیریت وضعیت ورود کاربر
              DrawerHeader(
                decoration: BoxDecoration(color: _primaryColor),
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(16),
                child: Center(
                  // کل محتوا را در مرکز هدر قرار می‌دهد
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // وسط‌چین کردن تمام المان‌های ستون
                    children: [
                      // ۱. عکس پروفایل یا لوگو در مرکز
                      CircleAvatar(
                        radius: 36, // سایز دایره تصویر
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(
                          _isLoggedIn
                              ? 'assets/images/user_avatar.png'
                              : 'assets/images/logo.png',
                        ),
                        child: _isLoggedIn
                            ? null
                            : Icon(
                                Icons.cake_rounded,
                                color: _primaryColor,
                                size: 32,
                              ),
                      ),
                      const SizedBox(height: 12),

                      // ۲. نام کاربر یا عنوان اپلیکیشن
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

                      // ۳. متن وضعیت زیر عنوان
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

              // آیتم‌های منو
              ListTile(
                leading: Icon(Icons.login_rounded, color: _primaryColor),
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
                leading: Icon(Icons.school_outlined, color: _primaryColor),
                title: const Text(
                  'دوره‌های من',
                  style: TextStyle(fontFamily: 'Samim'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleProtectedRoute(() {
                    // هدایت به صفحه دوره‌های خریداری شده برای تماشا
                  });
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.bookmark_border_rounded,
                  color: _primaryColor,
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
                  // ارتباط با پشتیبان دوره
                },
              ),
            ],
          ),
        ),

        // ۲. اپ‌بار (AppBar)
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                    Icons.menu_rounded,
                    color: _primaryColor,
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
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.cake_outlined,
                        color: _primaryColor,
                        size: 22,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'رویال کیک',
                    style: TextStyle(
                      color: _primaryColor,
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
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: _primaryColor,
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

        // ۳. بدنه اصلی صفحه (Body)
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= ۱. اسلایدر بنرها =================
              const SizedBox(height: 12),
              SizedBox(
                height: 210,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _bannerController,
                        itemCount: _banners.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentBannerPage = index;
                          });
                        },
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
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              _primaryColor,
                                              _primaryColor.withValues(
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
                                      );
                                    },
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                ? _primaryColor
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // ================= ۲. بخش ویژگی‌های متمایز (چرا رویال کیک؟) =================
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFeatureItem(
                      Icons.verified_user_outlined,
                      'رسپی‌های تست شده',
                    ),
                    _buildFeatureItem(
                      Icons.support_agent_rounded,
                      'پشتیبانی دائمی هنرجو',
                    ),
                    _buildFeatureItem(
                      Icons.workspace_premium_outlined,
                      'آموزش کاملاً بازارکاری',
                    ),
                  ],
                ),
              ),

              // ================= ۳. دسته‌بندی‌های محبوب =================
              const Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom: 12,
                ),
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
                  children: [
                    _buildCategoryItem(Icons.cake_rounded, 'کیک‌های مدرن'),
                    _buildCategoryItem(Icons.cookie_outlined, 'شیرینی و کوکی'),
                    _buildCategoryItem(
                      Icons.bakery_dining_rounded,
                      'دسر و چیزکیک',
                    ),
                    _buildCategoryItem(
                      Icons.menu_book_rounded,
                      'رسپی‌های رایگان',
                    ),
                  ],
                ),
              ),

              // ================= ۴. باکس پیشنهاد شگفت‌انگیز =================
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, const Color(0xff1b6350)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                // ... کدهای قبل از استک
                child: Stack(
                  children: [
                    Positioned(
                      left: -20,
                      top: -20,
                      // ✅ اصلاح شد: تبدیل color به backgroundColor
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
                                    color: _accentColor,
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
                              foregroundColor: _primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              _handleProtectedRoute(() {
                                // هدایت به صفحه جشنواره یا تخفیف‌ها
                              });
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'دوره‌های آموزشی رویال کیک',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Samim',
                        color: _darkText,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _handleProtectedRoute(() {});
                      },
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontFamily: 'Samim',
                          color: _accentColor,
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
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _myCourses.length,
                  itemBuilder: (context, index) {
                    final course = _myCourses[index];
                    return _buildCourseCard(
                      course['title']!,
                      course['price']!,
                      course['image']!,
                    );
                  },
                ),
              ),

              // ================= ۶. مینی گالری خروجی هنرجویان =================
              const Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 12,
                ),
                child: Text(
                  'خروجی هنرجویان رویال کیک',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Samim',
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Container(
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
                        child: Image.asset(
                          'assets/images/gallery/student$index.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.black26,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 35),
            ],
          ),
        ),

        // ۴. نوار ناوبری پایین صفحه (Bottom Navigation Bar)
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
              _buildBottomShortcut(
                icon: Icons.home_filled,
                label: 'Home',
                color: _primaryColor,
                isActive: true,
                onTap: () {},
              ),
              _buildBottomShortcut(
                icon: Icons.chrome_reader_mode_outlined,
                label: 'Courses',
                color: Colors.grey.shade400,
                isActive: false,
                onTap: () {
                  _handleProtectedRoute(() {});
                },
              ),
              _buildBottomShortcut(
                icon: Icons.image_outlined,
                label: 'Gallery',
                color: Colors.grey.shade400,
                isActive: false,
                onTap: () {
                  _handleProtectedRoute(() {});
                },
              ),
              _buildBottomShortcut(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Q&A',
                color: Colors.grey.shade400,
                isActive: false,
                onTap: () {
                  _handleProtectedRoute(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // متد اصلاح شده بخش ویژگی‌ها
  Widget _buildFeatureItem(IconData icon, String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _primaryColor, size: 26),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontFamily: 'Samim',
            color: Colors.black.withValues(
              alpha: 0.7,
            ), // ✅ اصلاح شد: رفع خطای black70
          ),
        ),
      ],
    );
  }

  // متد ساخت دایره‌های دسته‌بندی
  Widget _buildCategoryItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xfff5ebe6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xff8d6e63), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
              fontFamily: 'Samim',
            ),
          ),
        ],
      ),
    );
  }

  // متد ساخت کارت دوره‌ها (نسخه بدون subtitle و اصلاح شده)
  Widget _buildCourseCard(String title, String price, String imgAsset) {
    return Container(
      width: 165,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            _handleProtectedRoute(() {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'در حال باز کردن صفحه $title...',
                    style: const TextStyle(fontFamily: 'Samim'),
                  ),
                ),
              );
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Image.asset(
                    imgAsset,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: _accentColor.withValues(alpha: 0.15),
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: _accentColor,
                            size: 30,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Samim',
                        color: _darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Samim',
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // متد ساخت میانبرهای نوار ناوبری پایین صفحه
  Widget _buildBottomShortcut({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? _primaryColor : color, size: 24),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? _primaryColor : Colors.black45,
              fontFamily: 'Samim',
            ),
          ),
        ],
      ),
    );
  }
}
