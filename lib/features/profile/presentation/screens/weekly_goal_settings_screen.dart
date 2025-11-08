import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/profile/application/notifiers/profile_notifier.dart';
import 'package:n06/features/profile/presentation/widgets/weekly_goal_input_widget.dart';

/// Screen for adjusting weekly recording goals
///
/// Allows users to set target number of weight logs and symptom logs per week (0-7).
class WeeklyGoalSettingsScreen extends ConsumerStatefulWidget {
  const WeeklyGoalSettingsScreen({super.key});

  @override
  ConsumerState<WeeklyGoalSettingsScreen> createState() =>
      _WeeklyGoalSettingsScreenState();
}

class _WeeklyGoalSettingsScreenState
    extends ConsumerState<WeeklyGoalSettingsScreen> {
  late int _weightGoal;
  late int _symptomGoal;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

  void _initializeValues() {
    final profileState = ref.read(profileNotifierProvider);
    if (profileState.hasValue && profileState.value != null) {
      _weightGoal = profileState.value!.weeklyWeightRecordGoal;
      _symptomGoal = profileState.value!.weeklySymptomRecordGoal;
    }
  }

  Future<void> _onSave() async {
    // Show confirmation dialog if setting goal to 0
    if (_weightGoal == 0 || _symptomGoal == 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('목표 0 설정'),
          content: const Text('목표를 0으로 설정하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(profileNotifierProvider.notifier)
          .updateWeeklyGoals(_weightGoal, _symptomGoal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('주간 목표가 저장되었습니다')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('주간 기록 목표 조정'),
        elevation: 0,
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorState(error),
        data: (profile) {
          if (profile == null) {
            return _buildErrorState(Exception('Profile not found'));
          }
          return _buildForm(profile);
        },
      ),
    );
  }

  Widget _buildForm(dynamic profile) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Information section
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Text(
                '주간 목표를 설정하여 기록 달성을 추적하세요.\n투여 목표는 계획된 스케줄로부터 자동 계산됩니다.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Weight record goal
            Text(
              '주간 체중 기록 목표',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            WeeklyGoalInputWidget(
              label: '주간 체중 기록 횟수 (0~7회)',
              initialValue: _weightGoal,
              onChanged: (value) => setState(() => _weightGoal = value),
            ),
            const SizedBox(height: 20),

            Text(
              '${_weightGoal}회 / 주',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Symptom record goal
            Text(
              '주간 부작용 기록 목표',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            WeeklyGoalInputWidget(
              label: '주간 부작용 기록 횟수 (0~7회)',
              initialValue: _symptomGoal,
              onChanged: (value) => setState(() => _symptomGoal = value),
            ),
            const SizedBox(height: 20),

            Text(
              '${_symptomGoal}회 / 주',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),

            // Dose plan info (read-only)
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '투여 목표 (읽기 전용)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '투여 목표는 현재 투여 스케줄에 따라 자동으로 계산됩니다.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSave,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            const Text('프로필 정보를 불러올 수 없습니다'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(profileNotifierProvider);
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
