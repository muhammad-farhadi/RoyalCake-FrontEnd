import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../gallery/presentation/pages/universal_image.dart';
import '../../providers/app_tutorials_provider.dart';
import 'tutorial_video_player_page.dart'; // 🔴 ایمپورت پلیر جدید و مجزا

class AppTutorialPage extends ConsumerStatefulWidget {
  const AppTutorialPage({super.key});

  @override
  ConsumerState<AppTutorialPage> createState() => _AppTutorialPageState();
}

class _AppTutorialPageState extends ConsumerState<AppTutorialPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: true,
          title: const Text(
            'راهنما و آموزش‌ها',
            style: TextStyle(
              fontFamily: 'Samim',
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 17,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            // تب‌بار کپسولی و شکیل
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade700,
                labelStyle: const TextStyle(
                  fontFamily: 'Samim',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Samim',
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_outline_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('فیلم‌های آموزشی'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.downloading_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('راهنمای نصب'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // محتوای تب‌ها
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [_TutorialVideosTab(), _InstallGuideTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// ۱. لیست کارت‌های ویدیوهای آموزشی
// ===================================================================
class _TutorialVideosTab extends ConsumerWidget {
  const _TutorialVideosTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorialsState = ref.watch(appTutorialsProvider);

    return tutorialsState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'خطا در بارگذاری ویدیوها',
              style: TextStyle(fontFamily: 'Samim', color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(appTutorialsProvider),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'تلاش مجدد',
                style: TextStyle(fontFamily: 'Samim'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      data: (tutorials) {
        if (tutorials.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.video_library_outlined,
                  size: 54,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                const Text(
                  'ویدیوی آموزشی ثبت نشده است.',
                  style: TextStyle(fontFamily: 'Samim', color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(appTutorialsProvider),
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: tutorials.length,
            itemBuilder: (context, index) {
              final tutorial = tutorials[index];
              final fullCoverUrl =
                  tutorial.coverUrl != null && tutorial.coverUrl!.isNotEmpty
                  ? AppConstants.getFullImageUrl(tutorial.coverUrl!)
                  : null;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // 🔴 ارجاع به پلیر جدید و اختصاصی بدون دست زدن به بخش دوره‌ها
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TutorialVideoPlayerPage(
                              videoUrl: tutorial.videoUrl,
                              title: tutorial.title,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: fullCoverUrl != null
                                    ? UniversalImage(
                                        imageUrl: fullCoverUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: AppColors.primary.withOpacity(
                                          0.08,
                                        ),
                                        child: const Icon(
                                          Icons.movie_creation_outlined,
                                          size: 48,
                                          color: AppColors.primary,
                                        ),
                                      ),
                              ),
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tutorial.title,
                                  style: const TextStyle(
                                    fontFamily: 'Samim',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                if (tutorial.caption != null &&
                                    tutorial.caption!.trim().isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    tutorial.caption!.trim(),
                                    style: TextStyle(
                                      fontFamily: 'Samim',
                                      fontSize: 12.5,
                                      color: Colors.grey.shade600,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ===================================================================
// ۲. راهنمای نصب گام‌به‌گام
// ===================================================================
class _InstallGuideTab extends StatelessWidget {
  const _InstallGuideTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        _buildOSCard(
          title: 'راهنمای نصب در آیفون (iOS - Safari)',
          icon: Icons.apple_rounded,
          color: Colors.black,
          steps: [
            'سایت رویال کیک را در مرورگر Safari باز کنید.',
            'در پایین مرورگر دکمه Share (مربع با فلش رو به بالا) را بزنید.',
            'از منوی باز شده گزینه «Add to Home Screen» را انتخاب کنید.',
            'در بالای صفحه سمت چپ گزینه «Add» را لمس کنید.',
          ],
        ),
        const SizedBox(height: 16),
        _buildOSCard(
          title: 'راهنمای نصب در اندروید (Android - Chrome)',
          icon: Icons.android_rounded,
          color: const Color(0xff3DDC84),
          steps: [
            'سایت رویال کیک را در مرورگر Chrome باز کنید.',
            'دکمه ۳ نقطه در بالای سمت راست مرورگر را بزنید.',
            'گزینه «Add to Home screen» یا «Install App» را انتخاب کنید.',
            'پیام تأیید را بزنید تا برنامه روی گوشی نصب شود.',
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildOSCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> steps,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Samim',
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final stepText = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      stepText,
                      style: const TextStyle(
                        fontFamily: 'Samim',
                        fontSize: 12.5,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
