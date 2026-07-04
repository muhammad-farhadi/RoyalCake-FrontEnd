import 'dart:io';
import 'dart:typed_data'; // 🔴 الزامی برای خواندن باینری وب
import 'package:flutter/foundation.dart'; // 🔴 برای تشخیص پلتفرم وب (kIsWeb)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../gallery/presentation/pages/fullScreenPage.dart';
import '../../../gallery/presentation/pages/gallery_page.dart';
import '../../../home/providers/home_provider.dart';
import '../../providers/reviews_provider.dart';

class CourseReviewsPage extends ConsumerStatefulWidget {
  const CourseReviewsPage({super.key});

  @override
  ConsumerState<CourseReviewsPage> createState() => _CourseReviewsPageState();
}

class _CourseReviewsPageState extends ConsumerState<CourseReviewsPage> {
  int? _selectedCourseId;
  String? _selectedCourseTitle;

  @override
  Widget build(BuildContext context) {
    if (_selectedCourseId != null) {
      return _buildDetailedReviews(_selectedCourseId!, _selectedCourseTitle!);
    }

    final coursesAsync = ref.watch(coursesProvider);

    return coursesAsync.when(
      loading: () =>
      const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (err, stack) =>
      const Center(child: Text('خطا در بارگذاری لیست دوره‌ها')),
      data: (courses) {
        if (courses.isEmpty) {
          return const Center(child: Text('هیچ دوره‌ای یافت نشد.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    AppConstants.getFullImageUrl(course['image_url']),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  course['title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 0.0),
                  child: Text(
                    'برای مشاهده نظرات هنرجویان کلیک کنید',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                onTap: () {
                  ref
                      .read(courseReviewsProvider.notifier)
                      .fetchReviews(course['id']);
                  setState(() {
                    _selectedCourseId = course['id'];
                    _selectedCourseTitle = course['title'];
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailedReviews(int courseId, String courseTitle) {
    final reviewsState = ref.watch(courseReviewsProvider);

    return Column(
      children: [
        Container(
          color: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  setState(() {
                    _selectedCourseId = null;
                    _selectedCourseTitle = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'نظرات دوره: $courseTitle',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: reviewsState.when(
            loading: () =>
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (err, stack) =>
            const Center(child: Text('خطا در بارگذاری نظرات')),
            data: (reviews) {
              return Column(
                children: [
                  Expanded(
                    child: reviews.isEmpty
                        ? const Center(
                      child: Text(
                        'هنوز هیچ نظری برای این دوره تایید نشده است.',
                      ),
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 1, // سایه ملایم برای تمیزی لایوت
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // هدر نظر: شامل نام هنرجو و تاریخ ثبت نظر
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Text(
                                      review.user.fullName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    Text(
                                      "${review.createdAt.year}/${review
                                          .createdAt.month}/${review.createdAt
                                          .day}",
                                      style: const TextStyle(color: Colors.grey,
                                          fontSize: 11,
                                          fontFamily: 'Samim'),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20, thickness: 0.5),

                                // 🔴🔴 لایه جدید: قرار گرفتن متن و عکس به صورت افقی در کنار یکدیگر 🔴🔴
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  // تراز شدن المان‌ها از بالای کادر
                                  children: [
                                    // بخش متن نظر (به همراه Expanded تا کل فضای باقی‌مانده را پر کند)
                                    Expanded(
                                      child: Text(
                                        review.content,
                                        style: const TextStyle(height: 1.6,
                                            fontSize: 13,
                                            color: Colors.black87),
                                        textAlign: TextAlign
                                            .justify, // تراز شدن متن برای زیبایی بیشتر
                                      ),
                                    ),

                                    // اگر نظر دارای عکس بود، آن را در سمت چپ متن نمایش بده
                                    if (review.imageUrl != null) ...[
                                      const SizedBox(width: 12),
                                      // فاصله بین متن و عکس
                                      GestureDetector(
                                        onTap: () {
                                          final fullImageUrl = AppConstants
                                              .getFullImageUrl(
                                              review.imageUrl!);
                                          final reviewHeroTag = 'review_image_${review
                                              .id}';

                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              opaque: false,
                                              pageBuilder: (context, _, __) =>
                                                  FullScreenImageViewer(
                                                    imageUrl: fullImageUrl,
                                                    title: 'تصویر ارسالی ${review
                                                        .user.fullName}',
                                                    heroTag: reviewHeroTag,
                                                  ),
                                              transitionsBuilder: (context,
                                                  anim, __, child) =>
                                                  FadeTransition(opacity: anim,
                                                      child: child),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 85,
                                          // ابعاد بندانگشتی بسیار بهینه و شیک
                                          height: 85,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                12),
                                            border: Border.all(
                                                color: Colors.grey.shade200,
                                                width: 1.5),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                    0.02),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                10),
                                            child: Hero(
                                              tag: 'review_image_${review.id}',
                                              child: Image.network(
                                                AppConstants.getFullImageUrl(
                                                    review.imageUrl!),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) =>
                                                const Center(
                                                  child: Icon(Icons
                                                      .broken_image_outlined,
                                                      color: Colors.grey,
                                                      size: 20),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text(
                          'ثبت نظر و تجربه شما',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () =>
                            _showAddReviewBottomSheet(context, courseId),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddReviewBottomSheet(BuildContext context, int courseId) {
    final textController = TextEditingController();
    XFile? pickedImage;
    Uint8List? webImageBytes; // 🔴 ذخیره موقت بایت‌ها مخصوص اجرا روی وب

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            Future<void> pickReviewImage() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              );

              if (image != null) {
                // 🔴 اگر روی پلتفرم وب بودیم، بایت‌های فایل را مستقیم می‌خوانیم
                if (kIsWeb) {
                  final bytes = await image.readAsBytes();
                  setSheetState(() {
                    pickedImage = image;
                    webImageBytes = bytes;
                  });
                } else {
                  // اگر روی اندروید بودیم همون روال عادی کار می‌کند
                  setSheetState(() {
                    pickedImage = image;
                  });
                }
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery
                    .of(context)
                    .viewInsets
                    .bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تجربه خود از این دوره را بنویسید',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                      'نظر شما پس از تایید مدیریت در اپلیکیشن نمایش داده می‌شود...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // بخش پیش‌نمایش تصویر (سازگار با وب و اندروید)
                  if (pickedImage != null)
                    Stack(
                      children: [
                        Container(
                          height: 120,
                          width: 120,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            // 🔴 اگر وب بود از Image.memory استفاده کن، اگر اندروید بود از Image.file
                            child: kIsWeb
                                ? Image.memory(
                              webImageBytes!,
                              fit: BoxFit.cover,
                            )
                                : Image.file(
                              File(pickedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                pickedImage = null;
                                webImageBytes = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text(
                        'افزودن عکس نمونه‌کار (اختیاری)',
                        style: TextStyle(fontFamily: 'Samim'),
                      ),
                      onPressed: pickReviewImage,
                    ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (textController.text
                            .trim()
                            .isEmpty) return;

                        MultipartFile? multiPartFile;
                        if (pickedImage != null) {
                          if (kIsWeb) {
                            // 🔴 فرمت دهی آپلود مخصوص نسخه وب (ارسال مستقیم بایت‌ها به دپندرسی دایو)
                            multiPartFile = MultipartFile.fromBytes(
                              webImageBytes!,
                              filename: pickedImage!.name,
                            );
                          } else {
                            // فرمت دهی آپلود مخصوص نسخه اندروید
                            multiPartFile = await MultipartFile.fromFile(
                              pickedImage!.path,
                              filename: pickedImage!.name,
                            );
                          }
                        }

                        final success = await ref
                            .read(courseReviewsProvider.notifier)
                            .submitReview(
                          courseId: courseId,
                          content: textController.text.trim(),
                          imageFile: multiPartFile,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'نظر شما با موفقیت ثبت شد و پس از تایید مدیریت نمایش داده می‌شود.'
                                    : 'خطا! شما دانشجو این دوره نیستید یا دسترسی نامعتبر است.',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('ارسال نظر هنرجو'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
