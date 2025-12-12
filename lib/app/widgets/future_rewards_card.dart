import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../util/color.dart';

class FutureRewardsCard extends GetView<HomeController> {
  const FutureRewardsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
            ...controller.futureRewards.asMap().entries.map((entry) {
              final index = entry.key;
              final reward = entry.value;
              return Column(
                children: [
                  _buildRewardRow(
                    period: reward.period,
                    money: '₩ ${reward.money.toStringAsFixed(0)}',
                    life: controller.formatFutureLife(reward.life),
                  ),
                  if (index < controller.futureRewards.length - 1)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      height: 1,
                      color: AppColor.divider,
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardRow({
    required String period,
    required String money,
    required String life,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            period,
            style: const TextStyle(fontSize: 16, color: AppColor.textPrimary),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            money,
            style: const TextStyle(fontSize: 16, color: AppColor.textPrimary),
            textAlign: TextAlign.right,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            life,
            style: const TextStyle(fontSize: 16, color: AppColor.textPrimary),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

