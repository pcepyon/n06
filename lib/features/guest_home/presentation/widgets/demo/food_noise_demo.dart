import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// Food Noise 슬라이더 인터랙션 데모 위젯
///
/// 순수 UI 인터랙션만 제공하며, 데이터를 저장하지 않습니다.
/// StatefulWidget + setState 사용.
class FoodNoiseDemo extends StatefulWidget {
  final VoidCallback? onComplete;

  const FoodNoiseDemo({
    super.key,
    this.onComplete,
  });

  @override
  State<FoodNoiseDemo> createState() => _FoodNoiseDemoState();
}

class _FoodNoiseDemoState extends State<FoodNoiseDemo> {
  double _foodNoiseLevel = 0.5; // 0.0 ~ 1.0

  void _onSliderChanged(double value) {
    setState(() {
      _foodNoiseLevel = value;
    });
    HapticFeedback.selectionClick();

    // 완료 콜백 호출 (옵션)
    widget.onComplete?.call();
  }

  String _getFeedbackText() {
    if (_foodNoiseLevel <= 0.3) {
      return '적은 편이에요';
    } else if (_foodNoiseLevel <= 0.7) {
      return '보통이에요';
    } else {
      return '많은 편이에요 - GLP-1이 도움될 수 있어요';
    }
  }

  Color _getFeedbackColor() {
    if (_foodNoiseLevel <= 0.3) {
      return AppColors.success;
    } else if (_foodNoiseLevel <= 0.7) {
      return AppColors.info;
    } else {
      return AppColors.warning;
    }
  }

  IconData _getFeedbackIcon() {
    if (_foodNoiseLevel <= 0.3) {
      return Icons.mood;
    } else if (_foodNoiseLevel <= 0.7) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_dissatisfied;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 제목
        Text(
          'Food Noise 체험',
          style: AppTypography.heading3.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // 질문
        Text(
          '음식 생각이 얼마나 자주 나나요?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // 슬라이더 컨테이너
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              // 슬라이더
              Row(
                children: [
                  Text(
                    '적음',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _foodNoiseLevel,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      activeColor: _getFeedbackColor(),
                      inactiveColor: AppColors.border,
                      onChanged: _onSliderChanged,
                    ),
                  ),
                  Text(
                    '많음',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),

              // 현재 레벨 표시
              const SizedBox(height: 8),
              Text(
                '${(_foodNoiseLevel * 10).round()}/10',
                style: AppTypography.numericLarge.copyWith(
                  color: _getFeedbackColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 시각적 피드백 카드
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _getFeedbackColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getFeedbackColor().withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // 아이콘
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _getFeedbackIcon(),
                  key: ValueKey(_getFeedbackIcon()),
                  color: _getFeedbackColor(),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),

              // 피드백 텍스트
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _getFeedbackText(),
                    key: ValueKey(_getFeedbackText()),
                    style: AppTypography.bodyLarge.copyWith(
                      color: _getFeedbackColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 설명 텍스트
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.educationBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '💡',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Food Noise는 음식에 대한 끊임없는 생각을 의미합니다. GLP-1 약물은 이러한 생각을 줄여줄 수 있어요.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.education,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
