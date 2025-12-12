import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../util/color.dart';

class SmokingPeriodCard extends GetView<HomeController> {
  const SmokingPeriodCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
              '담배를 피운 기간 동안:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildSmokingStatRow(
              icon: Icons.smoking_rooms,
              value: controller.totalCigarettesSmoked.toString(),
              label: '담배 연기',
            ),
            const SizedBox(height: 12),
            _buildSmokingStatRow(
              icon: Icons.attach_money,
              value: controller.totalMoneyWastedFormatted,
              label: '돈 낭비',
            ),
            const SizedBox(height: 12),
            _buildSmokingStatRow(
              icon: Icons.access_time,
              value: controller.totalLifeLostFormatted,
              label: '생명 손실',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmokingStatRow({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColor.icon.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: AppColor.icon),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColor.accent,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColor.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

