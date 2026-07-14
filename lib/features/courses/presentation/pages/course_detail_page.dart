import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:royalcakes/features/courses/presentation/pages/video_player_page.dart';
import 'package:royalcakes/features/courses/presentation/pages/pdf_viewer_page.dart'; // ایمپورت نمایشگر امن PDF
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
    // ----------------------------------------

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        appBar: const MainAppBar(title: 'جزئیات دوره'),
        drawer: const AppDrawer(),
        bottomNavigationBar: const MainBottomNav(),
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
                  final fullImageUrl = AppConstants.getFullImageUrl(
                    course['image_url'],
                  );
                  final lessons = List<dynamic>.from(course['lessons'] ?? []);
                  final documents = List<dynamic>.from(
                    course['documents'] ?? [],
                  );

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // هدر عکس دوره
                      SliverToBoxAdapter(
                        child: Stack(
                          children: [
                            Image.network(
                              fullImageUrl,
                              height: 260,
                              width: double.infinity,
                              fit: BoxFit.contain,
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

                      // محتوای متنی و توضیحات اصلی دوره
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
                                const SizedBox(height: 24),

                                // ===================================================================
                                // 🔴 کلیدهای دوگزینه‌ای شکیل و متحرک (سرفصل‌ها / رسپی‌ها)
                                // ===================================================================
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
                                      // گزینه سمت راست: سرفصل‌ها
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              setState(() => _activeTab = 0),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            padding: const EdgeInsets.symmetric(
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
                                                  fontWeight: FontWeight.bold,
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
                                      // گزینه سمت چپ: رسپی‌ها و جزوات
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              setState(() => _activeTab = 1),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            padding: const EdgeInsets.symmetric(
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
                                                  fontWeight: FontWeight.bold,
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

                                // ===================================================================
                                // 🔴 رندر مشروط محتوا بر اساس تب انتخاب شده
                                // ===================================================================
                                if (_activeTab == 0) ...[
                                  // لود لیست سرفصل‌های ویدیویی (تب اول)
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
                                        final canWatch = isFree || isPurchased;

                                        final String? coverUrl =
                                            lesson['cover_url'];
                                        final String? fullCoverUrl =
                                            coverUrl != null
                                            ? AppConstants.getFullImageUrl(
                                                coverUrl,
                                              )
                                            : null;

                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade100,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            onTap: () {
                                              if (canWatch) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        VideoPlayerPage(
                                                          lessonId:
                                                              lesson['id'],
                                                          lessonTitle:
                                                              lesson['title'] ??
                                                              'جلسه آموزشی',
                                                        ),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'برای تماشای این جلسه، ابتدا باید دوره را خریداری کنید.',
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
                                                        decoration: BoxDecoration(
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
                                                              fullCoverUrl !=
                                                                  null
                                                              ? Image.network(
                                                                  fullCoverUrl,
                                                                  fit: BoxFit
                                                                      .contain,
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
                                                            color: canWatch
                                                                ? Colors.black
                                                                      .withOpacity(
                                                                        0.15,
                                                                      )
                                                                : Colors.black
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
                                                                canWatch
                                                                    ? Icons
                                                                          .play_arrow_rounded
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
                                                          lesson['title'] ??
                                                              'جلسه آموزشی',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontFamily: 'Samim',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13.5,
                                                            color: canWatch
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
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .access_time_rounded,
                                                              size: 13,
                                                              color: canWatch
                                                                  ? Colors
                                                                        .black45
                                                                  : Colors
                                                                        .grey
                                                                        .shade400,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              _formatDuration(
                                                                lesson['duration'] ??
                                                                    0,
                                                              ),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Samim',
                                                                fontSize: 11,
                                                                color: canWatch
                                                                    ? Colors
                                                                          .black54
                                                                    : Colors
                                                                          .grey
                                                                          .shade400,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            if (isFree)
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          6,
                                                                      vertical:
                                                                          2,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .green
                                                                      .withOpacity(
                                                                        0.12,
                                                                      ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        6,
                                                                      ),
                                                                ),
                                                                child: const Text(
                                                                  'رایگان',
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        'Samim',
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .green,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '${index + 1}',
                                                      style: TextStyle(
                                                        fontFamily: 'Samim',
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .grey
                                                            .shade400,
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
                                ] else ...[
                                  // لود لیست جزوات آموزشی و فایل‌های PDF (تب دوم)
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

                                        // 🔴 ۱. دریافت آدرس کاور اختصاصی جزوه از بک‌آند (جدید)
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
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade100,
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.015,
                                                ),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
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
                                                  // 🔴 ۲. بخش تصویر کاور هوشمند جزوه (کاملاً هماهنگ با سرفصل‌ها و BoxFit.contain)
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        width: 95,
                                                        height: 65,
                                                        decoration: BoxDecoration(
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
                                                                      .contain,
                                                                  // نمایش کامل تصویر بدون کات شدن
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
                                                      // اورلی گلس‌مورفیسم متناسب با نوع فایل (آیکون PDF یا قفل)
                                                      Positioned.fill(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: hasAccess
                                                                ? Colors.black
                                                                      .withOpacity(
                                                                        0.15,
                                                                      )
                                                                : Colors.black
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
                                                                          .picture_as_pdf_rounded // آیکون پی‌دی‌اف برای تمایز با ویدیو
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

                                                  // 🔴 ۳. بخش متون جزوه (عنوان و فرمت)
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
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontFamily: 'Samim',
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                                            fontFamily: 'Samim',
                                                            fontSize: 11,
                                                            color:
                                                                Colors.black38,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // نشانگر وضعیت نهایی دسترسی در انتهای سمت چپ کارت
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
                                                          ? AppColors.primary
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
                                  if (!isLoggedIn) {
                                    showLoginRequiredBottomSheet(context, ref);
                                    return;
                                  }

                                  // تشخیص هوشمند رایگان بودن دوره
                                  final isFreeCourse =
                                      course['price'] == 0 ||
                                      course['price'] == null;

                                  if (isFreeCourse) {
                                    // 🔴 سناریوی اول: فعال‌سازی مستقیم دوره رایگان بدون درگیر کردن سبد خرید
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
                                      // ارسال درخواست به روتر جدید بک‌آند شما
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
                                        // 🔴 ابطال کش پرووایدر دوره‌های من برای تغییر فوری وضعیت دکمه پایین صفحه به "شما هنرجوی این دوره هستید ✔"
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
                                    // 🔴 سناریوی دوم: فرآیند قبلی اضافه کردن دوره‌های پولی به سبد خرید
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
                                  // تغییر داینامیک متن دکمه متناسب با قیمت دوره
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
