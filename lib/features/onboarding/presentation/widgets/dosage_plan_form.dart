import 'package:flutter/material.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_text_field.dart';
import 'package:n06/features/onboarding/presentation/widgets/validation_alert.dart';
import 'package:n06/features/tracking/domain/entities/medication_template.dart';

/// 투여 계획 입력 폼
class DosagePlanForm extends StatefulWidget {
  final Function(String, DateTime, int, double) onDataChanged;
  final VoidCallback onNext;

  const DosagePlanForm({super.key, required this.onDataChanged, required this.onNext});

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
    _startDate = DateTime.now();
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
            const Text(
              '투여 계획 설정',
              style: TextStyle(
                fontSize: 20, // xl
                fontWeight: FontWeight.w600, // Semibold
                color: Color(0xFF1E293B), // Neutral-800
              ),
            ),
            const SizedBox(height: 16), // md

            // Medication Dropdown
            DropdownButtonFormField<MedicationTemplate>(
              key: ValueKey(_selectedTemplate),
              value: _selectedTemplate, // ignore: deprecated_member_use
              decoration: InputDecoration(
                labelText: '약물명',
                labelStyle: const TextStyle(
                  fontSize: 14, // sm
                  fontWeight: FontWeight.w600, // Semibold
                  color: Color(0xFF334155), // Neutral-700
                ),
                filled: true,
                fillColor: const Color(0xFFFFFFFF),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFCBD5E1), // Neutral-300
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF4ADE80), // Primary
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
                });
              },
            ),
            const SizedBox(height: 16), // md

            // Start Date Picker
            Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFCBD5E1), // Neutral-300
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFFFFFFF),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: const Text(
                  '시작일',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                subtitle: Text(
                  _startDate != null
                      ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
                      : '',
                  style: const TextStyle(fontSize: 16),
                ),
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
                  }
                },
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
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
                filled: true,
                fillColor: const Color(0xFFFFFFFF),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFCBD5E1),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF4ADE80),
                    width: 2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFCBD5E1),
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
              onPressed: _canProceed()
                  ? () {
                      widget.onDataChanged(
                        _selectedTemplate!.displayName,
                        _startDate ?? DateTime.now(),
                        _selectedTemplate!.standardCycleDays,
                        _selectedDose!,
                      );
                      widget.onNext();
                    }
                  : null,
              variant: GabiumButtonVariant.primary,
              size: GabiumButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}
