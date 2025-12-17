import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../util/color.dart';
import 'stat_card.dart';
import 'reset_confirm_dialog.dart';
import 'cigarettes_per_day_dialog.dart';
import 'money_saved_detail_dialog.dart';
import 'cigarettes_not_smoked_detail_dialog.dart';
import 'start_quitting_dialog.dart';

class StatsGridCard extends GetView<HomeController> {
  const StatsGridCard({super.key});

  // 초기화 버튼 탭 횟수 추적
  static int _resetTapCount = 0;
  static Timer? _resetTapTimer;
  static bool _hasShownMessage = false; // 메시지 표시 여부

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                        icon: Icons.access_time,
                        value: controller.elapsedFormatted,
                        label: '금연',
                      ),
                    ),
                  ),
                  Container(width: 1, height: 120, color: AppColor.divider),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: Get.context!,
                          builder: (context) => const MoneySavedDetailDialog(),
                        );
                      },
                      splashColor: AppColor.primary.withValues(alpha: 0.2),
                      highlightColor: AppColor.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      child: Obx(
                        () => StatCard(
                          icon: Icons.savings,
                          value: controller.moneySavedFormatted,
                          label: '돈 절약',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(height: 1, color: AppColor.divider),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final result = await showDialog<int>(
                          context: Get.context!,
                          builder: (context) => CigarettesPerDayDialog(
                            currentValue: controller.cigarettesPerDay.value,
                            isInitialValue:
                                !controller.isCigarettesPerDaySet.value,
                          ),
                        );

                        if (result != null) {
                          controller.setCigarettesPerDay(result);
                          Get.snackbar(
                            '설정 완료',
                            '하루 담배 개비 수가 ${result}개비로 설정되었습니다.',
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
                      splashColor: AppColor.primary.withValues(alpha: 0.2),
                      highlightColor: AppColor.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      child: Obx(
                        () => StatCard(
                          icon: Icons.smoking_rooms,
                          value: controller.isCigarettesPerDaySet.value
                              ? '${controller.cigarettesPerDay.value}개비'
                              : '하루 몇 개비\n피웠나요?',
                          label: controller.isCigarettesPerDaySet.value
                              ? '하루에 피웠던 개수'
                              : '탭하여 설정해주세요',
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 120, color: AppColor.divider),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: Get.context!,
                          builder: (context) =>
                              const CigarettesNotSmokedDetailDialog(),
                        );
                      },
                      splashColor: AppColor.primary.withValues(alpha: 0.2),
                      highlightColor: AppColor.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      child: Obx(
                        () => StatCard(
                          icon: Icons.smoke_free,
                          value: controller.cigarettesNotSmokedFormatted,
                          label: '안 피운 개비',
                        ),
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
              key: controller.startButtonKey,
              constraints: const BoxConstraints(minWidth: 80, minHeight: 40),
              decoration: BoxDecoration(
                color: AppColor.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColor.border, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(
                () => TextButton(
                  onPressed: () async {
                    if (controller.isQuittingStarted.value) {
                      // 초기화 버튼: 연속 5번 탭해야 다이얼로그 표시
                      _resetTapCount++;

                      // 타이머 리셋 (2초 내에 5번 탭해야 함)
                      _resetTapTimer?.cancel();
                      _resetTapTimer = Timer(const Duration(seconds: 2), () {
                        _resetTapCount = 0; // 2초 내에 5번 탭하지 않으면 리셋
                        _hasShownMessage = false; // 메시지 표시 플래그도 리셋
                      });

                      if (_resetTapCount >= 5) {
                        _resetTapCount = 0;
                        _hasShownMessage = false;
                        _resetTapTimer?.cancel();

                        // 초기화 다이얼로그 표시
                        final result = await showDialog<bool>(
                          context: Get.context!,
                          builder: (context) => const ResetConfirmDialog(),
                        );

                        if (result == true) {
                          controller.reset();
                        }
                      } else if (_resetTapCount == 1 && !_hasShownMessage) {
                        // 첫 번째 탭 시에만 메시지 표시
                        _hasShownMessage = true;
                        Get.snackbar(
                          '초기화',
                          '4번 더 탭하세요',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColor.primary.withValues(
                            alpha: 0.9,
                          ),
                          colorText: Colors.white,
                          duration: const Duration(milliseconds: 1500),
                          margin: const EdgeInsets.all(16),
                          borderRadius: 8,
                        );
                      }
                    } else {
                      // 아직 시작하지 않은 경우 금연 시작 다이얼로그 표시
                      final result = await showDialog<bool>(
                        context: Get.context!,
                        builder: (context) => const StartQuittingDialog(),
                      );

                      if (result == true) {
                        controller.startQuitting();
                        Get.snackbar(
                          '금연 시작!',
                          '당신의 금연 여정이 시작되었습니다.',
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
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    controller.isQuittingStarted.value ? '초기화' : '금연 시작!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.iconRefresh,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
