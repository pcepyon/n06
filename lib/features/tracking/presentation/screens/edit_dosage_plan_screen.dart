import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/theme/app_colors.dart';
import 'package:n06/core/theme/app_text_styles.dart';
import 'package:n06/core/widgets/app_button.dart';
import 'package:n06/core/widgets/app_card.dart';
import 'package:n06/features/tracking/application/notifiers/medication_notifier.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/entities/medication_template.dart';
import 'package:n06/features/tracking/domain/usecases/analyze_plan_change_impact_usecase.dart';

class EditDosagePlanScreen extends ConsumerWidget {
  const EditDosagePlanScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationState = ref.watch(medicationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('투여 계획 수정'),
      ),
      body: SafeArea(
        child: medicationState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('오류가 발생했습니다: $error', style: AppTextStyles.body1.copyWith(color: AppColors.error)),
                const SizedBox(height: 16),
                AppButton(
                  text: '다시 시도',
                  onPressed: () {
                    ref.invalidate(medicationNotifierProvider);
                  },
                  type: AppButtonType.secondary,
                  isFullWidth: false,
                ),
              ],
            ),
          ),
          data: (state) {
            final plan = state.activePlan;
            if (plan == null) {
              return const Center(
                child: Text('활성 투여 계획이 없습니다.', style: AppTextStyles.body1),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _EditDosagePlanForm(initialPlan: plan),
            );
          },
        ),
      ),
    );
  }
}

class _EditDosagePlanForm extends ConsumerStatefulWidget {
  final DosagePlan initialPlan;

  const _EditDosagePlanForm({
    // ignore: unused_element_parameter
    super.key,
    required this.initialPlan,
  });

  @override
  ConsumerState<_EditDosagePlanForm> createState() => _EditDosagePlanFormState();
}

class _EditDosagePlanFormState extends ConsumerState<_EditDosagePlanForm> {
  MedicationTemplate? _selectedTemplate;
  double? _selectedDose;
  late DateTime _selectedStartDate;

  @override
  void initState() {
    super.initState();
    final plan = widget.initialPlan;

    // Find matching template from existing medication name
    _selectedTemplate = MedicationTemplate.findByName(plan.medicationName);
    _selectedDose = plan.initialDoseMg;
    _selectedStartDate = plan.startDate;
  }

  Future<void> _handleSave() async {
    try {
      // Validate inputs
      if (_selectedTemplate == null) {
        _showErrorSnackBar('약물을 선택하세요');
        return;
      }

      if (_selectedDose == null) {
        _showErrorSnackBar('용량을 선택하세요');
        return;
      }

      final plan = widget.initialPlan;

      // Create updated plan
      final updatedPlan = plan.copyWith(
        medicationName: _selectedTemplate!.displayName,
        cycleDays: _selectedTemplate!.standardCycleDays,
        initialDoseMg: _selectedDose!,
        startDate: _selectedStartDate,
        updatedAt: DateTime.now(),
      );

      // Get analyze impact usecase
      final analyzeImpactUseCase = ref.read(analyzePlanChangeImpactUseCaseProvider);

      // Analyze impact
      final impact = analyzeImpactUseCase.execute(
        oldPlan: plan,
        newPlan: updatedPlan,
        fromDate: DateTime.now(),
      );

      // Show confirmation dialog if there are changes
      if (impact.hasChanges) {
        final confirmed = await _showImpactConfirmationDialog(context, impact);
        if (!confirmed) return;
      }

      // Update using usecase
      final updateUseCase = ref.read(updateDosagePlanUseCaseProvider);
      final result = await updateUseCase.execute(
        oldPlan: plan,
        newPlan: updatedPlan,
      );

      if (result.isSuccess) {
        _showSuccessSnackBar('투여 계획이 수정되었습니다');
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        _showErrorSnackBar(result.errorMessage ?? '업데이트 실패');
      }
    } catch (e) {
      _showErrorSnackBar('오류 발생: $e');
    }
  }

  Future<bool> _showImpactConfirmationDialog(
    BuildContext context,
    PlanChangeImpact impact,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('투여 계획 변경', style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('투여 계획 변경 시 이후 스케줄이 재계산됩니다.', style: AppTextStyles.body1),
            const SizedBox(height: 16),
            if (impact.affectedScheduleCount > 0)
              Text('영향받는 스케줄: ${impact.affectedScheduleCount}개', style: AppTextStyles.body2),
            if (impact.changedFields.isNotEmpty)
              Text('변경되는 항목: ${impact.changedFields.join(', ')}', style: AppTextStyles.body2),
            if (impact.warningMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    impact.warningMessage!,
                    style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          AppButton(
            text: '취소',
            onPressed: () => Navigator.pop(context, false),
            type: AppButtonType.ghost,
            isFullWidth: false,
          ),
          AppButton(
            text: '확인',
            onPressed: () => Navigator.pop(context, true),
            type: AppButtonType.primary,
            isFullWidth: false,
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.body2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Medication Name - Dropdown
        DropdownButtonFormField<MedicationTemplate>(
          decoration: const InputDecoration(
            labelText: '약물명',
            border: OutlineInputBorder(),
          ),
          initialValue: _selectedTemplate,
          items: MedicationTemplate.all.map((template) {
            return DropdownMenuItem<MedicationTemplate>(
              value: template,
              child: Text(template.displayName),
            );
          }).toList(),
          onChanged: (newTemplate) {
            setState(() {
              _selectedTemplate = newTemplate;
              // Reset dose when medication changes
              _selectedDose = null;
            });
          },
        ),
        const SizedBox(height: 16),

        // Initial Dose - Dropdown
        DropdownButtonFormField<double>(
          decoration: const InputDecoration(
            labelText: '초기 용량 (mg)',
            border: OutlineInputBorder(),
          ),
          initialValue: _selectedDose,
          items: _selectedTemplate?.availableDoses.map((dose) {
            return DropdownMenuItem<double>(
              value: dose,
              child: Text('$dose mg'),
            );
          }).toList(),
          onChanged: _selectedTemplate == null
              ? null
              : (newDose) {
                  setState(() {
                    _selectedDose = newDose;
                  });
                },
        ),
        const SizedBox(height: 16),

        // Cycle Days - Read-only display
        InputDecorator(
          decoration: const InputDecoration(
            labelText: '투여 주기',
            border: OutlineInputBorder(),
          ),
          child: Text(
            _selectedTemplate != null
                ? '${_selectedTemplate!.standardCycleDays}일 (매주)'
                : '-',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),

        // Start Date
        ListTile(
          title: const Text('시작일'),
          subtitle: Text(
            '${_selectedStartDate.year}-${_selectedStartDate.month.toString().padLeft(2, '0')}-${_selectedStartDate.day.toString().padLeft(2, '0')}',
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedStartDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() => _selectedStartDate = picked);
            }
          },
        ),
        const SizedBox(height: 32),

        // Save Button
        AppButton(
          text: '저장',
          onPressed: _handleSave,
          type: AppButtonType.primary,
        ),
      ],
    );
  }
}
