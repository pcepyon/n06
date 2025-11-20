import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('투여 계획 설정', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            DropdownButtonFormField<MedicationTemplate>(
              key: ValueKey(_selectedTemplate),
              value: _selectedTemplate, // ignore: deprecated_member_use
              decoration: InputDecoration(
                labelText: '약물명',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                  // Auto-fill with recommended start dose
                  _selectedDose = template?.recommendedStartDose;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('시작일'),
              subtitle: Text(_startDate?.toString() ?? ''),
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
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _selectedTemplate?.standardCycleDays.toString() ?? '7',
              enabled: false,
              decoration: InputDecoration(
                labelText: '투여 주기 (일)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<double>(
              key: ValueKey(_selectedDose),
              value: _selectedDose, // ignore: deprecated_member_use
              decoration: InputDecoration(
                labelText: '초기 용량 (mg)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700)),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canProceed()
                    ? () {
                        // 데이터를 부모 위젯에 전달
                        widget.onDataChanged(
                          _selectedTemplate!.displayName,
                          _startDate ?? DateTime.now(),
                          _selectedTemplate!.standardCycleDays,
                          _selectedDose!,
                        );
                        widget.onNext();
                      }
                    : null,
                child: const Text('다음'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
