import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../util/color.dart';

class CigarettesNotSmokedDetailDialog extends GetView<HomeController> {
  const CigarettesNotSmokedDetailDialog({super.key});

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목과 닫기 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '흡연량 자제 현황',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 스크롤 가능한 내용
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 현재 안 피운 개비 수
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColor.primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                '안 피운 개비',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_formatNumber(controller.cigarettesNotSmoked)}개비',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '약 ${(controller.cigarettesNotSmoked / 20).toStringAsFixed(1)}갑',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 경각심을 유발하는 수치들
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColor.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🚭 자제한 유해성분',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColor.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Obx(() => _buildWarningRow(
                                  label: '니코틴',
                                  value:
                                      '${(controller.cigarettesNotSmoked * 1.2).toStringAsFixed(1)}mg',
                                  description: '중독성 물질',
                                )),
                            const SizedBox(height: 12),
                            Obx(() => _buildWarningRow(
                                  label: '타르',
                                  value:
                                      '${(controller.cigarettesNotSmoked * 12).toStringAsFixed(0)}mg',
                                  description: '발암물질',
                                )),
                            const SizedBox(height: 12),
                            Obx(() => _buildWarningRow(
                                  label: '일산화탄소',
                                  value:
                                      '${(controller.cigarettesNotSmoked * 15).toStringAsFixed(0)}mg',
                                  description: '혈액 산소 운반 방해',
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 수명 관련 경각심
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.timer_off,
                                    color: Colors.orange.shade700, size: 24),
                                const SizedBox(width: 8),
                                const Text(
                                  '수명 회복',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Obx(() {
                              // 담배 한 개비당 약 11분의 수명 단축
                              final lifeRegainedMinutes =
                                  controller.cigarettesNotSmoked * 11;
                              final lifeRegainedHours = lifeRegainedMinutes ~/ 60;
                              final lifeRegainedDays = lifeRegainedHours ~/ 24;
                              final remainingHours = lifeRegainedHours % 24;
                              final remainingMinutes = lifeRegainedMinutes % 60;

                              String lifeRegainedText = '';
                              if (lifeRegainedDays > 0) {
                                lifeRegainedText =
                                    '${lifeRegainedDays}일 ${remainingHours}시간';
                              } else if (lifeRegainedHours > 0) {
                                lifeRegainedText =
                                    '${lifeRegainedHours}시간 ${remainingMinutes}분';
                              } else {
                                lifeRegainedText = '${lifeRegainedMinutes}분';
                              }

                              return _buildImpactItem(
                                '회복한 수명',
                                lifeRegainedText,
                              );
                            }),
                            const SizedBox(height: 8),
                            const Text(
                              '💡 담배 한 개비당 약 11분의 수명이 단축됩니다',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 건강 영향
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.red.shade700, size: 24),
                                const SizedBox(width: 8),
                                const Text(
                                  '건강에 미치는 영향',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Obx(() {
                              final packs = controller.cigarettesNotSmoked / 20;
                              return Column(
                                children: [
                                  _buildImpactItem(
                                    '심장질환 위험 감소',
                                    '약 ${(packs * 0.5).toStringAsFixed(1)}%',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildImpactItem(
                                    '폐암 위험 감소',
                                    '약 ${(packs * 0.3).toStringAsFixed(1)}%',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildImpactItem(
                                    '호흡기 기능 개선',
                                    '약 ${(packs * 0.4).toStringAsFixed(1)}%',
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 경각심을 유발하는 절대값들
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                const Text(
                                  '⚠️ 경각심을 주는 수치',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Obx(() {
                              final cigarettes = controller.cigarettesNotSmoked;
                              return Column(
                                children: [
                                  _buildAbsoluteValueRow(
                                    '담배 한 개비당',
                                    '11분의 수명 단축',
                                    Colors.white70,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildAbsoluteValueRow(
                                    '담배 한 개비당',
                                    '4,000가지 이상의 화학물질',
                                    Colors.white70,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildAbsoluteValueRow(
                                    '담배 한 개비당',
                                    '70가지 이상의 발암물질',
                                    Colors.red.shade300,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildAbsoluteValueRow(
                                    '당신이 자제한',
                                    '${_formatNumber(cigarettes)}개비 = 약 ${(cigarettes / 20).toStringAsFixed(1)}갑',
                                    Colors.green.shade300,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildAbsoluteValueRow(
                                    '이 수치가 의미하는 것',
                                    '${(cigarettes * 11 / 60).toStringAsFixed(1)}시간의 수명 회복',
                                    Colors.orange.shade300,
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 닫기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningRow({
    required String label,
    required String value,
    required String description,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColor.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildImpactItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColor.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildAbsoluteValueRow(
      String label, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

