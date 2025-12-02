import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/daily_checkin/presentation/constants/checkin_strings.dart';

/// 체중 입력 섹션 위젯
///
/// Features:
/// - 체중 입력 필드 (소수점 1자리)
/// - 이전 체중 표시
/// - "건너뛰기" 버튼 (덜 강조)
class WeightInputSection extends StatefulWidget {
  final double? previousWeight;
  final Function(double) onWeightSubmit;
  final VoidCallback onSkip;

  const WeightInputSection({
    super.key,
    this.previousWeight,
    required this.onWeightSubmit,
    required this.onSkip,
  });

  @override
  State<WeightInputSection> createState() => _WeightInputSectionState();
}

class _WeightInputSectionState extends State<WeightInputSection> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorText = '체중을 입력해주세요';
      });
      return;
    }

    final weight = double.tryParse(text);
    if (weight == null) {
      setState(() {
        _errorText = '올바른 숫자를 입력해주세요';
      });
      return;
    }

    if (weight < 30.0 || weight > 300.0) {
      setState(() {
        _errorText = '30.0 ~ 300.0 범위로 입력해주세요';
      });
      return;
    }

    setState(() {
      _errorText = null;
    });
    widget.onWeightSubmit(weight);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          // 아이콘
          const Center(
            child: Text(
              '📊',
              style: TextStyle(fontSize: 64),
            ),
          ),
          const SizedBox(height: 24),
          // 제목
          Text(
            WeightInputStrings.title,
            textAlign: TextAlign.center,
            style: AppTypography.heading2.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 32),
          // 입력 필드
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _errorText != null
                    ? AppColors.error
                    : AppColors.neutral200,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // 입력
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,1}'),
                          ),
                        ],
                        textAlign: TextAlign.center,
                        style: AppTypography.heading1.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral900,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.0',
                          hintStyle: TextStyle(
                            color: AppColors.neutral300,
                          ),
                        ),
                        onSubmitted: (_) => _handleSubmit(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      WeightInputStrings.unit,
                      style: AppTypography.heading2.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
                // 이전 체중
                if (widget.previousWeight != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    '${WeightInputStrings.previousLabel}: ${widget.previousWeight!.toStringAsFixed(1)}${WeightInputStrings.unit}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 에러 메시지
          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorText!,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
          const SizedBox(height: 24),
          // 다음 버튼
          FilledButton(
            onPressed: _handleSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              WeightInputStrings.nextButton,
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 건너뛰기
          TextButton(
            onPressed: widget.onSkip,
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
            child: Column(
              children: [
                Text(
                  WeightInputStrings.skipButton,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  WeightInputStrings.skipHint,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
