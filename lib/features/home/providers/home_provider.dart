import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

// پرووایدر مدیریت وضعیت نوار ناوبری پایین
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

// پرووایدر دوره‌ها
final coursesProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/courses/?skip=0&limit=10');
  return response.data as List<dynamic>;
});

// ==========================================
// سیستم جدید مدیریت گالری (رندومِ بدون تکرار)
// ==========================================
class GalleryState {
  final bool isLoading;
  final bool isFetchingMore;
  final String? error;
  final List<dynamic> images; // تصاویری که در حال حاضر روی صفحه هستند
  final bool hasMore;

  GalleryState({
    this.isLoading = false,
    this.isFetchingMore = false,
    this.error,
    this.images = const [],
    this.hasMore = true,
  });

  GalleryState copyWith({
    bool? isLoading,
    bool? isFetchingMore,
    String? error,
    List<dynamic>? images,
    bool? hasMore,
  }) {
    return GalleryState(
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      error: error ?? this.error,
      images: images ?? this.images,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class GalleryNotifier extends StateNotifier<GalleryState> {
  final Ref ref;
  final int _limit = 12; // تعداد عکسی که در هر بار لود اضافه می‌شود

  List<dynamic> _allShuffledImages = []; // مخزن اصلی و شافل شده کل عکس‌ها
  int _currentIndex = 0; // نشانگر اینکه تا کجای لیست پیش رفته‌ایم

  GalleryNotifier(this.ref) : super(GalleryState()) {
    loadInitial();
  }

  // ۱. دریافت یکباره، شافل کردن کل دیتا و نمایش ۱۲ تای اول
  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);

      // گرفتن مثلاً ۲۰۰ عکس جدید از سرور با یک ریکوئست سبک
      final response = await dio.get('/gallery/?skip=0&limit=200');
      _allShuffledImages = List<dynamic>.from(response.data);

      // جادوی اصلی: شافل کردن کل ۲۰۰ عکس همین اول کار
      _allShuffledImages.shuffle(Random());

      // جدا کردن ۱۲ عکس اول برای نمایش اولیه
      final initialData = _allShuffledImages.take(_limit).toList();
      _currentIndex = initialData.length;

      state = state.copyWith(
        isLoading: false,
        images: initialData,
        hasMore: _currentIndex < _allShuffledImages.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'خطا در دریافت تصاویر');
    }
  }

  // ۲. نمایش ۱۲ عکس بعدی از داخل مخزن شافل شده (بدون نیاز به ریکوئست جدید)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isFetchingMore) return;

    state = state.copyWith(isFetchingMore: true);

    // یک دیلی کوچیک واسه اینکه دکمه لودینگش نرم و طبیعی به نظر بیاد (UX بهتر)
    await Future.delayed(const Duration(milliseconds: 400));

    // برداشتن ۱۲ عکس بعدی از جایی که دفعه قبل متوقف شدیم
    final newData = _allShuffledImages
        .skip(_currentIndex)
        .take(_limit)
        .toList();
    _currentIndex += newData.length;

    state = state.copyWith(
      isFetchingMore: false,
      images: [...state.images, ...newData], // چسباندن عکس‌های جدید به قبلی‌ها
      hasMore:
          _currentIndex <
          _allShuffledImages.length, // چک کردن اینکه بازم عکس داریم یا نه
    );
  }
}

// جایگزینی پرووایدر گالری
final galleryProvider = StateNotifierProvider<GalleryNotifier, GalleryState>((
  ref,
) {
  return GalleryNotifier(ref);
});

// تابع فرمت قیمت
String formatPrice(dynamic price) {
  if (price == null || price == 0) return 'رایگان';
  final strPrice = price.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  String farsiPrice = strPrice;
  for (int i = 0; i < english.length; i++) {
    farsiPrice = farsiPrice.replaceAll(english[i], farsi[i]);
  }
  return '$farsiPrice تومان';
}
