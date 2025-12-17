import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../util/color.dart';
import '../controllers/home_controller.dart';

class MotivationalMessageDialog extends StatefulWidget {
  final List<String> allCurrentMessages; // 현재 사용 중인 모든 메시지 (기본 + 사용자 정의)

  const MotivationalMessageDialog({
    super.key,
    required this.allCurrentMessages,
  });

  @override
  State<MotivationalMessageDialog> createState() =>
      _MotivationalMessageDialogState();
}

class _MotivationalMessageDialogState
    extends State<MotivationalMessageDialog> {
  late List<TextEditingController> _controllers;
  late List<bool> _enabledStates;
  late HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<HomeController>();
    
    // 현재 사용 중인 모든 메시지 개수만큼 필드 생성
    final fieldCount = widget.allCurrentMessages.length;
    
    _controllers = List.generate(
      fieldCount,
      (index) => TextEditingController(
        text: index < widget.allCurrentMessages.length
            ? widget.allCurrentMessages[index]
            : '',
      ),
    );

    // 각 메시지의 활성화 상태 초기화
    _enabledStates = List.generate(
      fieldCount,
      (index) => _controller.isMessageEnabled(
        widget.allCurrentMessages[index],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '응원 메시지 설정',
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
            const SizedBox(height: 8),
            Text(
              '현재 ${widget.allCurrentMessages.length}개의 응원 메시지가 사용 중입니다',
              style: const TextStyle(
                fontSize: 14,
                color: AppColor.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(_controllers.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < _controllers.length - 1 ? 16 : 0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controllers[index],
                              enabled: _enabledStates[index],
                              decoration: InputDecoration(
                                labelText: '메시지 ${index + 1}',
                                hintText: '응원 메시지를 입력하세요',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: AppColor.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppColor.primary,
                                    width: 2,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppColor.border.withValues(alpha: 0.5),
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  color: _enabledStates[index]
                                      ? AppColor.textSecondary
                                      : AppColor.textSecondary.withValues(alpha: 0.5),
                                ),
                              ),
                              maxLength: 50,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Switch(
                            value: _enabledStates[index],
                            onChanged: (value) {
                              setState(() {
                                _enabledStates[index] = value;
                              });
                            },
                            activeColor: AppColor.primary,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: AppColor.border),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 활성화된 메시지만 저장
                      final messages = <String>[];
                      final enabledMessages = <String>[];
                      
                      for (int i = 0; i < _controllers.length; i++) {
                        final message = _controllers[i].text.trim();
                        if (message.isNotEmpty) {
                          messages.add(message);
                          if (_enabledStates[i]) {
                            enabledMessages.add(message);
                          }
                        }
                      }

                      // 사용자 정의 메시지 저장
                      _controller.setCustomMotivationalMessages(messages);

                      // 각 메시지의 활성화 상태 저장
                      for (int i = 0; i < widget.allCurrentMessages.length; i++) {
                        if (i < _controllers.length) {
                          final originalMessage = widget.allCurrentMessages[i];
                          final newMessage = _controllers[i].text.trim();
                          // 메시지가 변경되었거나, 활성화 상태가 변경된 경우
                          if (newMessage.isNotEmpty) {
                            _controller.setMessageEnabled(
                              newMessage,
                              _enabledStates[i],
                            );
                            // 원래 메시지와 다르면 원래 메시지도 비활성화 상태 업데이트
                            if (originalMessage != newMessage) {
                              _controller.setMessageEnabled(
                                originalMessage,
                                false,
                              );
                            }
                          } else {
                            _controller.setMessageEnabled(
                              originalMessage,
                              _enabledStates[i],
                            );
                          }
                        }
                      }

                      Navigator.of(context).pop(messages);
                    },
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
                      '저장',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

