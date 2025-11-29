import 'package:flutter/material.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_text_field.dart';
import 'package:n06/features/onboarding/presentation/widgets/validation_alert.dart';

/// 체중 및 목표 입력 폼
class WeightGoalForm extends StatefulWidget {
  final Function(double, double, int?) onDataChanged;
  final VoidCallback onNext;
  final bool isReviewMode;
  final double? initialCurrentWeight;
  final double? initialTargetWeight;
  final int? initialTargetPeriod;

  const WeightGoalForm({
    super.key,
    required this.onDataChanged,
    required this.onNext,
    this.isReviewMode = false,
    this.initialCurrentWeight,
    this.initialTargetWeight,
    this.initialTargetPeriod,
  });

  @override
  State<WeightGoalForm> createState() => _WeightGoalFormState();
}

class _WeightGoalFormState extends State<WeightGoalForm> {
  late TextEditingController _currentWeightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _targetPeriodController;

  double? _currentWeight;
  double? _targetWeight;
  int? _targetPeriod;
  double? _weeklyGoal;
  bool _hasWarning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 리뷰 모드: 초기값 설정
    _currentWeightController = TextEditingController(
      text: widget.initialCurrentWeight != null && widget.initialCurrentWeight! > 0
          ? widget.initialCurrentWeight.toString()
          : '',
    );
    _targetWeightController = TextEditingController(
      text: widget.initialTargetWeight != null && widget.initialTargetWeight! > 0
          ? widget.initialTargetWeight.toString()
          : '',
    );
    _targetPeriodController = TextEditingController(
      text: widget.initialTargetPeriod != null
          ? widget.initialTargetPeriod.toString()
          : '',
    );

    _currentWeightController.addListener(_recalculate);
    _targetWeightController.addListener(_recalculate);
    _targetPeriodController.addListener(_recalculate);

    // 리뷰 모드에서 초기값이 있으면 계산 및 부모에게 알림
    if (widget.isReviewMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _recalculate();
      });
    }
  }

  void _recalculate() {
    _currentWeight = double.tryParse(_currentWeightController.text);
    _targetWeight = double.tryParse(_targetWeightController.text);
    _targetPeriod = int.tryParse(_targetPeriodController.text);

    setState(() {
      _errorMessage = null;
      _weeklyGoal = null;
      _hasWarning = false;

      if (_currentWeight == null || _targetWeight == null) {
        return;
      }

      if (_currentWeight! < 20 || _currentWeight! > 300) {
        _errorMessage = '현재 체중은 20kg 이상 300kg 이하여야 합니다.';
        return;
      }

      if (_targetWeight! < 20 || _targetWeight! > 300) {
        _errorMessage = '목표 체중은 20kg 이상 300kg 이하여야 합니다.';
        return;
      }

      if (_targetWeight! >= _currentWeight!) {
        _errorMessage = '목표 체중은 현재 체중보다 작아야 합니다.';
        return;
      }

      if (_targetPeriod != null && _targetPeriod! > 0) {
        _weeklyGoal = (_currentWeight! - _targetWeight!) / _targetPeriod!;
        _hasWarning = _weeklyGoal! > 1.0;
      }
    });

    widget.onDataChanged(_currentWeight ?? 0, _targetWeight ?? 0, _targetPeriod);
  }

  @override
  void dispose() {
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _targetPeriodController.dispose();
    super.dispose();
  }

  bool _canProceed() {
    return _currentWeight != null && _targetWeight != null && _errorMessage == null;
  }

  Widget _buildPredictionCard() {
    if (_currentWeight == null || _currentWeight! <= 0) {
      return const SizedBox.shrink();
    }

    final predicted12Week = _currentWeight! * 0.10;
    final predicted72Week = _currentWeight! * 0.21;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Neutral-100
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '예상 변화',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '12주 후: -${predicted12Week.toStringAsFixed(1)}kg',
            style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 4),
          Text(
            '72주 후: -${predicted72Week.toStringAsFixed(1)}kg',
            style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 4),
          const Text(
            '* 임상시험 평균 기준',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Blue-50
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x4D3B82F6)), // Blue-500 with 30% opacity
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💡', style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '임상시험에서 72주 동안 평균 21% 감량을 달성했어요\n무리하지 않는 목표가 오히려 더 좋은 결과를 만들어요',
              style: TextStyle(fontSize: 14, color: Color(0xFF1E40AF)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0), // xl
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16), // md
            Text(
              widget.isReviewMode
                  ? '📊 체중 목표 확인'
                  : '📊 목표를 함께 세워볼까요?',
              style: const TextStyle(
                fontSize: 20, // xl
                fontWeight: FontWeight.w600, // Semibold
                color: Color(0xFF1E293B), // Neutral-800
              ),
            ),
            const SizedBox(height: 16), // md

            // Current Weight Input
            GabiumTextField(
              controller: _currentWeightController,
              label: '현재 체중 (kg)',
              hint: '현재 체중',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16), // md

            // Prediction Card
            _buildPredictionCard(),
            if (_currentWeight != null && _currentWeight! > 0) const SizedBox(height: 16), // md

            // Target Weight Input
            GabiumTextField(
              controller: _targetWeightController,
              label: '목표 체중 (kg)',
              hint: '목표 체중',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16), // md

            // Target Period Input
            GabiumTextField(
              controller: _targetPeriodController,
              label: '목표 기간 (주, 선택)',
              hint: '목표 기간',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24), // lg

            // Error Alert
            if (_errorMessage != null) ...[
              ValidationAlert(
                type: ValidationAlertType.error,
                message: _errorMessage!,
              ),
              const SizedBox(height: 8), // sm
            ],

            // Weekly Goal Info Alert
            if (_weeklyGoal != null && _errorMessage == null) ...[
              ValidationAlert(
                type: ValidationAlertType.info,
                message: '주간 목표: ${_weeklyGoal!.toStringAsFixed(2)}kg/주',
              ),
              const SizedBox(height: 8), // sm
            ],

            // Warning Alert
            if (_hasWarning && _errorMessage == null) ...[
              ValidationAlert(
                type: ValidationAlertType.warning,
                message: '⚠ 주간 목표가 1kg을 초과합니다. 안전한 목표를 권장합니다.',
              ),
              const SizedBox(height: 8), // sm
            ],

            // Motivation Card
            _buildMotivationCard(),
            const SizedBox(height: 16), // md

            // Next Button
            GabiumButton(
              text: '다음',
              onPressed: _canProceed() ? widget.onNext : null,
              variant: GabiumButtonVariant.primary,
              size: GabiumButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}
