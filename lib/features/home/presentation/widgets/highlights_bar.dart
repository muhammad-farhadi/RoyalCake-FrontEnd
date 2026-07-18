import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../providers/highlights_provider.dart';
import '../pages/highlight_view_page.dart';

class HighlightsBar extends ConsumerWidget {
  const HighlightsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlightsState = ref.watch(highlightsProvider);

    if (highlightsState.isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xff0c4d3b)),
        ),
      );
    }

    if (highlightsState.categories.isEmpty) {
      return const SizedBox.shrink(); // اگر دسته‌ای نبود چیزی نمایش داده نشود
    }

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: highlightsState.categories.length,
        itemBuilder: (context, index) {
          final category = highlightsState.categories[index];

          // اگر دسته‌ای هیچ عکسی داخلش نباشد نمایش نمی‌دهیم
          if (category.items.isEmpty) return const SizedBox.shrink();

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HighlightViewPage(category: category),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  // رینگ رنگی دور هایلایت به رنگ سبز اصلی آکادمی شما
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xff0c4d3b),
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
                  // const SizedBox(height: 6),
                  // Text(
                  //   category.title,
                  //   style: const TextStyle(
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.w500,
                  //     color: Color(0xff2c3e50),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
