import 'package:flutter/material.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_text_field.dart';
import 'package:n06/features/onboarding/presentation/widgets/validation_alert.dart';

/// 체중 및 목표 입력 폼
class WeightGoalForm extends StatefulWidget {
  final Function(double, double, int?) onDataChanged;
  final VoidCallback onNext;

  const WeightGoalForm({
    super.key,
    required this.onDataChanged,
    required this.onNext,
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

      // 0 이하 값 방지
      if (_currentWeight! <= 0) {
        _errorMessage = 'onboarding_weightGoal_errorEnterCurrent';
        return;
      }

      if (_targetWeight! <= 0) {
        _errorMessage = 'onboarding_weightGoal_errorEnterTarget';
        return;
      }

      if (_currentWeight! < 20 || _currentWeight! > 300) {
        _errorMessage = 'onboarding_weightGoal_errorCurrentRange';
        return;
      }

      if (_targetWeight! < 20 || _targetWeight! > 300) {
        _errorMessage = 'onboarding_weightGoal_errorTargetRange';
        return;
      }

      if (_targetWeight! >= _currentWeight!) {
        _errorMessage = 'onboarding_weightGoal_errorTargetTooHigh';
        return;
      }

      if (_targetPeriod != null && _targetPeriod! > 0) {
        _weeklyGoal = (_currentWeight! - _targetWeight!) / _targetPeriod!;
        _hasWarning = _weeklyGoal! > 1.0;
      }
    });

    // 유효한 값만 부모에게 전달 (0 이하 값 방지)
    if (_currentWeight != null && _currentWeight! > 0 &&
        _targetWeight != null && _targetWeight! > 0) {
      widget.onDataChanged(_currentWeight!, _targetWeight!, _targetPeriod);
    }
  }

  @override
  void dispose() {
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _targetPeriodController.dispose();
    super.dispose();
  }

  bool _canProceed() {
    return _currentWeight != null &&
           _currentWeight! > 0 &&
           _targetWeight != null &&
           _targetWeight! > 0 &&
           _errorMessage == null;
  }

  String _getErrorMessage(BuildContext context, String key) {
    return switch (key) {
      'onboarding_weightGoal_errorEnterCurrent' => context.l10n.onboarding_weightGoal_errorEnterCurrent,
      'onboarding_weightGoal_errorEnterTarget' => context.l10n.onboarding_weightGoal_errorEnterTarget,
      'onboarding_weightGoal_errorCurrentRange' => context.l10n.onboarding_weightGoal_errorCurrentRange,
      'onboarding_weightGoal_errorTargetRange' => context.l10n.onboarding_weightGoal_errorTargetRange,
      'onboarding_weightGoal_errorTargetTooHigh' => context.l10n.onboarding_weightGoal_errorTargetTooHigh,
      _ => key,
    };
  }

  Widget _buildPredictionCard(BuildContext context) {
    if (_currentWeight == null || _currentWeight! <= 0) {
      return const SizedBox.shrink();
    }

    final predicted12Week = _currentWeight! * 0.10;
    final predicted72Week = _currentWeight! * 0.21;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.onboarding_weightGoal_predictionTitle,
            style: AppTypography.labelMedium,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.onboarding_weightGoal_prediction12Weeks(predicted12Week.toStringAsFixed(1)),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.onboarding_weightGoal_prediction72Weeks(predicted72Week.toStringAsFixed(1)),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.onboarding_weightGoal_predictionNote,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Blue-50
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.onboarding_weightGoal_motivationMessage,
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFF1E40AF),
              ),
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
              context.l10n.onboarding_weightGoal_title,
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 16), // md

            // Current Weight Input
            GabiumTextField(
              controller: _currentWeightController,
              label: context.l10n.onboarding_weightGoal_currentWeightLabel,
              hint: context.l10n.onboarding_weightGoal_currentWeightHint,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16), // md

            // Prediction Card
            _buildPredictionCard(context),
            if (_currentWeight != null && _currentWeight! > 0) const SizedBox(height: 16), // md

            // Target Weight Input
            GabiumTextField(
              controller: _targetWeightController,
              label: context.l10n.onboarding_weightGoal_targetWeightLabel,
              hint: context.l10n.onboarding_weightGoal_targetWeightHint,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16), // md

            // Target Period Input
            GabiumTextField(
              controller: _targetPeriodController,
              label: context.l10n.onboarding_weightGoal_targetPeriodLabel,
              hint: context.l10n.onboarding_weightGoal_targetPeriodHint,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24), // lg

            // Error Alert
            if (_errorMessage != null) ...[
              ValidationAlert(
                type: ValidationAlertType.error,
                message: _getErrorMessage(context, _errorMessage!),
              ),
              const SizedBox(height: 8), // sm
            ],

            // Weekly Goal Info Alert
            if (_weeklyGoal != null && _errorMessage == null) ...[
              ValidationAlert(
                type: ValidationAlertType.info,
                message: context.l10n.onboarding_weightGoal_weeklyGoalInfo(_weeklyGoal!.toStringAsFixed(2)),
              ),
              const SizedBox(height: 8), // sm
            ],

            // Warning Alert
            if (_hasWarning && _errorMessage == null) ...[
              ValidationAlert(
                type: ValidationAlertType.warning,
                message: context.l10n.onboarding_weightGoal_warningTooFast,
              ),
              const SizedBox(height: 8), // sm
            ],

            // Motivation Card
            _buildMotivationCard(context),
            const SizedBox(height: 16), // md

            // Next Button
            GabiumButton(
              text: context.l10n.onboarding_common_nextButton,
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
