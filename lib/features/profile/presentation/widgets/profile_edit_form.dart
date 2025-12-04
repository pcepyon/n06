import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_text_field.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';

/// Widget for editing profile information
class ProfileEditForm extends StatefulWidget {
  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileChanged;
  final VoidCallback? onSave;

  const ProfileEditForm({
    super.key,
    required this.profile,
    required this.onProfileChanged,
    this.onSave,
  });

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  late TextEditingController _nameController;
  late TextEditingController _targetWeightController;
  late TextEditingController _currentWeightController;
  late TextEditingController _targetPeriodController;

  late String _currentName;
  late double _currentTargetWeight;
  late double _currentCurrentWeight;
  late int? _currentTargetPeriod;

  double? _calculatedWeeklyGoal;
  bool _showWeeklyGoalWarning = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _currentName = widget.profile.userName ?? '';
    _currentTargetWeight = widget.profile.targetWeight.value;
    _currentCurrentWeight = widget.profile.currentWeight.value;
    _currentTargetPeriod = widget.profile.targetPeriodWeeks;

    _nameController = TextEditingController(text: _currentName);
    _targetWeightController = TextEditingController(text: _currentTargetWeight.toString());
    _currentWeightController = TextEditingController(text: _currentCurrentWeight.toString());
    _targetPeriodController = TextEditingController(
      text: _currentTargetPeriod?.toString() ?? '',
    );

    _calculateWeeklyGoal();
  }

  void _calculateWeeklyGoal() {
    final targetWeight = double.tryParse(_targetWeightController.text);
    final currentWeight = double.tryParse(_currentWeightController.text);
    final periodWeeks = int.tryParse(_targetPeriodController.text);

    if (targetWeight != null && currentWeight != null && periodWeeks != null && periodWeeks > 0) {
      final weeklyGoal = (currentWeight - targetWeight) / periodWeeks;
      setState(() {
        _calculatedWeeklyGoal = double.parse(weeklyGoal.toStringAsFixed(2));
        _showWeeklyGoalWarning = _calculatedWeeklyGoal! > 1.0;
      });
    } else {
      setState(() {
        _calculatedWeeklyGoal = null;
        _showWeeklyGoalWarning = false;
      });
    }
  }

  void _notifyProfileChanged() {
    final targetWeight = double.tryParse(_targetWeightController.text);
    final currentWeight = double.tryParse(_currentWeightController.text);
    final periodWeeks = int.tryParse(_targetPeriodController.text);

    if (targetWeight != null && currentWeight != null) {
      try {
        final profile = UserProfile(
          userId: widget.profile.userId,
          userName: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : widget.profile.userName,
          targetWeight: Weight.create(targetWeight),
          currentWeight: Weight.create(currentWeight),
          targetPeriodWeeks: periodWeeks,
          weeklyLossGoalKg: _calculatedWeeklyGoal,
          weeklyWeightRecordGoal: widget.profile.weeklyWeightRecordGoal,
          weeklySymptomRecordGoal: widget.profile.weeklySymptomRecordGoal,
        );
        widget.onProfileChanged(profile);
      } catch (e) {
        // Validation error handled in parent
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetWeightController.dispose();
    _currentWeightController.dispose();
    _targetPeriodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name field
          GabiumTextField(
            controller: _nameController,
            label: context.l10n.profile_edit_field_name,
            hint: context.l10n.profile_edit_field_nameHint,
            keyboardType: TextInputType.text,
            onChanged: (_) => _notifyProfileChanged(),
          ),
          const SizedBox(height: 16),

          // Target weight field
          GabiumTextField(
            controller: _targetWeightController,
            label: context.l10n.profile_edit_field_targetWeight,
            hint: context.l10n.profile_edit_field_targetWeightHint,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              _calculateWeeklyGoal();
              _notifyProfileChanged();
            },
          ),
          const SizedBox(height: 16),

          // Current weight field
          GabiumTextField(
            controller: _currentWeightController,
            label: context.l10n.profile_edit_field_currentWeight,
            hint: context.l10n.profile_edit_field_currentWeightHint,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              _calculateWeeklyGoal();
              _notifyProfileChanged();
            },
          ),
          const SizedBox(height: 16),

          // Target period field
          GabiumTextField(
            controller: _targetPeriodController,
            label: context.l10n.profile_edit_field_targetPeriod,
            hint: context.l10n.profile_edit_field_targetPeriodHint,
            keyboardType: TextInputType.number,
            onChanged: (_) {
              _calculateWeeklyGoal();
              _notifyProfileChanged();
            },
          ),
          const SizedBox(height: 16),

          // Weekly goal display
          if (_calculatedWeeklyGoal != null) ...[
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: _showWeeklyGoalWarning
                    ? Border(
                        left: BorderSide(
                          color: AppColors.warning,
                          width: 4,
                        ),
                      )
                    : Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                borderRadius: BorderRadius.circular(12), // md
                boxShadow: [
                  BoxShadow(
                    color: _showWeeklyGoalWarning
                        ? AppColors.warning.withValues(alpha: 0.1)
                        : AppColors.neutral900.withValues(alpha: 0.06),
                    blurRadius: _showWeeklyGoalWarning ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16), // md
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    context.l10n.profile_edit_weeklyGoal_title,
                    style: AppTypography.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  // Goal value
                  Text(
                    context.l10n.profile_edit_weeklyGoal_value(_calculatedWeeklyGoal!.toStringAsFixed(2)),
                    style: AppTypography.heading2,
                  ),
                  if (_showWeeklyGoalWarning) ...[
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB), // Warning-50
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.l10n.profile_edit_weeklyGoal_warning,
                              style: AppTypography.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 24), // lg spacing

          // Save button
          GabiumButton(
            onPressed: widget.onSave ?? () {},
            text: context.l10n.common_button_save,
            variant: GabiumButtonVariant.primary,
            size: GabiumButtonSize.medium,
          ),

          const SizedBox(height: 16), // Safe area margin
        ],
      ),
    );
  }
}
