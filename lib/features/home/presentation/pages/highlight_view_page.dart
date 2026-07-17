import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // مطمئن شو این پکیج در پب‌اسپک هست
import '../../../../core/constants/app_constants.dart';
import '../../data/models/highlight_model.dart';

class HighlightViewPage extends StatefulWidget {
  final HighlightCategoryModel category;

  const HighlightViewPage({super.key, required this.category});

  @override
  State<HighlightViewPage> createState() => _HighlightViewPageState();
}

class _HighlightViewPageState extends State<HighlightViewPage> {
  int _currentIndex = 0;
  VideoPlayerController? _videoController;
  Timer? _imageTimer;
  Timer? _progressTimer;
  double _animationProgress = 0.0;
  bool _isVideoLoading = false;

  @override
  void initState() {
    super.initState();
    _playStoryItem();
  }

  // 🔴 هسته پردازش هوشمند استوری (تشخیص عکس یا ویدیو بودن آیتم مدل)
  void _playStoryItem() {
    _cleanCurrentEngine();

    // دریافت آیتم فعلی از لیست مدل شما
    final item = widget.category.items[_currentIndex];

    // 💡 نکته: اگر نام پراپرتی‌ها در مدل شما به جای camelCase به صورت کدمارک (video_url) هست، نام آنها را اصلاح کنید.
    final String? videoUrl = item.videoUrl;
    final String? imageUrl = item.imageUrl;

    if (videoUrl != null && videoUrl.isNotEmpty) {
      // 🎥 سناریوی اول: آیتم ویدیو است
      setState(() {
        _isVideoLoading = true;
        _animationProgress = 0.0;
      });

      final fullVideoUrl = AppConstants.getFullImageUrl(videoUrl);

      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(fullVideoUrl))
            ..initialize()
                .then((_) {
                  if (!mounted) return;
                  setState(() {
                    _isVideoLoading = false;
                  });
                  _videoController!.play();

                  // پر کردن نوار پیشرفت بالای صفحه بر اساس زمان واقعی ویدیو
                  _progressTimer = Timer.periodic(
                    const Duration(milliseconds: 30),
                    (timer) {
                      if (_videoController == null ||
                          !_videoController!.value.isInitialized)
                        return;
                      final duration =
                          _videoController!.value.duration.inMilliseconds;
                      final position =
                          _videoController!.value.position.inMilliseconds;
                      if (duration > 0) {
                        setState(() {
                          _animationProgress = position / duration;
                        });
                      }
                    },
                  );

                  // رفتن به استوری بعدی به محض تمام شدن ویدیو
                  _videoController!.addListener(() {
                    if (_videoController == null) return;
                    if (_videoController!.value.position >=
                        _videoController!.value.duration) {
                      _nextStory();
                    }
                  });
                })
                .catchError((err) {
                  _nextStory(); // اگر ویدیو به هر دلیلی خطا داد برو بعدی که کاربر معطل نشه
                });
    } else {
      // 🖼️ سناریوی دوم: آیتم تصویر است (نمایش ۵ ثانیه‌ای استاندارد)
      setState(() {
        _isVideoLoading = false;
        _animationProgress = 0.0;
      });

      const int durationSeconds = 5;
      int passedMs = 0;

      _progressTimer = Timer.periodic(const Duration(milliseconds: 30), (
        timer,
      ) {
        passedMs += 30;
        setState(() {
          _animationProgress = (passedMs / (durationSeconds * 1000)).clamp(
            0.0,
            1.0,
          );
        });
      });

      _imageTimer = Timer(const Duration(seconds: durationSeconds), () {
        _nextStory();
      });
    }
  }

  void _nextStory() {
    if (_currentIndex < widget.category.items.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _playStoryItem();
    } else {
      Navigator.pop(context); // اتمام تمام بخش‌های هایلایت -> خروج به داشبورد
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _playStoryItem();
    }
  }

  void _cleanCurrentEngine() {
    _imageTimer?.cancel();
    _progressTimer?.cancel();
    _videoController?.removeListener(() {});
    _videoController?.dispose();
    _videoController = null;
  }

  @override
  void dispose() {
    _cleanCurrentEngine();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.category.items[_currentIndex];
    final String? imageUrl = item.imageUrl;
    final String? videoUrl = item.videoUrl;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ۱. لایه نمایش مدیا (تمام صفحه با دتکتور لمسی چپ و راست)
            Positioned.fill(
              child: GestureDetector(
                onTapUp: (details) {
                  final width = MediaQuery.of(context).size.width;
                  // ضربه به سمت راست صفحه -> استوری بعدی | ضربه به سمت چپ صفحه -> استوری قبلی
                  if (details.globalPosition.dx > width / 2) {
                    _nextStory();
                  } else {
                    _previousStory();
                  }
                },
                child: Center(
                  child: videoUrl != null && videoUrl.isNotEmpty
                      ? (_videoController != null &&
                                _videoController!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio:
                                    _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              )
                            : const SizedBox.shrink())
                      : (imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                AppConstants.getFullImageUrl(imageUrl),
                                fit: BoxFit.contain,
                                width: double.infinity,
                              )
                            : const SizedBox.shrink()),
                ),
              ),
            ),

            // لودینگ چرخشی مخصوص بافرینگ ویدیوها
            if (_isVideoLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // ۲. لایه بالایی: نوارهای پیشرفت چندگانه اینستاگرامی (Progress Bars)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: List.generate(widget.category.items.length, (
                      index,
                    ) {
                      double progress = 0.0;
                      if (index < _currentIndex)
                        progress = 1.0; // استوری‌های پر شده قبلی
                      if (index == _currentIndex)
                        progress = _animationProgress; // وضعیت پارت فعلی

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            minHeight: 2.5,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),

                  // هدر شامل عنوان دسته‌بندی هایلایت و دکمه بستن پاپ‌آپ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.category.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Samim',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.black87, blurRadius: 6),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
