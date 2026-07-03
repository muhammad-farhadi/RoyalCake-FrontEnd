import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UniversalImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;

  const UniversalImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // ویجت پایه خطا
    final defaultError =
        errorWidget ??
        const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.black26),
        );

    if (kIsWeb) {
      // رندر بهینه پلتفرم وب در نسخه‌های جدید فلاتر برای جلوگیری از پر شدن رم سافاری آیفون
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => defaultError,
      );
    } else {
      // رندر بومی و سریع برای خروجی اندروید و ویندوز
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => defaultError,
      );
    }
  }
}
