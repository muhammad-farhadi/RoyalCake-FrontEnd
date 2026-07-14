import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

// پرووایدر مدیریت وضعیت نوار ناوبری پایین
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
final authStateProvider = StateProvider<bool>((ref) => false);

// 🔴 پرووایدر فیلتر هوشمند دوره‌ها (null = همه، true = رایگان، false = پولی)
final courseFilterProvider = StateProvider<bool?>((ref) => null);

// 🔴 پرووایدر دوره‌ها (این پرووایدر حالا به فیلتر بالا گوش می‌دهد)
final coursesProvider = FutureProvider<List<dynamic>>((ref) async {
  final isFree = ref.watch(courseFilterProvider);
  final dio = ref.read(dioProvider);

  String url =
      '/courses/?skip=0&limit=50'; // محدودیت بالاتر برای لود بهتر لیست کامل
  if (isFree != null) {
    url += '&is_free=$isFree';
  }

  final response = await dio.get(url);
  return response.data as List<dynamic>;
});

// 🔴 پرووایدر جدید مخصوص دوره‌های پولی (تخصصی) روی داشبورد
final homePaidCoursesProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/courses/?skip=0&limit=10&is_free=false');
  return response.data as List<dynamic>;
});

// 🔴 پرووایدر جدید مخصوص آموزش‌های رایگان روی داشبورد
final homeFreeCoursesProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/courses/?skip=0&limit=10&is_free=true');
  return response.data as List<dynamic>;
});

// ==========================================
// سیستم جدید مدیریت گالری (رندومِ بدون تکرار)
// ==========================================
class GalleryState {
  final bool isLoading;
  final bool isFetchingMore;
  final String? error;
  final List<dynamic> images;
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
  final int _limit = 12;

  List<dynamic> _allShuffledImages = [];
  int _currentIndex = 0;

  GalleryNotifier(this.ref) : super(GalleryState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/gallery/?skip=0&limit=200');
      _allShuffledImages = List<dynamic>.from(response.data);
      _allShuffledImages.shuffle(Random());

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

  Future<void> loadMore() async {
    if (!state.hasMore || state.isFetchingMore) return;

    state = state.copyWith(isFetchingMore: true);
    await Future.delayed(const Duration(milliseconds: 400));

    final newData = _allShuffledImages
        .skip(_currentIndex)
        .take(_limit)
        .toList();
    _currentIndex += newData.length;

    state = state.copyWith(
      isFetchingMore: false,
      images: [...state.images, ...newData],
      hasMore: _currentIndex < _allShuffledImages.length,
    );
  }
}

final galleryProvider = StateNotifierProvider<GalleryNotifier, GalleryState>((
  ref,
) {
  return GalleryNotifier(ref);
});

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
