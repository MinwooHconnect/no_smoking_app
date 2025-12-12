import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../util/color.dart';
import 'circular_progress_painter.dart';
import 'target_period_dialog.dart';

class ProgressCard extends GetView<HomeController> {
  const ProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    '일 ${controller.days + 1}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    showDialog(
                      context: Get.context!,
                      builder: (context) => TargetPeriodDialog(
                        currentTarget: controller.targetPeriod.value,
                        onSelect: (period) {
                          final previousPeriod = controller.targetPeriod.value;
                          controller.setTargetPeriod(period);

                          // 선택 피드백 스낵바 표시
                          if (previousPeriod != period) {
                            Get.snackbar(
                              '목표 기간 변경',
                              '목표 기간이 "$period"로 설정되었습니다.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColor.primary.withValues(
                                alpha: 0.9,
                              ),
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                              margin: const EdgeInsets.all(16),
                              borderRadius: 8,
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // 원형 진행률 표시
          SizedBox(
            height: 280,
            child: Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Obx(
                  () => CustomPaint(
                    painter: CircularProgressPainter(
                      progress: controller.progressPercentage / 100,
                      progressColor: AppColor.accent,
                      backgroundColor: AppColor.progressBackground,
                      strokeWidth: 16,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: controller.progressPercentage
                                      .toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w300,
                                    color: AppColor.accent,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' %',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w300,
                                    color: AppColor.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${controller.days + 1}일',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColor.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              '저는 자제 중입니다!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
