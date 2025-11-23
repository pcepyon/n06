import 'package:flutter/material.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_text_field.dart';
import 'package:n06/features/onboarding/presentation/widgets/validation_alert.dart';

/// 체중 및 목표 입력 폼
class WeightGoalForm extends StatefulWidget {
  final Function(double, double, int?) onDataChanged;
  final VoidCallback onNext;

  const WeightGoalForm({super.key, required this.onDataChanged, required this.onNext});

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
    _currentWeightController = TextEditingController();
    _targetWeightController = TextEditingController();
    _targetPeriodController = TextEditingController();

    _currentWeightController.addListener(_recalculate);
    _targetWeightController.addListener(_recalculate);
    _targetPeriodController.addListener(_recalculate);
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0), // xl
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16), // md
            const Text(
              '체중 및 목표 설정',
              style: TextStyle(
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
