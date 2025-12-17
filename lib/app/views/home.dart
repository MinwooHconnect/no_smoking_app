import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/home_controller.dart';
import '../util/color.dart';
import '../widgets/progress_card.dart';
import '../widgets/stats_grid_card.dart';
import '../widgets/future_rewards_card.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/tutorial_overlay.dart';

class Home extends GetView<HomeController> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // 메인 진행률 카드
                const ProgressCard(),

                // 통계 그리드
                const StatsGridCard(),

                // 애드몹 광고
                const AdBannerWidget(),

                // // 과거 흡연 기간 카드
                // const SmokingPeriodCard(),

                // 미래 보상 카드
                const FutureRewardsCard(),

                const SizedBox(height: 32),
              ],
            ),
          ),
          // 튜토리얼 오버레이 (첫 실행 시에만 표시, 데이터 로드 완료 후)
          Obx(
            () =>
                controller.isDataLoaded.value &&
                    controller.isFirstRun.value &&
                    !controller.isQuittingStarted.value
                ? TutorialOverlay(
                    targetKey: controller.startButtonKey,
                    onComplete: () {
                      controller.completeTutorial();
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        '도와줘 금연',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
      actions: [
        // 앱 공유하기 버튼
        IconButton(icon: const Icon(Icons.share), onPressed: () => _shareApp()),
        // 알림 설정 버튼 (종 아이콘 토글)
        Obx(
          () => IconButton(
            icon: Icon(
              controller.isNotificationVisible.value
                  ? Icons.notifications_active
                  : Icons.notifications_off,
            ),
            onPressed: () {
              if (controller.isQuittingStarted.value) {
                final wasVisible = controller.isNotificationVisible.value;
                controller.toggleNotification();
                Get.snackbar(
                  wasVisible ? '알림 숨김' : '알림 표시',
                  wasVisible ? '금연 중 알림이 숨겨졌습니다.' : '금연 중 알림이 표시됩니다.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColor.primary.withValues(alpha: 0.9),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(16),
                  borderRadius: 8,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                );
              } else {
                Get.snackbar(
                  '알림',
                  '금연을 시작하면 알림을 사용할 수 있습니다.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColor.primary.withValues(alpha: 0.9),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(16),
                  borderRadius: 8,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  // 앱 공유하기
  void _shareApp() {
    const playStoreLink =
        'https://play.google.com/store/apps/details?id=com.example.no_smoking_app';
    const shareText =
        '''
🚭 금연 앱을 추천합니다!

건강한 금연 여정을 함께 시작해보세요.
$playStoreLink
''';

    Share.share(shareText, subject: '금연 앱 추천');
  }
}
