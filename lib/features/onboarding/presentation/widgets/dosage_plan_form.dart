import 'package:flutter/material.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';

/// 투여 계획 입력 폼
class DosagePlanForm extends StatefulWidget {
  final Function(String, DateTime, int, double, List<EscalationStep>?) onDataChanged;
  final VoidCallback onNext;

  const DosagePlanForm({super.key, required this.onDataChanged, required this.onNext});

  @override
  State<DosagePlanForm> createState() => _DosagePlanFormState();
}

class _DosagePlanFormState extends State<DosagePlanForm> {
  late TextEditingController _medicationNameController;
  late TextEditingController _cycleDaysController;
  late TextEditingController _initialDoseController;

  DateTime? _startDate;
  final List<EscalationStep> _escalationSteps = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _medicationNameController = TextEditingController();
    _cycleDaysController = TextEditingController();
    _initialDoseController = TextEditingController();
    _startDate = DateTime.now();
  }

  @override
  void dispose() {
    _medicationNameController.dispose();
    _cycleDaysController.dispose();
    _initialDoseController.dispose();
    super.dispose();
  }

  bool _canProceed() {
    final medicationName = _medicationNameController.text.trim();
    final cycleDays = int.tryParse(_cycleDaysController.text);
    final initialDose = double.tryParse(_initialDoseController.text);

    if (medicationName.isEmpty) {
      _errorMessage = '약물명을 입력해주세요.';
      return false;
    }

    if (cycleDays == null || cycleDays <= 0) {
      _errorMessage = '투여 주기는 양수여야 합니다.';
      return false;
    }

    if (initialDose == null || initialDose <= 0) {
      _errorMessage = '초기 용량은 양수여야 합니다.';
      return false;
    }

    _errorMessage = null;
    return true;
  }

  void _addEscalationStep() {
    showDialog(
      context: context,
      builder: (context) => _EscalationStepDialog(
        onSave: (weeks, doseMg) {
          setState(() {
            _escalationSteps.add(EscalationStep(weeksFromStart: weeks, doseMg: doseMg));
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _removeEscalationStep(int index) {
    setState(() {
      _escalationSteps.removeAt(index);
    });
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
            TextField(
              controller: _medicationNameController,
              onChanged: (_) => setState(() {}), // 입력 변경 시 UI 업데이트
              decoration: InputDecoration(
                labelText: '약물명',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
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
            TextField(
              controller: _cycleDaysController,
              onChanged: (_) => setState(() {}), // 입력 변경 시 UI 업데이트
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '투여 주기 (일)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _initialDoseController,
              onChanged: (_) => setState(() {}), // 입력 변경 시 UI 업데이트
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '초기 용량 (mg)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),
            if (_escalationSteps.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('증량 계획', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _escalationSteps.length,
                    itemBuilder: (context, index) {
                      final step = _escalationSteps[index];
                      return ListTile(
                        title: Text('${step.weeksFromStart}주차 → ${step.doseMg}mg'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeEscalationStep(index),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ElevatedButton.icon(
              onPressed: _addEscalationStep,
              icon: const Icon(Icons.add),
              label: const Text('증량 단계 추가'),
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
                          _medicationNameController.text.trim(),
                          _startDate ?? DateTime.now(),
                          int.parse(_cycleDaysController.text),
                          double.parse(_initialDoseController.text),
                          _escalationSteps,
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

/// 증량 단계 추가 다이얼로그
class _EscalationStepDialog extends StatefulWidget {
  final Function(int, double) onSave;

  const _EscalationStepDialog({super.key, required this.onSave});

  @override
  State<_EscalationStepDialog> createState() => _EscalationStepDialogState();
}

class _EscalationStepDialogState extends State<_EscalationStepDialog> {
  late TextEditingController _weeksController;
  late TextEditingController _doseController;

  @override
  void initState() {
    super.initState();
    _weeksController = TextEditingController();
    _doseController = TextEditingController();
  }

  @override
  void dispose() {
    _weeksController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('증량 단계 추가'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _weeksController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '주차'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _doseController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: '용량 (mg)'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        TextButton(
          onPressed: () {
            final weeks = int.tryParse(_weeksController.text);
            final dose = double.tryParse(_doseController.text);
            if (weeks != null && dose != null) {
              widget.onSave(weeks, dose);
            }
          },
          child: const Text('추가'),
        ),
      ],
    );
  }
}
