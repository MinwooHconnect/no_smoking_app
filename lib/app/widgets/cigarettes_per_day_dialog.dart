import 'package:flutter/material.dart';
import '../util/color.dart';

class CigarettesPerDayDialog extends StatefulWidget {
  final int currentValue;

  const CigarettesPerDayDialog({
    super.key,
    required this.currentValue,
  });

  @override
  State<CigarettesPerDayDialog> createState() => _CigarettesPerDayDialogState();
}

class _CigarettesPerDayDialogState extends State<CigarettesPerDayDialog> {
  late TextEditingController _controller;
  int? _selectedValue;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue.toString());
    _selectedValue = widget.currentValue;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPresetSelected(int value) {
    setState(() {
      _selectedValue = value;
      _controller.text = value.toString();
    });
  }

  void _onCustomValueChanged(String value) {
    final intValue = int.tryParse(value);
    if (intValue != null && intValue > 0) {
      setState(() {
        _selectedValue = intValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final presetValues = [5, 10, 15, 20, 25, 30, 40, 50];

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
                  '하루 담배 개비 수 설정',
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
            const SizedBox(height: 20),
            const Text(
              '하루에 피웠던 담배 개비 수를 선택하세요',
              style: TextStyle(
                fontSize: 14,
                color: AppColor.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // 프리셋 버튼들
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presetValues.map((value) {
                final isSelected = _selectedValue == value;
                return InkWell(
                  onTap: () => _onPresetSelected(value),
                  splashColor: AppColor.primary.withValues(alpha: 0.2),
                  highlightColor: AppColor.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColor.primary
                          : AppColor.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColor.primary
                            : AppColor.border,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$value개비',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : AppColor.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // 직접 입력 필드
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '직접 입력',
                hintText: '개비 수를 입력하세요',
                suffixText: '개비',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColor.primary, width: 2),
                ),
              ),
              onChanged: _onCustomValueChanged,
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
                    onPressed: _selectedValue != null
                        ? () => Navigator.of(context).pop(_selectedValue)
                        : null,
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
          ],
        ),
      ),
    );
  }
}

