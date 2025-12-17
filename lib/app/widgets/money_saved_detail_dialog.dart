import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';
import '../controllers/home_controller.dart';
import '../util/color.dart';

class MoneySavedDetailDialog extends GetView<HomeController> {
  const MoneySavedDetailDialog({super.key});

  String _formatMoney(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Future<void> _shareScreenshot(
    BuildContext context,
    GlobalKey screenshotKey,
  ) async {
    try {
      // RepaintBoundary의 RenderRepaintBoundary 가져오기
      final RenderRepaintBoundary boundary =
          screenshotKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      // 이미지 캡처
      final image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 임시 파일로 저장
      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/money_saved_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      // 공유 텍스트 생성
      final elapsed = controller.elapsedFormatted;
      final cigarettesPerDay = controller.cigarettesPerDay.value;
      final cigarettesNotSmoked = controller.cigarettesNotSmoked;
      final moneySaved = _formatMoney(controller.moneySaved);

      const playStoreLink =
          'https://play.google.com/store/apps/details?id=com.example.no_smoking_app';

      final shareText =
          '''
🚭 금연 성과를 공유합니다! 💪

💰 총 절약 금액: ₩ $moneySaved
⏰ 금연 기간: $elapsed
🚬 안 피운 개비: ${cigarettesNotSmoked}개비
📊 하루 담배 개비 수: ${cigarettesPerDay}개비

금연으로 건강과 돈을 모두 절약하고 있어요!

이 앱으로 금연을 시작해보세요!
$playStoreLink
''';

      // 공유
      await Share.shareXFiles([XFile(imagePath)], text: shareText);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('스크린샷 공유 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const pricePerCigarette = 225;
    final screenshotKey = GlobalKey();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목과 닫기 버튼 (스크린샷 제외)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '돈 절약 세부사항',
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
            // 정보 부분만 RepaintBoundary로 감싸기 (스크린샷에 포함)
            RepaintBoundary(
              key: screenshotKey,
              child: Column(
                children: [
                  // 계산 세부사항
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColor.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => _buildDetailRow(
                            label: '금연 기간',
                            value: controller.elapsedFormatted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => _buildDetailRow(
                            label: '하루 담배 개비 수',
                            value: '${controller.cigarettesPerDay.value}개비',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => _buildDetailRow(
                            label: '안 피운 개비 수',
                            value: '${controller.cigarettesNotSmoked}개비',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          label: '개비당 가격',
                          value: '₩ $pricePerCigarette',
                        ),
                        const Divider(height: 32),
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '계산식',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.textPrimary,
                                ),
                              ),
                              Text(
                                '${controller.cigarettesNotSmoked} × ₩ $pricePerCigarette',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 총 절약 금액
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColor.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '총 절약 금액',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textPrimary,
                            ),
                          ),
                          Text(
                            '₩ ${_formatMoney(controller.moneySaved)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColor.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 스크린샷 공유 버튼만
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _shareScreenshot(context, screenshotKey),
                icon: const Icon(Icons.camera_alt, size: 20),
                label: const Text('스크린샷 공유'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColor.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
      ],
    );
  }
}
