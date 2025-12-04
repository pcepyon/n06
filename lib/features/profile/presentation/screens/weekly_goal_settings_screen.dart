import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/profile/application/notifiers/profile_notifier.dart';
import 'package:n06/features/profile/presentation/widgets/weekly_goal_input_widget.dart';

/// Screen for adjusting weekly recording goals with Gabium Design System styling
///
/// Allows users to set target number of weight logs and symptom logs per week (0-7).
/// Updated to use Design System tokens for colors, typography, spacing, and shadows.
class WeeklyGoalSettingsScreen extends ConsumerStatefulWidget {
  const WeeklyGoalSettingsScreen({super.key});

  @override
  ConsumerState<WeeklyGoalSettingsScreen> createState() => _WeeklyGoalSettingsScreenState();
}

class _WeeklyGoalSettingsScreenState extends ConsumerState<WeeklyGoalSettingsScreen> {
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
        builder: (dialogContext) => AlertDialog(
          title: Text(context.l10n.weeklyGoal_dialog_zeroGoal_title),
          content: Text(context.l10n.weeklyGoal_dialog_zeroGoal_message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(context.l10n.common_button_cancel)),
            TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(context.l10n.common_button_confirm)),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(profileNotifierProvider.notifier).updateWeeklyGoals(_weightGoal, _symptomGoal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.weeklyGoal_toast_success),
            backgroundColor: const Color(0xFF10B981), // Success color
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16.0),
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.weeklyGoal_toast_saveFailed(e.toString())),
            backgroundColor: const Color(0xFFEF4444), // Error color
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16.0),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.weeklyGoal_screen_title), elevation: 0),
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
            // Information box with Info color accent
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // Neutral-100
                borderRadius: BorderRadius.circular(12.0), // md
                border: Border.all(
                  color: const Color(0xFFCBD5E1), // Neutral-300
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      color: AppColors.education, // Info/Education color
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      context.l10n.weeklyGoal_info_message,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF334155), // Neutral-700
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Weight record goal section
            Text(
              context.l10n.weeklyGoal_weightRecord_title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155), // Neutral-700
                  ),
            ),
            const SizedBox(height: 8.0),
            WeeklyGoalInputWidget(
              label: context.l10n.weeklyGoal_weightRecord_label,
              initialValue: _weightGoal,
              onChanged: (value) => setState(() => _weightGoal = value),
            ),
            const SizedBox(height: 20.0),
            Text(
              context.l10n.weeklyGoal_weightRecord_display(_weightGoal),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF64748B), // Neutral-500
                  ),
            ),
            const SizedBox(height: 32.0),

            // Symptom record goal section
            Text(
              context.l10n.weeklyGoal_symptomRecord_title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155), // Neutral-700
                  ),
            ),
            const SizedBox(height: 8.0),
            WeeklyGoalInputWidget(
              label: context.l10n.weeklyGoal_symptomRecord_label,
              initialValue: _symptomGoal,
              onChanged: (value) => setState(() => _symptomGoal = value),
            ),
            const SizedBox(height: 20.0),
            Text(
              context.l10n.weeklyGoal_symptomRecord_display(_symptomGoal),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF64748B), // Neutral-500
                  ),
            ),
            const SizedBox(height: 40.0),

            // Read-only dose plan info box
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC), // Neutral-50
                borderRadius: BorderRadius.circular(12.0), // md
                border: Border.all(
                  color: const Color(0xFFE2E8F0), // Neutral-200
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 2.0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.weeklyGoal_doseGoal_title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF334155), // Neutral-700
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    context.l10n.weeklyGoal_doseGoal_message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B), // Neutral-500
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40.0),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ADE80), // Primary
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF4ADE80)
                      .withValues(alpha: 0.4), // Primary at 40% opacity
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // sm
                  ),
                  elevation: 2.0,
                  shadowColor: Colors.black.withValues(alpha: 0.06),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20.0,
                        width: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        context.l10n.common_button_save,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(context.l10n.common_error_profileLoadFailed),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(profileNotifierProvider);
              },
              child: Text(context.l10n.common_button_retry),
            ),
          ],
        ),
      ),
    );
  }
}
