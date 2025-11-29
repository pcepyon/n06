import 'package:flutter/material.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_text_field.dart';
import 'package:n06/features/onboarding/presentation/widgets/validation_alert.dart';
import 'package:n06/features/tracking/domain/entities/medication_template.dart';

/// 투여 계획 입력 폼
class DosagePlanForm extends StatefulWidget {
  final Function(String, DateTime, int, double) onDataChanged;
  final VoidCallback onNext;
  final bool isReviewMode;
  final String? initialMedicationName;
  final DateTime? initialStartDate;
  final double? initialDose;

  const DosagePlanForm({
    super.key,
    required this.onDataChanged,
    required this.onNext,
    this.isReviewMode = false,
    this.initialMedicationName,
    this.initialStartDate,
    this.initialDose,
  });

  @override
  State<DosagePlanForm> createState() => _DosagePlanFormState();
}

class _DosagePlanFormState extends State<DosagePlanForm> {
  MedicationTemplate? _selectedTemplate;
  double? _selectedDose;

  DateTime? _startDate;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate ?? DateTime.now();

    // 리뷰 모드: 초기값 설정
    if (widget.isReviewMode && widget.initialMedicationName != null) {
      // 약물 이름으로 템플릿 찾기
      final template = MedicationTemplate.all.where(
        (t) => t.displayName == widget.initialMedicationName,
      ).firstOrNull;
      if (template != null) {
        _selectedTemplate = template;
        _selectedDose = widget.initialDose ?? template.recommendedStartDose;
        // 리뷰 모드에서 초기값이 있으면 부모에게 즉시 알림
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _notifyParent();
        });
      }
    }
  }

  /// 부모에게 현재 선택된 데이터를 전달
  void _notifyParent() {
    if (_selectedTemplate != null && _selectedDose != null) {
      widget.onDataChanged(
        _selectedTemplate!.displayName,
        _startDate ?? DateTime.now(),
        _selectedTemplate!.standardCycleDays,
        _selectedDose!,
      );
    }
  }

  bool _canProceed() {
    if (_selectedTemplate == null) {
      _errorMessage = '약물을 선택해주세요.';
      return false;
    }

    if (_selectedDose == null) {
      _errorMessage = '초기 용량을 선택해주세요.';
      return false;
    }

    _errorMessage = null;
    return true;
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
              widget.isReviewMode ? '투여 계획 확인' : '투여 계획 설정',
              style: AppTypography.heading2,
            ),
            const SizedBox(height: 16), // md

            // Medication Dropdown
            DropdownButtonFormField<MedicationTemplate>(
              key: ValueKey(_selectedTemplate),
              value: _selectedTemplate, // ignore: deprecated_member_use
              decoration: InputDecoration(
                labelText: '약물명',
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
              items: MedicationTemplate.all.map((template) {
                return DropdownMenuItem(
                  value: template,
                  child: Text(template.displayName),
                );
              }).toList(),
              onChanged: (template) {
                setState(() {
                  _selectedTemplate = template;
                  _selectedDose = template?.recommendedStartDose;
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
                      '시작일',
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
                text: _selectedTemplate?.standardCycleDays.toString() ?? '7',
              ),
              label: '투여 주기 (일)',
              hint: '투여 주기',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16), // md

            // Initial Dose Dropdown
            DropdownButtonFormField<double>(
              key: ValueKey(_selectedDose),
              value: _selectedDose, // ignore: deprecated_member_use
              decoration: InputDecoration(
                labelText: '초기 용량 (mg)',
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
              items: _selectedTemplate?.availableDoses.map((dose) {
                return DropdownMenuItem(
                  value: dose,
                  child: Text('${dose}mg'),
                );
              }).toList(),
              onChanged: _selectedTemplate == null
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
                message: _errorMessage!,
              ),
              const SizedBox(height: 16), // md
            ],

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
