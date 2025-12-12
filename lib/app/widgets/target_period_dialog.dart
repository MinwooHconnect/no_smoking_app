import 'package:flutter/material.dart';
import '../util/color.dart';

class TargetPeriodDialog extends StatelessWidget {
  final String currentTarget;
  final Function(String) onSelect;

  const TargetPeriodDialog({
    super.key,
    required this.currentTarget,
    required this.onSelect,
  });

  static const List<String> targetOptions = [
    '1일',
    '2일',
    '3일',
    '4일',
    '5일',
    '6일',
    '1주',
    '2주',
    '3주',
    '1개월',
    '2개월',
    '3개월',
    '6개월',
    '1년',
    '2년',
    '3년',
    '4년',
    '5년',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '목표 기간 선택',
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
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: targetOptions.length,
                itemBuilder: (context, index) {
                  final option = targetOptions[index];
                  final isSelected = option == currentTarget;

                  return InkWell(
                    splashColor: AppColor.primary.withValues(alpha: 0.2),
                    highlightColor: AppColor.primary.withValues(alpha: 0.1),
                    onTap: () async {
                      // 선택 피드백을 위한 애니메이션
                      if (!isSelected) {
                        // 선택 콜백 호출
                        onSelect(option);
                        
                        // 선택 피드백을 보여주기 위해 잠시 대기
                        await Future.delayed(const Duration(milliseconds: 150));
                        
                        // 다이얼로그 닫기
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      } else {
                        // 이미 선택된 항목이면 그냥 닫기
                        Navigator.of(context).pop();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.primary.withValues(alpha: 0.15)
                            : Colors.transparent,
                        border: isSelected
                            ? Border(
                                left: BorderSide(
                                  color: AppColor.primary,
                                  width: 3,
                                ),
                              )
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColor.primary
                                  : AppColor.textPrimary,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColor.primary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: AppColor.primary,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

