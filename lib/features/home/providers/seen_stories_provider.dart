import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeenStoriesNotifier extends StateNotifier<Set<String>> {
  static const String _prefKey = 'seen_individual_story_items';

  SeenStoriesNotifier() : super({}) {
    _loadSeenStories();
  }

  Future<void> _loadSeenStories() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedIds = prefs.getStringList(_prefKey);
    if (savedIds != null) {
      state = savedIds.toSet();
    }
  }

  // 🔴 ثبت سین برای یک آیتم مشخص از استوری
  Future<void> markItemAsSeen(dynamic itemId) async {
    final idStr = itemId.toString();
    if (!state.contains(idStr)) {
      final newState = Set<String>.from(state)..add(idStr);
      state = newState;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, newState.toList());
    }
  }

  // 🔴 بررسی اینکه آیا تمام استوری‌های یک دسته سین خورده‌اند؟ (منطق اینستاگرام)
  bool isCategoryFullySeen(List<dynamic> items) {
    if (items.isEmpty) return true;
    return items.every((item) {
      final itemId = (item is Map ? item['id'] : item.id).toString();
      return state.contains(itemId);
    });
  }
}

final seenStoriesProvider =
    StateNotifierProvider<SeenStoriesNotifier, Set<String>>((ref) {
      return SeenStoriesNotifier();
    });
