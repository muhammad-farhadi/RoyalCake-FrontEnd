import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/providers/home_provider.dart';
import 'universal_image.dart';

class GalleryPage extends ConsumerStatefulWidget {
  const GalleryPage({super.key});

  @override
  ConsumerState<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    if (kIsWeb) {
      // 🟢 محدود کردن شدید حافظه کش تصاویر برای مهار رم سافاری
      PaintingBinding.instance.imageCache.maximumSize = 3;
      PaintingBinding.instance.imageCache.maximumSizeBytes =
          15 * 1024 * 1024; // ۱۵ مگابایت
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final galleryState = ref.watch(galleryProvider);

    if (galleryState.isLoading && galleryState.images.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    if (galleryState.error != null && galleryState.images.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            galleryState.error!,
            style: const TextStyle(fontFamily: 'Samim', color: Colors.white),
          ),
        ),
      );
    }

    final images = galleryState.images;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // اسلایدر ورق‌زدنی تمام صفحه
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            scrollDirection: Axis.vertical,
            // 🟢 ورق خوردن به صورت عمودی (رو به پایین و بالا)
            onPageChanged: (index) {
              // لود اتوماتیک صفحات بعدی از سرور
              if (index == images.length - 1 &&
                  galleryState.hasMore &&
                  !galleryState.isFetchingMore) {
                ref.read(galleryProvider.notifier).loadMore();
              }
            },
            itemBuilder: (context, index) {
              final item = images[index];
              final fullImageUrl = AppConstants.getFullImageUrl(
                item['image_url'],
              );
              final title =
                  item['title'] ??
                  item['alt_text'] ??
                  'اثر هنرجوی آکادمی رویال کیک';

              return Stack(
                fit: StackFit.expand,
                children: [
                  // تصویر بزرگ وسط صفحه با قابلیت زوم
                  Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: UniversalImage(
                        imageUrl: fullImageUrl,
                        fit: BoxFit.contain,
                        cacheWidth: 1000, // رزولوشن کاملاً بهینه شده
                      ),
                    ),
                  ),

                  // سایه مشکی پایین صفحه
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 180,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black87,
                            Colors.black38,
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),

                  // متون کپشن و شمارنده تصویر
                  Positioned(
                    bottom: 40,
                    right: 24,
                    left: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Samim',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'تصویر ${index + 1} از ${galleryState.hasMore ? "..." : images.length}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            fontFamily: 'Samim',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // وضعیت لودینگ داینامیک انتهای اسلایدر
          if (galleryState.isFetchingMore)
            const Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
