import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../providers/highlights_provider.dart';
import '../../providers/seen_stories_provider.dart';
import '../pages/highlight_view_page.dart';

class HighlightsBar extends ConsumerStatefulWidget {
  const HighlightsBar({super.key});

  @override
  ConsumerState<HighlightsBar> createState() => _HighlightsBarState();
}

class _HighlightsBarState extends ConsumerState<HighlightsBar> {
  @override
  Widget build(BuildContext context) {
    final highlightsState = ref.watch(highlightsProvider);
    // گوش دادن مداوم به تغییرات لیست آیدی‌ها
    final seenIds = ref.watch(seenStoriesProvider);
    final seenNotifier = ref.read(seenStoriesProvider.notifier);

    if (highlightsState.isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xff0c4d3b)),
        ),
      );
    }

    if (highlightsState.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    // مرتب‌سازی دسته‌ها
    final sortedCategories = List.from(highlightsState.categories)
      ..sort((a, b) {
        if (a.createdAt != null && b.createdAt != null) {
          return b.createdAt!.compareTo(a.createdAt!);
        }
        return 0;
      });

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: sortedCategories.length,
        itemBuilder: (context, index) {
          final category = sortedCategories[index];

          if (category.items.isEmpty) return const SizedBox.shrink();

          // بررسی وضعیت خاکستری شدن با متد اینستاگرامی
          final isFullySeen = seenNotifier.isCategoryFullySeen(category.items);

          return GestureDetector(
            onTap: () {
              // باز کردن صفحه و منتظر ماندن برای بسته شدن آن
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HighlightViewPage(category: category),
                ),
              ).then((_) {
                // 🔴 راز حل مشکل: وقتی کاربر از استوری بیرون می‌آید، ویجت را مجبور به رندر مجدد می‌کنیم
                // چون seenStoriesProvider تغییر کرده، رنگ دور استوری بلافاصله خاکستری می‌شود.
                if (mounted) setState(() {});
              });
            },
            child: Container(
              margin: const EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isFullySeen
                          ? Colors.grey.shade300
                          : const Color(0xff0c4d3b),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(
                          AppConstants.getFullImageUrl(category.coverUrl),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
