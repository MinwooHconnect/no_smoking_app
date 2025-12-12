import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../util/color.dart';
import 'stat_card.dart';
import 'reset_confirm_dialog.dart';

class StatsGridCard extends GetView<HomeController> {
  const StatsGridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.cardBackground,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColor.shadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => StatCard(
                        icon: Icons.flag,
                        value: controller.elapsedFormatted,
                        label: '금연',
                      ),
                    ),
                  ),
                  Container(width: 1, height: 120, color: AppColor.divider),
                  Expanded(
                    child: Obx(
                      () => StatCard(
                        icon: Icons.camera_alt_outlined,
                        value: controller.moneySavedFormatted,
                        label: '돈 절약',
                      ),
                    ),
                  ),
                ],
              ),
              Container(height: 1, color: AppColor.divider),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => StatCard(
                        icon: Icons.access_time,
                        value: controller.lifeRegainedFormatted,
                        label: '생명 되찾음',
                      ),
                    ),
                  ),
                  Container(width: 1, height: 120, color: AppColor.divider),
                  Expanded(
                    child: Obx(
                      () => StatCard(
                        icon: Icons.smoke_free,
                        value: controller.cigarettesNotSmokedFormatted,
                        label: '담배 연기 없음',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 중앙 새로고침 버튼
        Positioned(
          top: -24,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColor.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppColor.border, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: AppColor.iconRefresh,
                  size: 28,
                ),
                onPressed: () async {
                  final result = await showDialog<bool>(
                    context: Get.context!,
                    builder: (context) => const ResetConfirmDialog(),
                  );

                  if (result == true) {
                    controller.reset();
                    Get.snackbar(
                      '리셋 완료',
                      '금연 시간이 초기화되었습니다.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColor.primary.withValues(alpha: 0.9),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(16),
                      borderRadius: 8,
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
