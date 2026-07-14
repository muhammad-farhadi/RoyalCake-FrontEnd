import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart'; // 🔴 پکیج جدید، لوکال و بدون نیاز به تنظیمات وب
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/app_colors.dart';

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
    _loadSecurePdf();
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
  Widget build(BuildContext context) {
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
                // 🔴 رندر کاملاً بومی، روان و امنِ بایت‌ها بدون دستکاری index.html
                child: PdfPreview(
                  build: (format) => _pdfBytes!,
                  allowPrinting: false,
                  // 🔒 غیرفعال کردن دکمه پرینت
                  allowSharing: false,
                  // 🔒 غیرفعال کردن دکمه دانلود و اشتراک‌گذاری بیرون برنامه
                  canChangePageFormat: false,
                  // قفل کردن سایز صفحه
                  canChangeOrientation: false,
                  // قفل کردن چرخش صفحه
                  canDebug: false,
                  actions: const [], // حذف هرگونه دکمه اضافی از تولبار
                ),
              ),
      ),
    );
  }
}
