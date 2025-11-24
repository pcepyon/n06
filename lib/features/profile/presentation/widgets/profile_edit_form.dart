import 'package:flutter/material.dart';
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
            label: '이름',
            hint: '예: 김철수',
            keyboardType: TextInputType.text,
            onChanged: (_) => _notifyProfileChanged(),
          ),
          const SizedBox(height: 16),

          // Target weight field
          GabiumTextField(
            controller: _targetWeightController,
            label: '목표 체중 (kg)',
            hint: '예: 75.5',
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
            label: '현재 체중 (kg)',
            hint: '예: 85.0',
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
            label: '목표 기간 (주)',
            hint: '예: 12',
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
                color: Colors.white,
                border: _showWeeklyGoalWarning
                    ? const Border(
                        left: BorderSide(
                          color: Color(0xFFF59E0B), // Warning
                          width: 4,
                        ),
                      )
                    : Border.all(
                        color: const Color(0xFFE2E8F0), // Neutral-200
                        width: 1,
                      ),
                borderRadius: BorderRadius.circular(12), // md
                boxShadow: [
                  BoxShadow(
                    color: _showWeeklyGoalWarning
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                        : const Color(0xFF0F172A).withValues(alpha: 0.06),
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
                  const Text(
                    '주간 감량 목표',
                    style: TextStyle(
                      color: Color(0xFF334155), // Neutral-700
                      fontSize: 14,
                      fontWeight: FontWeight.w600, // Semibold
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Goal value
                  Text(
                    '${_calculatedWeeklyGoal!.toStringAsFixed(2)}kg',
                    style: const TextStyle(
                      color: Color(0xFF1E293B), // Neutral-800
                      fontSize: 20,
                      fontWeight: FontWeight.w700, // Bold
                      fontFamily: 'Pretendard',
                    ),
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
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFF59E0B), // Warning
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '주당 1kg 초과의 감량 목표는 위험할 수 있습니다.',
                              style: const TextStyle(
                                color: Color(0xFF92400E), // Dark Warning
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Pretendard',
                              ),
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
            text: '저장',
            variant: GabiumButtonVariant.primary,
            size: GabiumButtonSize.medium,
          ),

          const SizedBox(height: 16), // Safe area margin
        ],
      ),
    );
  }
}
