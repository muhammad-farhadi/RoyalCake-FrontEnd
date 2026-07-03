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
  int _currentVisibleCount = 12;
  List<dynamic> _shuffledImages = [];

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // 🔴 به جای صفر، یک بافر ۲۰ تایی می‌دیم تا در اسکرول سریع، CPU ذوب نشه!
      PaintingBinding.instance.imageCache.maximumSize = 20;
      PaintingBinding.instance.imageCache.maximumSizeBytes =
          20 * 1024 * 1024; // ۲۰ مگابایت رم مجاز
    }
  }

  @override
  Widget build(BuildContext context) {
    // برای اطمینان بیشتر، در هر بار رندر کش قبلی را کاملاً پاک می‌کنیم
    if (kIsWeb) PaintingBinding.instance.imageCache.clear();

    final galleryState = ref.watch(galleryProvider);

    if (galleryState.isLoading && galleryState.images.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.lightBg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

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

    // 🔴 حل مشکل لود بیشتر: اضافه کردن هوشمندِ عکس‌های جدید سرور به لیست شافل‌شده
    final allImages = galleryState.images;
    if (_shuffledImages.length < allImages.length) {
      // فقط عکس‌های جدیدی که تازه از سرور آمده‌اند را جدا کن و شافل کن
      final newImages = allImages.sublist(_shuffledImages.length);
      final shuffledNew = List.from(newImages)..shuffle(Random());
      _shuffledImages.addAll(shuffledNew); // به انتهای لیست اضافه کن
    }

    final int displayCount = min(_currentVisibleCount, _shuffledImages.length);
    final bool hasMoreLocal = _currentVisibleCount < _shuffledImages.length;
    final bool hasMoreServer = galleryState.hasMore;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        // 🔴 ایده طلایی دوم شما: فلاتر حق ندارد عکس‌های بالا و پایین اسکرین را پیش‌لود کند!
        cacheExtent: 0,
        slivers: [
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
                                      cacheWidth: 350,
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
                addAutomaticKeepAlives: false,
                addRepaintBoundaries:
                    true, // 🔴 این حتماً باید TRUE باشه تا کل صفحه تو اسکرول تیک نزنه!
              ),
            ),
          ),

          // 🔴 دکمه هوشمند ترکیبی
          if (hasMoreLocal || hasMoreServer)
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
                        onPressed: () {
                          if (hasMoreLocal) {
                            // اگر هنوز تو اون ۲۰۰ تای قبلی عکس داریم، ۱۲ تا دیگه نشون بده
                            setState(() {
                              _currentVisibleCount += 12;
                            });
                          } else if (hasMoreServer) {
                            // اگر ۲۰۰ تای قبلی تموم شد، به سرور ریکوئست بزن برای صفحه بعدی دیتابیس
                            ref.read(galleryProvider.notifier).loadMore();
                            setState(() {
                              _currentVisibleCount += 12;
                            });
                          }
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

          if (!hasMoreLocal && !hasMoreServer && _shuffledImages.isNotEmpty)
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

// ----------------------------------------------------
// نمایشگر تمام صفحه
// ----------------------------------------------------
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
                    // با زدن دکمه بستن، عکس کیفیت بالا باید از رم پاک شود
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
