import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_toast.dart';
import 'package:n06/features/tracking/application/notifiers/medication_notifier.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/entities/medication_template.dart';
import 'package:n06/features/tracking/domain/usecases/analyze_plan_change_impact_usecase.dart';
import 'package:n06/features/tracking/presentation/widgets/date_picker_field.dart';
import 'package:n06/core/presentation/widgets/impact_analysis_dialog.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

class EditDosagePlanScreen extends ConsumerWidget {
  final bool isRestart;

  const EditDosagePlanScreen({
    super.key,
    this.isRestart = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationState = ref.watch(medicationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isRestart ? '투여 계획 재설정' : '투여 계획 수정'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: medicationState.when(
          loading: () => Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  '오류가 발생했습니다',
                  style: AppTypography.heading1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GabiumButton(
                  text: '다시 시도',
                  onPressed: () {
                    ref.invalidate(medicationNotifierProvider);
                  },
                  variant: GabiumButtonVariant.primary,
                  size: GabiumButtonSize.medium,
                ),
              ],
            ),
          ),
          data: (state) {
            final plan = state.activePlan;
            if (plan == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: AppColors.info,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '활성 투여 계획이 없습니다',
                      style: AppTypography.heading1.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _EditDosagePlanForm(
                initialPlan: plan,
                isRestart: isRestart,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EditDosagePlanForm extends ConsumerStatefulWidget {
  final DosagePlan initialPlan;
  final bool isRestart;

  const _EditDosagePlanForm({
    // ignore: unused_element_parameter
    super.key,
    required this.initialPlan,
    this.isRestart = false,
  });

  @override
  ConsumerState<_EditDosagePlanForm> createState() => _EditDosagePlanFormState();
}

class _EditDosagePlanFormState extends ConsumerState<_EditDosagePlanForm> {
  MedicationTemplate? _selectedTemplate;
  double? _selectedDose;
  late DateTime _selectedStartDate;
  bool _isSaving = false;

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
    setState(() => _isSaving = true);
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
        if (!confirmed) {
          if (mounted) {
            setState(() => _isSaving = false);
          }
          return;
        }
      }

      // Update using usecase
      final updateUseCase = ref.read(updateDosagePlanUseCaseProvider);
      final result = await updateUseCase.execute(
        oldPlan: plan,
        newPlan: updatedPlan,
        isRestart: widget.isRestart,
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
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<bool> _showImpactConfirmationDialog(
    BuildContext context,
    PlanChangeImpact impact,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x800F172A), // Neutral-900 at 50%
      builder: (context) => ImpactAnalysisDialog(
        impact: impact,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );

    return confirmed ?? false;
  }

  void _showErrorSnackBar(String message) {
    GabiumToast.showError(context, message);
  }

  void _showSuccessSnackBar(String message) {
    GabiumToast.showSuccess(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ============== 섹션 제목 ==============
        Text(
          '투여 계획 수정',
          style: AppTypography.heading1.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24), // lg spacing

        // ============== 약물명 드롭다운 ==============
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '약물명',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedTemplate == null
                    ? AppColors.borderDark
                    : AppColors.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.surface,
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: AppColors.surface,
                ),
                child: DropdownButton<MedicationTemplate>(
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  value: _selectedTemplate,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '약물을 선택하세요',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ),
                  items: MedicationTemplate.all.map((template) {
                    return DropdownMenuItem<MedicationTemplate>(
                      value: template,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          template.displayName,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newTemplate) {
                    setState(() {
                      _selectedTemplate = newTemplate;
                      _selectedDose = null;
                    });
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            if (_selectedTemplate == null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '약물을 선택하면 용량을 선택할 수 있습니다',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textDisabled,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16), // md spacing

        // ============== 초기 용량 드롭다운 ==============
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '초기 용량 (mg)',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedDose == null
                    ? AppColors.borderDark
                    : AppColors.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
                color: _selectedTemplate == null
                  ? AppColors.background
                  : AppColors.surface,
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: AppColors.surface,
                ),
                child: DropdownButton<double>(
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  value: _selectedDose,
                  disabledHint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _selectedTemplate == null
                        ? '먼저 약물을 선택하세요'
                        : '용량을 선택하세요',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ),
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '용량을 선택하세요',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ),
                  items: _selectedTemplate?.availableDoses.map((dose) {
                    return DropdownMenuItem<double>(
                      value: dose,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$dose mg',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList() ?? [],
                  onChanged: _selectedTemplate == null
                    ? null
                    : (newDose) {
                      setState(() => _selectedDose = newDose);
                    },
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16), // md spacing

        // ============== 투여 주기 (읽기 전용) ==============
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '투여 주기',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.background,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _selectedTemplate != null
                    ? '${_selectedTemplate!.standardCycleDays}일 (매주)'
                    : '-',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '약물에 따라 자동으로 설정됩니다',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16), // md spacing

        // ============== 시작일 선택 ==============
        DatePickerField(
          label: '시작일',
          value: _selectedStartDate,
          onChanged: (newDate) {
            setState(() => _selectedStartDate = newDate);
          },
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        ),
        const SizedBox(height: 32), // xl spacing

        // ============== 버튼 그룹 ==============
        Row(
          children: [
            // 취소 버튼
            Expanded(
              child: GabiumButton(
                text: '취소',
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                variant: GabiumButtonVariant.secondary,
                size: GabiumButtonSize.medium,
              ),
            ),
            const SizedBox(width: 12), // md spacing
            // 저장 버튼
            Expanded(
              child: GabiumButton(
                text: '저장',
                onPressed: _isSaving ? null : _handleSave,
                isLoading: _isSaving,
                variant: GabiumButtonVariant.primary,
                size: GabiumButtonSize.medium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
