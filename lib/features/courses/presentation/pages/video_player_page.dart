import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:screen_protector/screen_protector.dart';
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
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _secureScreen();
    _initializePlayer();
  }

  Future<void> _secureScreen() async {
    if (kIsWeb) return;

    if (Platform.isAndroid || Platform.isIOS) {
      try {
        await ScreenProtector.preventScreenshotOn();
      } catch (e) {
        debugPrint('خطا در فعال‌سازی محافظ صفحه: $e');
      }
    }
  }

  Future<void> _initializePlayer() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        '/courses/${widget.lessonId}/stream-ticket',
      );
      final ticket = response.data['ticket'];

      final url =
          '${AppConstants.apiBaseUrl}/courses/${widget
          .lessonId}/stream/playlist.m3u8?ticket=$ticket';

      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController!.initialize();

      // خواندن شماره موبایل کاربر برای پاس دادن به واترمارک
      final userPhone = ref
          .read(authProvider)
          .phoneNumber ?? 'کاربر رویال کیک';

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.accent,
          backgroundColor: Colors.white.withOpacity(0.3),
          bufferedColor: Colors.white.withOpacity(0.6),
        ),
        // 🔥 معجزه اصلی اینجاست؛ واترمارک را به بخش overlay چوی اضافه می‌کنیم
        overlay: MovingWatermark(userPhone: userPhone),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        try {
          ScreenProtector.preventScreenshotOff();
        } catch (_) {}
      }
    }

    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
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
        ),
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: AppColors.accent)
              : _hasError
              ? const Text(
            'خطا در بارگذاری ویدیو',
            style: TextStyle(color: Colors.white, fontFamily: 'Samim'),
          )
              : _chewieController != null &&
              _chewieController!.videoPlayerController.value.isInitialized
              ? AspectRatio(
            aspectRatio: _chewieController!
                .videoPlayerController
                .value
                .aspectRatio,
            child: Chewie(controller: _chewieController!),
          )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// 🔴 ویجت مستقل و هوشمند واترمارک متحرک برای پشتیبانی از حالت FullScreen
// 🔴 ویجت اصلاح‌شده واترمارک با سایز بزرگ‌تر و وضوح بیشتر
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
              // 🔴 تغییرات اعمال شده:
              color: Colors.white.withOpacity(0.45),
              // افزایش وضوح (از ۰.۲۵ به ۰.۴۵)
              fontSize: 19,
              // بزرگ‌تر شدن ابعاد متن (از ۱۵ به ۱۹)
              fontWeight: FontWeight.w900,
              // ضخامت فوق‌العاده برای خوانایی بهتر
              fontFamily: 'Samim',
              shadows: [
                Shadow(
                  offset: const Offset(1.5, 1.5),
                  // سایه کمی پهن‌تر برای تفکیک از پس‌زمینه ویدیو
                  blurRadius: 4.0,
                  // محوشدگی ملایم دور سایه
                  color: Colors.black.withOpacity(
                      0.7), // تیره کردن سایه برای خوانایی روی بخش‌های سفید ویدیو
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}