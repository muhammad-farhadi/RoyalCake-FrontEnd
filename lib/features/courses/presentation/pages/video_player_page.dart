import 'dart:async';
import 'dart:math';

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';

class VideoPlayerPage extends ConsumerStatefulWidget {
  final int lessonId;
  final String lessonTitle;

  const VideoPlayerPage({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  ConsumerState<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends ConsumerState<VideoPlayerPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = 'خطا در بارگذاری ویدیو';
  double _currentSpeed = 1.0;

  /// بدون نیاز به dart:io — روی وب هم کامپایل می‌شود.
  bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    _secureScreen();
    _initializePlayer();
  }

  Future<void> _secureScreen() async {
    if (!_isMobile) return;
    try {
      await ScreenProtector.preventScreenshotOn();
    } catch (e) {
      debugPrint('خطا در فعال‌سازی محافظ صفحه: $e');
    }
  }

  void _fail(String message) {
    if (!mounted || _hasError) return;
    setState(() {
      _isLoading = false;
      _hasError = true;
      _errorMessage = message;
    });
  }

  void _videoListener() {
    final v = _videoController?.value;
    if (v == null || !v.hasError) return;
    debugPrint('🎬 VIDEO ERROR → ${v.errorDescription}');
    _fail('خطای پخش: ${v.errorDescription ?? "نامشخص"}');
  }

  Future<void> _initializePlayer() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        '/courses/${widget.lessonId}/stream-ticket',
      );
      final ticket = response.data['ticket'];

      if (ticket == null || ticket.toString().isEmpty) {
        _fail('سرور تیکت معتبری برنگرداند.');
        return;
      }

      final url =
          '${AppConstants.apiBaseUrl}/courses/${widget.lessonId}'
          '/stream/playlist.m3u8?ticket=$ticket';
      debugPrint('🎬 stream url → $url');

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        // ⚠️ حیاتی: چون URL با ?ticket= تمام می‌شود، ExoPlayer نمی‌تواند از روی
        // پسوند فایل بفهمد HLS است. این خط صریحاً به او می‌گوید.
        formatHint: VideoFormat.hls,
      );
      _videoController = controller;
      controller.addListener(_videoListener);

      await controller.initialize().timeout(const Duration(seconds: 25));
      if (!mounted) return;

      final userPhone = ref.read(authProvider).phoneNumber ?? 'کاربر رویال کیک';

      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        showControls: true,
        allowFullScreen: true,
        // سرعت را از دکمه‌ی AppBar می‌دهیم، پس منوی داخلی Chewie لازم نیست.
        allowPlaybackSpeedChanging: false,
        aspectRatio: controller.value.aspectRatio,
        overlay: MovingWatermark(userPhone: userPhone),
        deviceOrientationsOnEnterFullScreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: const [DeviceOrientation.portraitUp],
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.accent,
          backgroundColor: Colors.white.withOpacity(0.35),
          bufferedColor: Colors.white.withOpacity(0.5),
        ),
        errorBuilder: (context, errorMessage) =>
            _buildErrorView(message: errorMessage),
      );

      setState(() => _isLoading = false);
    } on TimeoutException {
      _fail(
        'پخش‌کننده بعد از ۲۵ ثانیه نتوانست ویدیو را باز کند.\n'
        'اتصال اینترنت خود را بررسی کنید.',
      );
    } catch (e) {
      _fail('خطا در بارگذاری ویدیو:\n$e');
    }
  }

  Future<void> _retry() async {
    _videoController?.removeListener(_videoListener);
    _chewieController?.dispose();
    await _videoController?.dispose();
    _chewieController = null;
    _videoController = null;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _currentSpeed = 1.0;
    });
    await _initializePlayer();
  }

  void _showSpeedSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'سرعت پخش ویدیو',
                  style: TextStyle(
                    fontFamily: 'Samim',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...speeds.map((speed) {
                  final isSelected = _currentSpeed == speed;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: isSelected ? AppColors.accent : Colors.grey,
                    ),
                    title: Text(
                      '${speed}x ${speed == 1.0 ? "(عادی)" : ""}',
                      style: TextStyle(
                        fontFamily: 'Samim',
                        color: isSelected ? AppColors.accent : Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      _videoController?.setPlaybackSpeed(speed);
                      setState(() => _currentSpeed = speed);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    if (_isMobile) {
      try {
        ScreenProtector.preventScreenshotOff();
      } catch (_) {}
    }
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    _videoController?.removeListener(_videoListener);
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildLoadingView() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: AppColors.accent),
        SizedBox(height: 16),
        Text(
          'در حال اتصال به سرور...',
          style: TextStyle(
            color: Colors.white70,
            fontFamily: 'Samim',
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView({String? message}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 48,
          ),
          const SizedBox(height: 14),
          Text(
            message ?? _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Samim',
              fontSize: 14,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.accent),
            label: const Text(
              'تلاش دوباره',
              style: TextStyle(color: AppColors.accent, fontFamily: 'Samim'),
            ),
            onPressed: _retry,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            widget.lessonTitle,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Samim',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (!_isLoading && !_hasError)
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.speed_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_currentSpeed}x',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Samim',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                onPressed: _showSpeedSelector,
              ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Center(
              child: _isLoading
                  ? _buildLoadingView()
                  : _hasError
                  ? _buildErrorView()
                  : Chewie(controller: _chewieController!),
            ),
          ),
        ),
      ),
    );
  }
}

class MovingWatermark extends StatefulWidget {
  final String userPhone;

  const MovingWatermark({super.key, required this.userPhone});

  @override
  State<MovingWatermark> createState() => _MovingWatermarkState();
}

class _MovingWatermarkState extends State<MovingWatermark> {
  final Random _random = Random();
  Timer? _watermarkTimer;
  Alignment _watermarkAlignment = Alignment.center;

  @override
  void initState() {
    super.initState();
    _startWatermarkMovement();
  }

  void _startWatermarkMovement() {
    _watermarkTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          final x = (_random.nextDouble() * 1.8) - 0.9;
          final y = (_random.nextDouble() * 1.8) - 0.9;
          _watermarkAlignment = Alignment(x, y);
        });
      }
    });
  }

  @override
  void dispose() {
    _watermarkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedAlign(
        alignment: _watermarkAlignment,
        duration: const Duration(seconds: 4),
        curve: Curves.linear,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            widget.userPhone,
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 19,
              fontWeight: FontWeight.w900,
              fontFamily: 'Samim',
              shadows: [
                Shadow(
                  offset: const Offset(1.5, 1.5),
                  blurRadius: 4.0,
                  color: Colors.black.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
