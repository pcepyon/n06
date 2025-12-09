import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_text_field.dart';
import 'package:n06/features/onboarding/presentation/widgets/validation_alert.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/domain/entities/medication.dart';

/// 투여 계획 입력 폼
class DosagePlanForm extends ConsumerStatefulWidget {
  final Function(String, DateTime, int, double) onDataChanged;
  final VoidCallback onNext;

  const DosagePlanForm({
    super.key,
    required this.onDataChanged,
    required this.onNext,
  });

  @override
  ConsumerState<DosagePlanForm> createState() => _DosagePlanFormState();
}

class _DosagePlanFormState extends ConsumerState<DosagePlanForm> {
  Medication? _selectedMedication;
  double? _selectedDose;

  DateTime? _startDate;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
  }

  /// 부모에게 현재 선택된 데이터를 전달
  void _notifyParent() {
    if (_selectedMedication != null && _selectedDose != null) {
      widget.onDataChanged(
        _selectedMedication!.displayName,
        _startDate ?? DateTime.now(),
        _selectedMedication!.cycleDays,
        _selectedDose!,
      );
    }
  }

  bool _canProceed() {
    if (_selectedMedication == null) {
      _errorMessage = 'onboarding_dosagePlan_errorSelectMedication';
      return false;
    }

    if (_selectedDose == null) {
      _errorMessage = 'onboarding_dosagePlan_errorSelectDose';
      return false;
    }

    _errorMessage = null;
    return true;
  }

  String _getErrorMessage(BuildContext context, String key) {
    return switch (key) {
      'onboarding_dosagePlan_errorSelectMedication' => context.l10n.onboarding_dosagePlan_errorSelectMedication,
      'onboarding_dosagePlan_errorSelectDose' => context.l10n.onboarding_dosagePlan_errorSelectDose,
      _ => key,
    };
  }

  @override
  Widget build(BuildContext context) {
    final medicationsAsync = ref.watch(activeMedicationsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0), // xl
      child: medicationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                context.l10n.common_error_networkRetry,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              GabiumButton(
                text: context.l10n.common_button_retry,
                onPressed: () => ref.invalidate(activeMedicationsProvider),
                variant: GabiumButtonVariant.secondary,
                size: GabiumButtonSize.small,
              ),
            ],
          ),
        ),
        data: (medications) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16), // md
                Text(
                  context.l10n.onboarding_dosagePlan_title,
                  style: AppTypography.heading2,
                ),
                const SizedBox(height: 16), // md

                // Medication Dropdown
                DropdownButtonFormField<Medication>(
                  key: ValueKey(_selectedMedication?.id),
                  value: _selectedMedication,
                  decoration: InputDecoration(
                    labelText: context.l10n.onboarding_dosagePlan_medicationLabel,
                    labelStyle: AppTypography.labelMedium,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.borderDark,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  items: medications.map((medication) {
                    return DropdownMenuItem(
                      value: medication,
                      child: Text(medication.displayName),
                    );
                  }).toList(),
                  onChanged: (medication) {
                    setState(() {
                      _selectedMedication = medication;
                      _selectedDose = medication?.startDose;
                      _errorMessage = null; // 약물 선택 시 에러 메시지 초기화
                    });
                    _notifyParent();
                  },
                ),
                const SizedBox(height: 16), // md

                // Start Date Picker
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                      });
                      _notifyParent();
                    }
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.borderDark,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.surface,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.onboarding_dosagePlan_startDateLabel,
                          style: AppTypography.labelMedium,
                        ),
                        Text(
                          _startDate != null
                              ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
                              : '',
                          style: AppTypography.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16), // md

                // Cycle Field (Read-only)
                GabiumTextField(
                  controller: TextEditingController(
                    text: _selectedMedication?.cycleDays.toString() ?? '7',
                  ),
                  label: context.l10n.onboarding_dosagePlan_cycleLabel,
                  hint: context.l10n.onboarding_dosagePlan_cycleHint,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16), // md

                // Initial Dose Dropdown
                DropdownButtonFormField<double>(
                  key: ValueKey(_selectedDose),
                  value: _selectedDose,
                  decoration: InputDecoration(
                    labelText: context.l10n.onboarding_dosagePlan_initialDoseLabel,
                    labelStyle: AppTypography.labelMedium,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.borderDark,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.borderDark,
                        width: 2,
                      ),
                    ),
                  ),
                  items: _selectedMedication?.availableDoses.map((dose) {
                    return DropdownMenuItem(
                      value: dose,
                      child: Text('${dose}${_selectedMedication?.doseUnit ?? "mg"}'),
                    );
                  }).toList(),
                  onChanged: _selectedMedication == null
                      ? null
                      : (dose) {
                          setState(() {
                            _selectedDose = dose;
                          });
                          _notifyParent();
                        },
                ),
                const SizedBox(height: 24), // lg

                // Error Alert
                if (_errorMessage != null) ...[
                  ValidationAlert(
                    type: ValidationAlertType.error,
                    message: _getErrorMessage(context, _errorMessage!),
                  ),
                  const SizedBox(height: 16), // md
                ],

                // Next Button
                GabiumButton(
                  text: context.l10n.onboarding_common_nextButton,
                  onPressed: _canProceed() ? widget.onNext : null,
                  variant: GabiumButtonVariant.primary,
                  size: GabiumButtonSize.medium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
