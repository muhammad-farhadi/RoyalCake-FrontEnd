import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:royalcakes/features/courses/presentation/pages/video_player_page.dart';
import 'package:royalcakes/features/courses/presentation/pages/pdf_viewer_page.dart';
import 'package:royalcakes/features/gallery/presentation/pages/universal_image.dart'; // ایمپورت ویجت بومی کش شما
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/widgets/layout_widgets.dart';
import '../../../orders/providers/cart_provider.dart';
import '../../providers/course_detail_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class CourseDetailPage extends ConsumerStatefulWidget {
  final int courseId;

  const CourseDetailPage({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends ConsumerState<CourseDetailPage> {
  // 🔴 ۰ برای سرفصل‌ها (سمت راست) و ۱ برای رسپی‌ها (سمت چپ)
  int _activeTab = 0;

  // 🔴 ردیابی ایندکس اسلاید فعلی آلبوم بالای صفحه
  int _currentImgPage = 0;

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

  // متد کمکی برای ساخت کاورهای موقت
  Widget _buildPlaceholderCover() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xff146952)],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
      ),
      child: const Center(
        child: Icon(Icons.cake_rounded, color: Colors.white30, size: 24),
      ),
    );
  }

  // متد کمکی اجرای لینک‌های پشتیبانی به صورت عمومی و امن
  Future<void> _launchSocialUrl(Uri uri, String platformName) async {
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'خطا در باز کردن $platformName. لطفا مطمئن شوید برنامه $platformName روی گوشی شما نصب است.',
                style: const TextStyle(fontFamily: 'Samim'),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطا در ارتباط با $platformName',
              style: const TextStyle(fontFamily: 'Samim'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // اجرای لینک اختصاصی تلگرام روی یوزرنیم جدید شما
  Future<void> _launchTelegram() async {
    final Uri telegramUri = Uri.parse('https://t.me/royalcakes_ir');
    await _launchSocialUrl(telegramUri, 'تلگرام');
  }

  // اجرای لینک اختصاصی بله روی یوزرنیم جدید شما
  Future<void> _launchBale() async {
    final Uri baleUri = Uri.parse('https://ble.ir/royalcakes_ir');
    await _launchSocialUrl(baleUri, 'بله');
  }

  // اجرای تماس مستقیم با شماره پشتیبانی اختصاصی شما
  Future<void> _launchCall() async {
    final Uri callUri = Uri.parse('tel:09197919171');
    await _launchSocialUrl(callUri, 'تماس تلفنی');
  }

  @override
  Widget build(BuildContext context) {
    final courseState = ref.watch(courseDetailProvider(widget.courseId));

    // --- بررسی وضعیت خرید دوره توسط کاربر ---
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isAuthenticated;

    bool isPurchased = false;
    if (isLoggedIn) {
      final myCoursesState = ref.watch(myCoursesProvider);
      myCoursesState.whenData((courses) {
        isPurchased = courses.any((c) => c['course_id'] == widget.courseId);
      });
    }

    // 🔴 بررسی رایگان بودن دوره خارج از ویجت بیلد تا دکمه پشتیبانی را برای دوره‌های رایگان مخفی کنیم
    bool isFreeCourseForFab = false;
    courseState.whenData((course) {
      isFreeCourseForFab = course['price'] == 0 || course['price'] == null;
    });
    // ----------------------------------------

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        appBar: const MainAppBar(title: 'جزئیات دوره'),
        drawer: const AppDrawer(),
        bottomNavigationBar: const MainBottomNav(),

        // 🔴 دکمه شناور تنها در صورتی نمایش داده می‌شود که شخص دوره را خریده باشد و دوره رایگان نباشد
        floatingActionButton: (isPurchased && !isFreeCourseForFab)
            ? ExpandableSupportFab(
                onTelegramTap: _launchTelegram,
                onBaleTap: _launchBale,
                onCallTap: _launchCall,
              )
            : null,

        // قرارگیری دکمه شناور در سمت چپ صفحه
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

        body: Column(
          children: [
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
                  // تشخیص هوشمند وضعیت رایگان بودن دوره فعلی
                  final bool isFreeCourse =
                      course['price'] == 0 || course['price'] == null;

                  // ترکیب هوشمند عکس کاور اصلی و آلبوم تصاویر دوره جهت ساخت اسلایدر
                  final List<String> courseAlbum = [];
                  if (course['image_url'] != null &&
                      course['image_url'].toString().isNotEmpty) {
                    courseAlbum.add(
                      AppConstants.getFullImageUrl(course['image_url']),
                    );
                  }

                  final albumImages = course['images'] as List?;
                  if (albumImages != null) {
                    for (var img in albumImages) {
                      if (img['image_url'] != null &&
                          img['image_url'].toString().isNotEmpty) {
                        courseAlbum.add(
                          AppConstants.getFullImageUrl(img['image_url']),
                        );
                      }
                    }
                  }

                  // فال‌بک در صورتی که دیتایی نبود
                  if (courseAlbum.isEmpty) {
                    courseAlbum.add(
                      AppConstants.getFullImageUrl(
                        '/static/courses/images/default.webp',
                      ),
                    );
                  }

                  final lessons = List<dynamic>.from(course['lessons'] ?? []);
                  final documents = List<dynamic>.from(
                    course['documents'] ?? [],
                  );

                  return Stack(
                    children: [
                      // 1. محتوای اصلی قابل اسکرول
                      CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: 260,
                                  width: double.infinity,
                                  child: PageView.builder(
                                    itemCount: courseAlbum.length,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentImgPage = index;
                                      });
                                    },
                                    itemBuilder: (context, imgIndex) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FullScreenAlbumViewer(
                                                    images: courseAlbum,
                                                    initialIndex: imgIndex,
                                                    title:
                                                        course['title'] ??
                                                        'جزئیات آلبوم',
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Image.network(
                                          courseAlbum[imgIndex],
                                          width: double.infinity,
                                          height: 260,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                IgnorePointer(
                                  child: Container(
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
                                ),

                                if (courseAlbum.length > 1)
                                  Positioned(
                                    bottom: 38,
                                    left: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_currentImgPage + 1} از ${courseAlbum.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Samim',
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // محتوای متنی و توضیحات اصلی دوره
                          SliverToBoxAdapter(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.lightBg,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              transform: Matrix4.translationValues(
                                0.0,
                                -20.0,
                                0.0,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 🔴 تغییر ۱: مخفی‌سازی هوشمند نشان‌های طبقه‌بندی در صورت رایگان بودن آموزش
                                    if (!isFreeCourse) ...[
                                      Row(
                                        children: [
                                          _buildBadge(
                                            Icons.trending_up_rounded,
                                            course['level'] ??
                                                'مبتدی تا پیشرفته',
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
                                    ],

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

                                    // 🔴 تغییر ۲: مخفی‌سازی هوشمند باکس‌های آمار تعداد جلسات و ساعت در صورت رایگان بودن آموزش
                                    if (!isFreeCourse) ...[
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
                                    ],

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
                                    const SizedBox(height: 24),

                                    // کلیدهای دوگزینه‌ای شکیل (سرفصل‌ها / رسپی‌ها)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => setState(
                                                () => _activeTab = 0,
                                              ),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 250,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _activeTab == 0
                                                      ? AppColors.primary
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'سرفصل‌های دوره',
                                                    style: TextStyle(
                                                      fontFamily: 'Samim',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                      color: _activeTab == 0
                                                          ? Colors.white
                                                          : Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => setState(
                                                () => _activeTab = 1,
                                              ),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 250,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _activeTab == 1
                                                      ? AppColors.primary
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'رسپی‌ها و جزوات',
                                                    style: TextStyle(
                                                      fontFamily: 'Samim',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                      color: _activeTab == 1
                                                          ? Colors.white
                                                          : Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // رندر مشروط محتوا بر اساس تب انتخاب شده
                                    if (_activeTab == 0) ...[
                                      if (lessons.isEmpty)
                                        const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(24.0),
                                            child: Text(
                                              'هنوز جلسه‌ای برای این دوره آپلود نشده است.',
                                              style: TextStyle(
                                                fontFamily: 'Samim',
                                                color: Colors.black45,
                                              ),
                                            ),
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
                                            final isFree =
                                                lesson['is_free'] == true;
                                            final canWatch =
                                                isFree || isPurchased;

                                            // 🔴 تغییر ۳: ارجاع ردیف‌ها به ویجت آکاردئونی هوشمند کشویی جهت بازشدن پویای کپشن
                                            return LessonItemRow(
                                              lesson: lesson,
                                              index: index,
                                              canWatch: canWatch,
                                              formattedDuration:
                                                  _formatDuration(
                                                    lesson['duration'] ?? 0,
                                                  ),
                                              placeholderCover:
                                                  _buildPlaceholderCover(),
                                            );
                                          },
                                        ),
                                    ] else ...[
                                      if (documents.isEmpty)
                                        const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(32.0),
                                            child: Text(
                                              'هنوز جزوه یا کتابچه‌ای برای این دوره ثبت نشده است.',
                                              style: TextStyle(
                                                fontFamily: 'Samim',
                                                color: Colors.black45,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: documents.length,
                                          itemBuilder: (context, index) {
                                            final doc = documents[index];
                                            final hasAccess =
                                                isPurchased ||
                                                course['price'] == 0 ||
                                                course['price'] == null;

                                            final String? docCoverUrl =
                                                doc['cover_url'];
                                            final String? fullDocCoverUrl =
                                                docCoverUrl != null
                                                ? AppConstants.getFullImageUrl(
                                                    docCoverUrl,
                                                  )
                                                : null;

                                            return Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 14,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                border: Border.all(
                                                  color: Colors.grey.shade100,
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.015),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                onTap: () {
                                                  if (hasAccess) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            PdfViewerPage(
                                                              docId: doc['id'],
                                                              docTitle:
                                                                  doc['title'] ??
                                                                  'جزوه آموزشی',
                                                            ),
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'برای دسترسی به جزوات و رسپی‌ها، ابتدا باید دوره را خریداری کنید.',
                                                          style: TextStyle(
                                                            fontFamily: 'Samim',
                                                          ),
                                                        ),
                                                        backgroundColor:
                                                            Colors.orange,
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    10.0,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Container(
                                                            width: 95,
                                                            height: 65,
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade50,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        12,
                                                                      ),
                                                                ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              child:
                                                                  fullDocCoverUrl !=
                                                                      null
                                                                  ? Image.network(
                                                                      fullDocCoverUrl,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      errorBuilder:
                                                                          (
                                                                            context,
                                                                            error,
                                                                            stackTrace,
                                                                          ) =>
                                                                              _buildPlaceholderCover(),
                                                                    )
                                                                  : _buildPlaceholderCover(),
                                                            ),
                                                          ),
                                                          Positioned.fill(
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                color: hasAccess
                                                                    ? Colors
                                                                          .black
                                                                          .withOpacity(
                                                                            0.15,
                                                                          )
                                                                    : Colors
                                                                          .black
                                                                          .withOpacity(
                                                                            0.4,
                                                                          ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                              child: Center(
                                                                child: Container(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        6,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                          0.25,
                                                                        ),
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child: Icon(
                                                                    hasAccess
                                                                        ? Icons
                                                                              .picture_as_pdf_rounded
                                                                        : Icons
                                                                              .lock_outline_rounded,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 18,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 14),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              doc['title'] ??
                                                                  'فایل راهنما',
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Samim',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13.5,
                                                                color: hasAccess
                                                                    ? AppColors
                                                                          .darkText
                                                                    : Colors
                                                                          .grey
                                                                          .shade500,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                            const Text(
                                                              'فرمت: PDF اختصاصی رویال کیک',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Samim',
                                                                fontSize: 11,
                                                                color: Colors
                                                                    .black38,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 4,
                                                            ),
                                                        child: Icon(
                                                          hasAccess
                                                              ? Icons
                                                                    .visibility_outlined
                                                              : Icons
                                                                    .lock_outline_rounded,
                                                          color: hasAccess
                                                              ? AppColors
                                                                    .primary
                                                              : Colors
                                                                    .grey
                                                                    .shade400,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 2. دکمه بازگشت ثابت و شناور
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
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
                  );
                },
              ),
            ),

            // نوار چسبان ثبت نام ثابت پایین صفحه
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
                            'شما هنرجوی این دوره هستید ✔',
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
                                // const Text(
                                //   'مبلغ سرمایه‌گذاری:',
                                //   style: TextStyle(
                                //     fontSize: 11,
                                //     color: Colors.black54,
                                //     fontFamily: 'Samim',
                                //   ),
                                // ),
                                // const SizedBox(height: 4),
                                // بررسی وضعیت تخفیف فعال روی این دوره
                                if (course['is_discount_active'] == true) ...[
                                  Text(
                                    _formatPrice(course['price']),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                      fontFamily: 'Samim',
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: Colors.red,
                                      decorationThickness: 2.0, // ضخامت خط قرمز
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatPrice(course['final_price']),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontFamily: 'Samim',
                                    ),
                                  ),
                                ] else ...[
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
                              ],
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!isLoggedIn) {
                                    showLoginRequiredBottomSheet(context, ref);
                                    return;
                                  }

                                  final isFreeCourse =
                                      course['price'] == 0 ||
                                      course['price'] == null;

                                  if (isFreeCourse) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'در حال فعال‌سازی دوره رایگان...',
                                          style: TextStyle(fontFamily: 'Samim'),
                                        ),
                                      ),
                                    );
                                    try {
                                      final dio = ref.read(dioProvider);
                                      final response = await dio.post(
                                        '/orders/${widget.courseId}/enroll-free',
                                      );

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.green,
                                            content: Text(
                                              response.data['detail'] ??
                                                  'دوره رایگان با موفقیت برای شما فعال شد.',
                                              style: const TextStyle(
                                                fontFamily: 'Samim',
                                              ),
                                            ),
                                          ),
                                        );
                                        ref.invalidate(myCoursesProvider);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        String errorMsg =
                                            'خطا در فعال‌سازی دوره رایگان';
                                        if (e is DioException &&
                                            e.response?.data != null) {
                                          final data = e.response!.data;
                                          if (data is Map &&
                                              data.containsKey('detail')) {
                                            errorMsg = data['detail']
                                                .toString();
                                          }
                                        }
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.redAccent,
                                            content: Text(
                                              errorMsg,
                                              style: const TextStyle(
                                                fontFamily: 'Samim',
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'در حال افزودن به سبد خرید...',
                                          style: TextStyle(fontFamily: 'Samim'),
                                        ),
                                      ),
                                    );
                                    try {
                                      final success = await ref
                                          .read(cartProvider.notifier)
                                          .addToCart(widget.courseId);
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
                                child: Text(
                                  course['price'] == 0 ||
                                          course['price'] == null
                                      ? 'فعال‌سازی رایگان دوره'
                                      : 'ثبت‌نام در دوره',
                                  style: const TextStyle(
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

// ===================================================================
// 🔴 ویجت مدیریت آکاردئونی و بازشدن کشویی کپشن درس‌ها (جدید)
// ===================================================================
class LessonItemRow extends StatefulWidget {
  final dynamic lesson;
  final int index;
  final bool canWatch;
  final String formattedDuration;
  final Widget placeholderCover;

  const LessonItemRow({
    super.key,
    required this.lesson,
    required this.index,
    required this.canWatch,
    required this.formattedDuration,
    required this.placeholderCover,
  });

  @override
  State<LessonItemRow> createState() => _LessonItemRowState();
}

class _LessonItemRowState extends State<LessonItemRow> {
  bool _isExpanded = false; // ردیابی وضعیت باز یا بسته بودن کپشن این ردیف

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final isFree = lesson['is_free'] == true;

    // بررسی هوشمند وجود کپشن اختصاصی در دیتای لود شده از سرور
    final hasCaption =
        lesson['caption'] != null &&
        lesson['caption'].toString().trim().isNotEmpty;
    final String captionText = lesson['caption'] ?? '';

    final String? coverUrl = lesson['cover_url'];
    final String? fullCoverUrl = coverUrl != null
        ? AppConstants.getFullImageUrl(coverUrl)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              if (widget.canWatch) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerPage(
                      lessonId: lesson['id'],
                      lessonTitle: lesson['title'] ?? 'جلسه آموزشی',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'برای تماشای این جلسه, ابتدا باید دوره را خریداری کنید.',
                      style: TextStyle(fontFamily: 'Samim'),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 95,
                        height: 65,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: fullCoverUrl != null
                              ? Image.network(
                                  fullCoverUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      widget.placeholderCover,
                                )
                              : widget.placeholderCover,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.canWatch
                                ? Colors.black.withOpacity(0.15)
                                : Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.canWatch
                                    ? Icons.play_arrow_rounded
                                    : Icons.lock_outline_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson['title'] ?? 'جلسه آموزشی',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Samim',
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: widget.canWatch
                                ? AppColors.darkText
                                : Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: widget.canWatch
                                  ? Colors.black45
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.formattedDuration,
                              style: TextStyle(
                                fontFamily: 'Samim',
                                fontSize: 11,
                                color: widget.canWatch
                                    ? Colors.black54
                                    : Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (isFree)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'رایگان',
                                  style: TextStyle(
                                    fontFamily: 'Samim',
                                    fontSize: 10,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 🔴 اگر درس کپشن داشت، دکمه فلش بازشونده چرخشی نمایش داده می‌شود، در غیر این صورت ایندکس عددی ساده
                  hasCaption
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          icon: AnimatedRotation(
                            duration: const Duration(milliseconds: 200),
                            turns: _isExpanded ? 0.5 : 0.0,
                            // چرخش معکوس ۱۸۰ درجه فلش هنگام باز شدن
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary.withOpacity(0.7),
                              size: 24,
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${widget.index + 1}',
                            style: TextStyle(
                              fontFamily: 'Samim',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),

          // 🔴 بخش متحرک کشویی کپشن
          if (hasCaption)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(
                  left: 12.0,
                  right: 12.0,
                  bottom: 12.0,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 0.5),
                  ),
                  child: Text(
                    captionText,
                    // 🔴 تغییرات ظاهری: ضخامت بیشتر، سایز بزرگ‌تر، و رنگ تیره‌تر برای خوانایی بهتر
                    style: const TextStyle(
                      fontFamily: 'Samim',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
        ],
      ),
    );
  }
}

// ===================================================================
// دکمه شناور منبسط‌شونده ۳ کاناله (تراز عمودی و ریاضی در چپ)
// ===================================================================
class ExpandableSupportFab extends StatefulWidget {
  final VoidCallback onTelegramTap;
  final VoidCallback onBaleTap;
  final VoidCallback onCallTap;

  const ExpandableSupportFab({
    super.key,
    required this.onTelegramTap,
    required this.onBaleTap,
    required this.onCallTap,
  });

  @override
  State<ExpandableSupportFab> createState() => _ExpandableSupportFabState();
}

class _ExpandableSupportFabState extends State<ExpandableSupportFab>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: SizedBox(
        width: 230,
        height: 250,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ۱. گزینه پیام‌رسان بله
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              bottom: _isOpen ? 190 : 0,
              left: 8,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isOpen ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !_isOpen,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.ltr,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'bale_fab_sub',
                        onPressed: () {
                          _toggle();
                          widget.onBaleTap();
                        },
                        backgroundColor: Colors.white,
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/icons/bale.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.chat_bubble_rounded,
                              color: Color(0xff14876b),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Card(
                        elevation: 3,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Text(
                            'رفع اشکال در بله',
                            style: TextStyle(
                              fontFamily: 'Samim',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ۲. گزینه پیام‌رسان تلگرام
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              bottom: _isOpen ? 130 : 0,
              left: 8,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isOpen ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !_isOpen,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.ltr,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'telegram_fab_sub',
                        onPressed: () {
                          _toggle();
                          widget.onTelegramTap();
                        },
                        backgroundColor: Colors.white,
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/icons/telegram.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.telegram_rounded,
                              color: Color(0xff0088cc),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Card(
                        elevation: 3,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Text(
                            'رفع اشکال در تلگرام',
                            style: TextStyle(
                              fontFamily: 'Samim',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ۳. گزینه تماس مستقیم تلفنی
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              bottom: _isOpen ? 70 : 0,
              left: 8,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isOpen ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !_isOpen,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.ltr,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'call_fab_sub',
                        onPressed: () {
                          _toggle();
                          widget.onCallTap();
                        },
                        backgroundColor: Colors.white,
                        elevation: 4,
                        child: const Icon(
                          Icons.phone_in_talk_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Card(
                        elevation: 3,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Text(
                            'پشتیبانی تلفنی مستقیم',
                            style: TextStyle(
                              fontFamily: 'Samim',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ۴. دکمه اصلی و چرخان پشتیبانی
            Positioned(
              bottom: 0,
              left: 0,
              child: FloatingActionButton(
                heroTag: 'main_support_fab',
                onPressed: _toggle,
                backgroundColor: AppColors.primary,
                elevation: 6,
                child: RotationTransition(
                  turns: Tween<double>(
                    begin: 0.0,
                    end: 0.125,
                  ).animate(_controller),
                  child: AnimatedCrossFade(
                    firstChild: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    secondChild: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    crossFadeState: _isOpen
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// ویجت آلبوم تمام‌صفحه با بازنویسی بر اساس کامپوننت بومی پروژه شما
// ===================================================================
class FullScreenAlbumViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String title;

  const FullScreenAlbumViewer({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.title,
  });

  @override
  State<FullScreenAlbumViewer> createState() => _FullScreenAlbumViewerState();
}

class _FullScreenAlbumViewerState extends State<FullScreenAlbumViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      body: Stack(
        children: [
          // لایه ورق‌زدنی آلبوم
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: UniversalImage(
                    imageUrl: widget.images[index],
                    fit: BoxFit.contain,
                    cacheWidth: 1000,
                  ),
                );
              },
            ),
          ),

          // هدر بالای صفحه
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${widget.title} (${_currentIndex + 1} از ${widget.images.length})',
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Samim',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
