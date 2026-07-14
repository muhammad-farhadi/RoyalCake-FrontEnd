import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../gallery/presentation/pages/universal_image.dart';
import '../../../home/providers/home_provider.dart';
import 'course_detail_page.dart';

class CoursesPage extends ConsumerWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesState = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Column(
        children: [
          // 🔴 هدر فیلترهای تفکیک‌کننده شکیل بالای صفحه
          _buildFilterBar(context, ref),

          Expanded(
            child: coursesState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, stack) => const Center(
                child: Text(
                  'خطا در دریافت لیست دوره‌ها',
                  style: TextStyle(
                    fontFamily: 'Samim',
                    color: AppColors.darkText,
                  ),
                ),
              ),
              data: (courses) {
                if (courses.isEmpty) {
                  return const Center(
                    child: Text(
                      'هیچ دوره‌ای در این بخش یافت نشد.',
                      style: TextStyle(
                        fontFamily: 'Samim',
                        color: Colors.black45,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref.refresh(coursesProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final fullImageUrl = AppConstants.getFullImageUrl(
                        course['image_url'],
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CourseDetailPage(
                                      courseId: course['id'],
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 130,
                                    height: 150,
                                    color: Colors.grey.shade100,
                                    child: UniversalImage(
                                      imageUrl: fullImageUrl,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.accent
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  course['level'] ??
                                                      'مبتدی تا پیشرفته',
                                                  style: const TextStyle(
                                                    color: AppColors.primary,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Samim',
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                course['title'] ?? 'بدون عنوان',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: AppColors.darkText,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Samim',
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.auto_stories_outlined,
                                                size: 16,
                                                color: Colors.black45,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${course['session_count'] ?? 0} جلسه آموزشی',
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                  fontFamily: 'Samim',
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                formatPrice(course['price']),
                                                style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Samim',
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CourseDetailPage(
                                                            courseId:
                                                                course['id'],
                                                          ),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.primary,
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'ثبت‌نام',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Samim',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
        ],
      ),
    );
  }

  // ویجت کمکی نواری فیلترها برای UX زیباتر
  Widget _buildFilterBar(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(courseFilterProvider);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'همه دوره‌ها',
              isSelected: currentFilter == null,
              onTap: () => ref.read(courseFilterProvider.notifier).state = null,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'دوره‌های تخصصی',
              isSelected: currentFilter == false,
              onTap: () =>
                  ref.read(courseFilterProvider.notifier).state = false,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'آموزش‌های رایگان',
              isSelected: currentFilter == true,
              onTap: () => ref.read(courseFilterProvider.notifier).state = true,
            ),
          ],
        ),
      ),
    );
  }
}

// ویجت داخلی و کوچک دکمه فیلتر
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Samim',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.darkText,
          ),
        ),
      ),
    );
  }
}
