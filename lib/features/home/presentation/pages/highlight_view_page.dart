import 'package:flutter/material.dart';
import '../../data/models/highlight_model.dart';
import '../../../../features/gallery/presentation/pages/universal_image.dart';
import '../../../../core/constants/app_constants.dart';

class HighlightViewPage extends StatefulWidget {
  final HighlightCategoryModel category;

  const HighlightViewPage({super.key, required this.category});

  @override
  State<HighlightViewPage> createState() => _HighlightViewPageState();
}

// 🔴 اضافه کردن TickerProviderStateMixin برای مدیریت انیمیشن بار بالای صفحه
class _HighlightViewPageState extends State<HighlightViewPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  AnimationController? _animController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // راه‌اندازی اولین استوری
    _initStoryPage(isFirst: true);
  }

  // 🔴 تابع اصلی مدیریت و زمان‌بندی هر استوری
  void _initStoryPage({bool isFirst = false}) {
    _animController?.dispose();

    // تعریف انیمیشن ۵ ثانیه‌ای برای هر عکس
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // گوش دادن به پایان انیمیشن برای رفتن به استوری بعدی به صورت خودکار
    _animController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    // شروع انیمیشن بار
    _animController!.forward();

    if (!isFirst) {
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStory() {
    if (_currentIndex < widget.category.items.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _initStoryPage();
    } else {
      // اگر استوری‌ها تمام شد، صفحه بسته شود
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _initStoryPage();
    }
  }

  // مدیریت تاچ دستی کاربر
  void _onTapPage(TapUpDetails details) {
    final width = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;

    // ضربه به سمت راست صفحه (در RTL یعنی صفحه قبل)
    if (dx > width / 2) {
      _previousStory();
    } else {
      // ضربه به سمت چپ صفحه (صفحه بعد)
      _nextStory();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = widget.category.items[_currentIndex];
    final dateStr =
        "${currentItem.createdAt.year}/${currentItem.createdAt.month}/${currentItem.createdAt.day}";

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTapUp: _onTapPage,
          // 🔴 قابلیت خفن: اگر کاربر دستش را نگه داشت استوری استاپ (Pause) شود
          onLongPress: () => _animController?.stop(),
          // وقتی دستش را برداشت انیمیشن ادامه پیدا کند (Resume)
          onLongPressUp: () => _animController?.forward(),
          child: Stack(
            children: [
              // ۱. اسلایدر اصلی عکس‌ها
              PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.category.items.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: UniversalImage(
                      fit: BoxFit.contain,
                      imageUrl: AppConstants.getFullImageUrl(
                        widget.category.items[index].imageUrl,
                      ),
                    ),
                  );
                },
              ),

              // ۲. خط‌های انیمیشنی پرشونده بالای استوری (Progress Indicators)
              Positioned(
                top: 15,
                left: 10,
                right: 10,
                child: Row(
                  children: List.generate(widget.category.items.length, (
                    index,
                  ) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: index == _currentIndex
                            ? AnimatedBuilder(
                                animation: _animController!,
                                builder: (context, child) {
                                  return LinearProgressIndicator(
                                    value: _animController!.value,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.3,
                                    ),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                    minHeight: 3,
                                  );
                                },
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: index < _currentIndex
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                      ),
                    );
                  }),
                ),
              ),

              // ۳. اطلاعات بالای هایلایت (کاور، عنوان و تاریخ)
              Positioned(
                top: 30,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                            AppConstants.getFullImageUrl(
                              widget.category.coverUrl,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.category.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Samim',
                          ),
                        ),
                      ],
                    ),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'Samim',
                      ),
                    ),
                  ],
                ),
              ),

              // دکمه خروج ضربدر
              Positioned(
                top: 70,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
