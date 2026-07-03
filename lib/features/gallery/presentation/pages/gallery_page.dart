import 'dart:math';
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
  // 🔴 تعداد عکس‌هایی که در حال حاضر مجاز به رندر شدن هستند (شروع با ۱۲)
  int _currentVisibleCount = 12;
  List<dynamic> _shuffledImages = [];
  bool _isShuffled = false;

  @override
  Widget build(BuildContext context) {
    // محدود کردن کش فلاتر روی وب برای امنیت رم سافاری آیفون
    if (kIsWeb) {
      PaintingBinding.instance.imageCache.maximumSize = 5;
      PaintingBinding.instance.imageCache.maximumSizeBytes = 15 * 1024 * 1024;
    }

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
            style: const TextStyle(fontFamily: 'Samim'),
          ),
        ),
      );
    }

    // 🔴 لود کردن ۲۰۰ لینک متنی از پرووایدر و شافل کردن آن‌ها فقط برای یک‌بار
    final allImages = galleryState.images;
    if (!_isShuffled && allImages.isNotEmpty) {
      _shuffledImages = List.from(allImages);
      _shuffledImages.shuffle(Random()); // تصادفی کردن چینش ۲۰۰ لینک در حافظه
      _isShuffled = true;
    }

    // 🔴 محاسبه تعداد آیتم‌هایی که واقعاً باید در سطر و ستون رندر شوند
    final int displayCount = min(_currentVisibleCount, _shuffledImages.length);
    final bool hasMoreLocal = _currentVisibleCount < _shuffledImages.length;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // بخش نمایش تصاویر به صورت شبکه‌ای
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _shuffledImages[index];
                  final fullImageUrl = AppConstants.getFullImageUrl(
                    item['image_url'],
                  );
                  final title =
                      item['title'] ?? item['alt_text'] ?? 'اثر هنرجو';
                  final heroTag = 'gallery_image_${item['id'] ?? index}';

                  return GestureDetector(
                    onTap: () {
                      if (kIsWeb) PaintingBinding.instance.imageCache.clear();
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (context, _, __) =>
                              FullScreenImageViewer(
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
                              child: kIsWeb
                                  ? UniversalImage(
                                      imageUrl: fullImageUrl,
                                      fit: BoxFit.cover,
                                      cacheWidth:
                                          350, // رندر فوق‌العاده سبک برای رم وب
                                    )
                                  : Hero(
                                      tag: heroTag,
                                      child: UniversalImage(
                                        imageUrl: fullImageUrl,
                                        fit: BoxFit.cover,
                                        cacheWidth: 400,
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
                },
                childCount: displayCount,
                // 🔴 فقط به تعداد مجاز لود کن (مثلا ۱۲ تا)
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: true,
              ),
            ),
          ),

          // 🔴 دکمه هوشمند لود بیشتر: بدون درخواست به سرور، ۱۲ عکس بعدی را از لیست ۲۰۰ تایی موجود آزاد می‌کند
          if (hasMoreLocal)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 30,
                  top: 10,
                  left: 40,
                  right: 40,
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentVisibleCount +=
                          12; // 🔴 اضافه شدن ۱۲ عدد به سقف مجاز رندر
                    });
                  },
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

          // پیام انتهای گالری
          if (!hasMoreLocal && _shuffledImages.isNotEmpty)
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
              child: kIsWeb
                  ? UniversalImage(imageUrl: imageUrl, fit: BoxFit.contain)
                  : Hero(
                      tag: heroTag,
                      child: UniversalImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
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
                  onPressed: () {
                    if (kIsWeb) PaintingBinding.instance.imageCache.clear();
                    Navigator.pop(context);
                  },
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
