import 'package:flutter/material.dart';
import '../util/color.dart';

class TutorialOverlay extends StatelessWidget {
  final GlobalKey targetKey;
  final VoidCallback onComplete;

  const TutorialOverlay({
    super.key,
    required this.targetKey,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onComplete,
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Stack(
          children: [
            // 튜토리얼 설명
            _buildTutorialContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialContent(BuildContext context) {
    return Positioned(
      bottom: 200,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // 설명 카드
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColor.cardBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.touch_app,
                  size: 48,
                  color: AppColor.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  '금연 시작!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '버튼을 눌러서\n금연을 시작하세요!',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColor.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '알겠습니다',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



