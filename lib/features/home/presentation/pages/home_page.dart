import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// یک پرووایدر فرضی برای لود داده‌های صفحه اصلی از بک‌اند
final homeDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // اینجا در آینده به دیو کلاینت وصل می‌شویم
  await Future.delayed(const Duration(seconds: 2)); // شبیه‌سازی لودینگ
  return {
    'banners': ['banner2.png', 'banner5.png', 'banner6.png'],
    'categories': ['کیک‌ها', 'چیز کیک‌ها', 'شیرینی‌ها'],
  };
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeDataProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('رویال کیک'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {
              // مسیریابی به سبد خرید (Orders)
            },
          ),
        ],
      ),
      body: homeState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('خطا در دریافت اطلاعات: $error')),
        data: (data) {
          return RefreshIndicator(
            onRefresh: () => ref.refresh(homeDataProvider.future),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 12),
                _buildWelcomeSection(theme),
                const SizedBox(height: 20),
                _buildBannerSlider(data['banners']),
                const SizedBox(height: 24),
                _buildSectionHeader(theme, 'دسته‌بندی‌ها', () {}),
                const SizedBox(height: 12),
                _buildCategoryList(data['categories'], theme),
                const SizedBox(height: 24),
                _buildSectionHeader(theme, 'جدیدترین دوره‌های آموزشی', () {}),
                const SizedBox(height: 12),
                // اینجا در آینده لیست دوره‌ها (Courses) از بک‌اند رندر می‌شود
                _buildDummyCourseList(theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('سلام، خوش آمدید! 👋', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 4),
        Text(
          'امروز دوست داری چه شیرینی پختی رو یاد بگیری؟',
          style: theme.textTheme.headlineLarge?.copyWith(fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildBannerSlider(List<dynamic> banners) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: PageView.builder(
          itemCount: banners.length,
          itemBuilder: (context, index) {
            return Image.asset(
              'assets/images/${banners[index]}',
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    String title,
    VoidCallback onSeeAll,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'مشاهده همه',
            style: TextStyle(color: theme.colorScheme.secondary),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(List<dynamic> categories, ThemeData theme) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: index == 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Text(
                categories[index],
                style: TextStyle(
                  color: index == 0
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDummyCourseList(ThemeData theme) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: const Center(child: Icon(Icons.cake, size: 40)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'دوره جامع پخت کیک',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'مدرس: استاد رویال',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '۴۵۰,۰۰۰ تومان',
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
