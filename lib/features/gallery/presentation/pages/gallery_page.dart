import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/providers/home_provider.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryState = ref.watch(galleryProvider);

    // حالت لودینگ اولیه
    if (galleryState.isLoading && galleryState.images.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.lightBg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // حالت ارور اولیه
    if (galleryState.error != null && galleryState.images.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.lightBg,
        body: Center(
          child: Text(
            galleryState.error!,
            style: const TextStyle(
              fontFamily: 'Samim',
              color: AppColors.darkText,
            ),
          ),
        ),
      );
    }

    final images = galleryState.images;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // بخش نمایش تصاویر
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = images[index];
                final fullImageUrl = AppConstants.getFullImageUrl(
                  item['image_url'],
                );
                final title = item['title'] ?? item['alt_text'] ?? 'اثر هنرجو';
                final heroTag = 'gallery_image_${item['id'] ?? index}';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (context, _, __) => FullScreenImageViewer(
                          imageUrl: fullImageUrl,
                          title: title,
                          heroTag: heroTag,
                        ),
                        transitionsBuilder: (context, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Hero(
                              tag: heroTag,
                              child: Image.network(
                                fullImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        color: Colors.black26,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.75),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            left: 10,
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Samim',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }, childCount: images.length),
            ),
          ),

          // دکمه مشاهده تصاویر بیشتر در انتهای لیست
          if (galleryState.hasMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 30,
                  top: 10,
                  left: 40,
                  right: 40,
                ),
                child: galleryState.isFetchingMore
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () =>
                            ref.read(galleryProvider.notifier).loadMore(),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        label: const Text(
                          'مشاهده تصاویر بیشتر',
                          style: TextStyle(
                            fontFamily: 'Samim',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                      ),
              ),
            ),

          // فضای خالی انتهای صفحه وقتی تمام عکس‌ها لود شدند
          if (!galleryState.hasMore && images.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40, top: 20),
                child: Center(
                  child: Text(
                    'تمام تصاویر گالری بارگذاری شدند',
                    style: TextStyle(
                      fontFamily: 'Samim',
                      color: Colors.black45,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.95),
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: heroTag,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),
          ),
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
                      color: Colors.black.withValues(alpha: 0.5),
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
                    title,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Samim',
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
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
