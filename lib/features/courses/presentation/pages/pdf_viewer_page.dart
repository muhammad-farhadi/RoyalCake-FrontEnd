import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:screen_protector/screen_protector.dart'; // 🔴 ایمپورت محافظ صفحه نمایش
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart'; // ایمپورت پرووایدر احراز هویت

class PdfViewerPage extends ConsumerStatefulWidget {
  final int docId;
  final String docTitle;

  const PdfViewerPage({super.key, required this.docId, required this.docTitle});

  @override
  ConsumerState<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends ConsumerState<PdfViewerPage> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _secureScreen(); // 🔴 فعال‌سازی لایه امنیتی ضد اسکرین‌شات
    _loadSecurePdf();
  }

  // 🔴 متد غیرفعال کردن اسکرین‌شات و فیلم‌برداری از صفحه در اندروید و iOS
  Future<void> _secureScreen() async {
    if (kIsWeb) return;
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        await ScreenProtector.preventScreenshotOn();
      } catch (e) {
        debugPrint('خطا در فعال‌سازی محافظ صفحه PDF: $e');
      }
    }
  }

  Future<void> _loadSecurePdf() async {
    try {
      final dio = ref.read(dioProvider);

      final response = await dio.get(
        '/courses/docs/${widget.docId}/pdf-view',
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data != null) {
        setState(() {
          _pdfBytes = Uint8List.fromList(response.data);
          _isLoading = false;
        });
      } else {
        throw Exception("فایل خالی است");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            "خطا در بارگذاری جزوه. لطفاً دسترسی خود یا اتصال اینترنت را بررسی کنید.";
      });
    }
  }

  @override
  void dispose() {
    // 🔴 آزاد کردن قفل اسکرین‌شات سیستم‌عامل هنگام خروج از صفحه جزوه
    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        try {
          ScreenProtector.preventScreenshotOff();
        } catch (_) {}
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // خواندن شماره موبایل هنرجو برای تزریق به لایه واترمارک
    final userPhone = ref.watch(authProvider).phoneNumber ?? 'کاربر رویال کیک';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xfff5f5f5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          foregroundColor: AppColors.primary,
          centerTitle: true,
          title: Text(
            widget.docTitle,
            style: const TextStyle(
              fontFamily: 'Samim',
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'در حال آماده‌سازی جزوه...',
                      style: TextStyle(
                        fontFamily: 'Samim',
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            : _errorMessage != null
            ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontFamily: 'Samim',
                    color: Colors.redAccent,
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    // 🔴 قابلیت زوم هوشمند مهارشده فقط روی لایه خودِ PDF
                    Positioned.fill(
                      child: InteractiveViewer(
                        minScale: 1.0,
                        maxScale:
                            4.5, // اجازه زوم دو انگشتی تا ۴.۵ برابر بزرگتر
                        child: PdfPreview(
                          build: (format) => _pdfBytes!,
                          allowPrinting: false,
                          allowSharing: false,
                          canChangePageFormat: false,
                          canChangeOrientation: false,
                          canDebug: false,
                          actions: const [],
                        ),
                      ),
                    ),

                    // 🔒 واترمارک چون بیرون از InteractiveViewer است، با زوم و پن کردن کاربر کاملاً ثابت و مهارشده باقی می‌ماند
                    MovingPdfWatermark(userPhone: userPhone),
                  ],
                ),
              ),
      ),
    );
  }
}

// ===================================================================
// 🔴 ویجت اختصاصی واترمارک متحرک روی فایلهای PDF (بهینه‌شده برای صفحات روشن)
// ===================================================================
class MovingPdfWatermark extends StatefulWidget {
  final String userPhone;

  const MovingPdfWatermark({super.key, required this.userPhone});

  @override
  State<MovingPdfWatermark> createState() => _MovingPdfWatermarkState();
}

class _MovingPdfWatermarkState extends State<MovingPdfWatermark> {
  final Random _random = Random();
  Timer? _watermarkTimer;
  Alignment _watermarkAlignment = Alignment.center;

  @override
  void initState() {
    super.initState();
    _startWatermarkMovement();
  }

  void _startWatermarkMovement() {
    _watermarkTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          // تولید محدودتر محدوده حرکتی برای جلوگیری از بیرون زدن شماره از کادر ابزار PDF
          final x = (_random.nextDouble() * 1.6) - 0.8;
          final y = (_random.nextDouble() * 1.6) - 0.8;
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
        duration: const Duration(seconds: 5),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            widget.userPhone,
            style: TextStyle(
              // 🔴 بهینه‌سازی رنگ برای پس‌زمینه سفید جزوات (مشکی نیمه شفاف با سایه ملایم سفید)
              color: Colors.black.withOpacity(0.18),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'Samim',
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 2.0,
                  color: Colors.white.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
