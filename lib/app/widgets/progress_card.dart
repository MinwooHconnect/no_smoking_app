import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../util/color.dart';
import 'circular_progress_painter.dart';
import 'target_period_dialog.dart';
import 'motivational_message_dialog.dart';

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
                    '설정 기간 ${controller.targetPeriod.value}',
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
                          controller.setTargetPeriod(period);
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
                            '${controller.days + 1}일 차',
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
          Obx(
            () => controller.isQuittingStarted.value
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: Get.context!,
                          builder: (context) => MotivationalMessageDialog(
                            allCurrentMessages:
                                controller.allMessagesIncludingDisabled,
                          ),
                        ).then((result) {
                          if (result != null && result is List<String>) {
                            controller.setCustomMotivationalMessages(result);
                            Get.snackbar(
                              '저장 완료',
                              '응원 메시지가 저장되었습니다.',
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
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: ClipRect(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Center(
                            child: _AnimatedMotivationalMessage(
                              message:
                                  controller.currentMotivationalMessage.value,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(height: 24),
          ),
        ],
      ),
    );
  }
}

class _AnimatedMotivationalMessage extends StatefulWidget {
  final String message;

  const _AnimatedMotivationalMessage({required this.message});

  @override
  State<_AnimatedMotivationalMessage> createState() =>
      _AnimatedMotivationalMessageState();
}

class _AnimatedMotivationalMessageState
    extends State<_AnimatedMotivationalMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _exitAnimation; // 이전 문구: 중앙에서 왼쪽으로
  late Animation<Offset> _enterAnimation; // 새 문구: 오른쪽에서 중앙으로
  String _displayMessage = '';
  String? _previousMessage;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _displayMessage = widget.message;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 이전 문구 애니메이션: 중앙에서 왼쪽으로 사라짐
    _exitAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0), // 중앙에서 시작
      end: const Offset(-1.0, 0.0), // 왼쪽으로 사라짐
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 새 문구 애니메이션: 오른쪽에서 중앙으로 나타남
    _enterAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // 오른쪽에서 시작
      end: const Offset(0.0, 0.0), // 중앙으로 이동
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_AnimatedMotivationalMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message && !_isAnimating) {
      _changeMessage();
    }
  }

  void _changeMessage() async {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _previousMessage = _displayMessage;
    });

    // 1단계: 이전 문구를 중앙에서 왼쪽으로 사라지게
    _controller.reset();
    await _controller.forward();

    // 이전 문구 제거 및 새 문구 설정
    if (mounted) {
      setState(() {
        _previousMessage = null;
        _displayMessage = widget.message;
      });

      // 2단계: 새 문구를 오른쪽에서 중앙으로 나타나게
      _controller.reset();
      await _controller.forward();

      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        children: [
          // 이전 문구 (왼쪽으로 사라지는 중)
          if (_previousMessage != null)
            SlideTransition(
              position: _exitAnimation,
              child: Text(
                _previousMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
              ),
            ),
          // 현재 문구 (이전 문구가 없을 때만 표시)
          if (_previousMessage == null)
            SlideTransition(
              position: _isAnimating
                  ? _enterAnimation
                  : AlwaysStoppedAnimation(const Offset(0.0, 0.0)),
              child: Text(
                _displayMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
