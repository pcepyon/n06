import 'package:flutter/material.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/value_objects/weight.dart';

/// Widget for editing profile information
class ProfileEditForm extends StatefulWidget {
  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileChanged;

  const ProfileEditForm({
    super.key,
    required this.profile,
    required this.onProfileChanged,
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
    _currentName = widget.profile.userId; // TODO: Get actual name from somewhere
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
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '이름',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _notifyProfileChanged(),
          ),
          const SizedBox(height: 16),

          // Target weight field
          TextField(
            controller: _targetWeightController,
            decoration: const InputDecoration(
              labelText: '목표 체중 (kg)',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              _calculateWeeklyGoal();
              _notifyProfileChanged();
            },
          ),
          const SizedBox(height: 16),

          // Current weight field
          TextField(
            controller: _currentWeightController,
            decoration: const InputDecoration(
              labelText: '현재 체중 (kg)',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) {
              _calculateWeeklyGoal();
              _notifyProfileChanged();
            },
          ),
          const SizedBox(height: 16),

          // Target period field
          TextField(
            controller: _targetPeriodController,
            decoration: const InputDecoration(
              labelText: '목표 기간 (주)',
              border: OutlineInputBorder(),
            ),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _showWeeklyGoalWarning ? Colors.orange : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '주간 감량 목표: ${_calculatedWeeklyGoal!.toStringAsFixed(2)}kg',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (_showWeeklyGoalWarning) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '주당 1kg 초과의 감량 목표는 위험할 수 있습니다.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
