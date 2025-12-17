import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../util/color.dart';

class FutureRewardsCard extends GetView<HomeController> {
  const FutureRewardsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '대가로 무엇을 받게 되나요?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '돈과 수명',
              style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                  2: FlexColumnWidth(3),
                },
                children: [
                  // 헤더 행
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColor.divider, width: 1),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '기간',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '돈',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textSecondary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '수명',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textSecondary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  // 데이터 행들
                  ...controller.futureRewards.map((reward) {
                    return TableRow(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColor.divider.withValues(alpha: 0.5),
                            width: 0.5,
                          ),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            reward.period,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColor.textPrimary,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            '₩ ${controller.formatMoney(reward.money)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColor.textPrimary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            controller.formatFutureLife(reward.life),
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColor.textPrimary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
