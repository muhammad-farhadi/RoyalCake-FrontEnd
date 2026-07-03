import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UniversalImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;
  final int?
  cacheWidth; // 🔴 اضافه شدن پارامتر کش سایز برای جلوگیری از کرش سافاری

  const UniversalImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorWidget,
    this.cacheWidth, // 🔴 مقداردهی
  });

  @override
  Widget build(BuildContext context) {
    final defaultError =
        errorWidget ??
        const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.black26),
        );

    if (kIsWeb) {
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        cacheWidth: cacheWidth,
        filterQuality: FilterQuality.none, // 🔴 معجزه سرعت: غیرفعال کردن رندر سنگین پیکسلی در وب
        gaplessPlayback: true, // 🔴 جلوگیری از چشمک زدن عکس در اسکرول بالا و پایین
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
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        cacheWidth: cacheWidth,
        // 🔴 اعمال کش سایز در اندروید (برای روانی بیشتر اسکرول)
        errorBuilder: (context, error, stackTrace) => defaultError,
      );
    }
  }
}
