import 'package:flutter/foundation.dart' show kIsWeb; // اضافه شد
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../gallery/presentation/pages/universal_image.dart';

// ================== بخش ویژگی‌های متمایز ==================
class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const FeatureItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 26),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontFamily: 'Samim',
            color: Colors.black.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

// ================== دایره‌های دسته‌بندی ==================
class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const CategoryItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xfff5ebe6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xff8d6e63), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
              fontFamily: 'Samim',
            ),
          ),
        ],
      ),
    );
  }
}

// ================== کارت دوره‌ها ==================
class CourseCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // گرفتن آدرس کامل عکس
    final fullUrl = AppConstants.getFullImageUrl(imageUrl);

    return Container(
      width: 165, // عرض ثابت برای یکدست شدن کارت‌ها
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------
              // بخش بالایی: عکس دوره
              // ------------------------------------
              Expanded(
                flex: 5,
                child: SizedBox(
                  width: double.infinity,
                  child: Image.network(
                    fullUrl,
                    fit: BoxFit.contain, // 🔴 تغییر از cover به contain برای نمایش کامل عکس دوره در داشبورد
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              // ------------------------------------
              // بخش پایینی: متن‌ها
              // ------------------------------------
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 👇 جادوی یک‌خطی ماندن و کوچک شدن سایز فونت اینجاست
                      SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          // اگر جا نشد کوچیکش کن
                          alignment: Alignment.centerRight,
                          // از راست به چپ بچین
                          child: Text(
                            title,
                            maxLines: 1, // فقط و فقط یک خط!
                            style: const TextStyle(
                              fontSize: 13.5, // سایز ایده‌آل پیش‌فرض
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Samim',
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                      ),

                      // قیمت
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Samim',
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== میانبر نوار پایین ==================
class BottomNavShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const BottomNavShortcut({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppColors.primary : color, size: 24),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.primary : Colors.black45,
              fontFamily: 'Samim',
            ),
          ),
        ],
      ),
    );
  }
}
