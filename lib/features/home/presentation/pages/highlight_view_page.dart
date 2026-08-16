import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/highlight_model.dart';
import '../../providers/seen_stories_provider.dart';

class HighlightViewPage extends ConsumerStatefulWidget {
  final HighlightCategoryModel category;

  const HighlightViewPage({super.key, required this.category});

  @override
  ConsumerState<HighlightViewPage> createState() => _HighlightViewPageState();
}

class _HighlightViewPageState extends ConsumerState<HighlightViewPage> {
  int _currentIndex = 0;
  VideoPlayerController? _videoController;
  Timer? _imageTimer;
  Timer? _progressTimer;
  double _animationProgress = 0.0;
  bool _isVideoLoading = false;

  // 🔴 لیست استوری‌های سورت شده بر اساس تاریخ
  late List<dynamic> _sortedItems;

  @override
  void initState() {
    super.initState();
    // 🔴 ۱. مرتب‌سازی استوری‌های داخل دسته بر اساس تاریخ (از قدیمی به جدید جهت پخش ترتیبی)
    _sortedItems = List.from(widget.category.items)
      ..sort((a, b) {
        if (a.createdAt != null && b.createdAt != null) {
          return a.createdAt!.compareTo(b.createdAt!);
        }
        return 0;
      });

    _playStoryItem();
  }

  // 🔴 هسته پردازش هوشمند استوری و ثبت سین
  void _playStoryItem() {
    _cleanCurrentEngine();

    if (_sortedItems.isEmpty) return;

    final item = _sortedItems[_currentIndex];

    // 🔴 ۲. ثبت سین در حافظه گوشی برای این استوری مشخص
    final itemId = item.id;
    ref.read(seenStoriesProvider.notifier).markItemAsSeen(itemId);

    final String? videoUrl = item.videoUrl;
    final String? imageUrl = item.imageUrl;

    if (videoUrl != null && videoUrl.isNotEmpty) {
      // 🎥 سناریوی ویدیو
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

                  _videoController!.addListener(() {
                    if (_videoController == null) return;
                    if (_videoController!.value.position >=
                        _videoController!.value.duration) {
                      _nextStory();
                    }
                  });
                })
                .catchError((err) {
                  _nextStory();
                });
    } else {
      // 🖼️ سناریوی عکس (نمایش ۵ ثانیه‌ای)
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
    if (_currentIndex < _sortedItems.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _playStoryItem();
    } else {
      Navigator.pop(context);
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
    if (_sortedItems.isEmpty) return const SizedBox.shrink();

    final item = _sortedItems[_currentIndex];
    final String? imageUrl = item.imageUrl;
    final String? videoUrl = item.videoUrl;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ۱. لایه نمایش مدیا (تمام صفحه)
            Positioned.fill(
              child: GestureDetector(
                onTapUp: (details) {
                  final width = MediaQuery.of(context).size.width;
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

            if (_isVideoLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // ۲. لایه بالایی: نوارهای پیشرفت چندگانه اینستاگرامی
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: List.generate(_sortedItems.length, (index) {
                      double progress = 0.0;
                      if (index < _currentIndex) progress = 1.0;
                      if (index == _currentIndex) progress = _animationProgress;

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
