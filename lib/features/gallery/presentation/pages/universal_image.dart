import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UniversalImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;
  final int? cacheWidth;

  const UniversalImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorWidget,
    this.cacheWidth,
  });

  @override
  Widget build(BuildContext context) {
    final defaultError =
        errorWidget ??
        const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.black26),
        );

    return Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      // 🔴 معجزه اصلی کنترل رم فلاتر همینجاست. عکس باکیفیت رو در همون سایزی که میخوایم تو رم نگه میداره
      cacheWidth: cacheWidth,
      errorBuilder: (context, error, stackTrace) => defaultError,
    );
  }
}
