import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/models/highlight_model.dart';

class HighlightsState {
  final bool isLoading;
  final List<HighlightCategoryModel> categories;
  final String? error;

  HighlightsState({
    this.isLoading = false,
    this.categories = const [],
    this.error,
  });

  HighlightsState copyWith({
    bool? isLoading,
    List<HighlightCategoryModel>? categories,
    String? error,
  }) {
    return HighlightsState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      error: error,
    );
  }
}

class HighlightsNotifier extends StateNotifier<HighlightsState> {
  final Ref ref;

  HighlightsNotifier(this.ref) : super(HighlightsState()) {
    fetchHighlights();
  }

  Future<void> fetchHighlights() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/highlights'); // آدرس ست شده در بک‌اند

      final List data = response.data;
      final categories = data
          .map((e) => HighlightCategoryModel.fromJson(e))
          .toList();

      state = state.copyWith(isLoading: false, categories: categories);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'خطا در دریافت هایلایت‌ها',
      );
    }
  }
}

final highlightsProvider =
    StateNotifierProvider<HighlightsNotifier, HighlightsState>((ref) {
      return HighlightsNotifier(ref);
    });
