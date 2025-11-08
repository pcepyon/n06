import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/domain/entities/dosage_plan.dart';
import 'package:n06/features/tracking/domain/usecases/analyze_plan_change_impact_usecase.dart';

class EditDosagePlanScreen extends ConsumerWidget {
  final DosagePlan initialPlan;

  const EditDosagePlanScreen({
    super.key,
    required this.initialPlan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('투여 계획 수정'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _EditDosagePlanForm(initialPlan: initialPlan),
        ),
      ),
    );
  }
}

class _EditDosagePlanForm extends ConsumerStatefulWidget {
  final DosagePlan initialPlan;

  const _EditDosagePlanForm({
    super.key,
    required this.initialPlan,
  });

  @override
  ConsumerState<_EditDosagePlanForm> createState() => _EditDosagePlanFormState();
}

class _EditDosagePlanFormState extends ConsumerState<_EditDosagePlanForm> {
  late TextEditingController _medicationNameController;
  late TextEditingController _cycleDaysController;
  late TextEditingController _initialDoseController;
  late DateTime _selectedStartDate;

  @override
  void initState() {
    super.initState();
    _medicationNameController = TextEditingController(
      text: widget.initialPlan.medicationName,
    );
    _cycleDaysController = TextEditingController(
      text: widget.initialPlan.cycleDays.toString(),
    );
    _initialDoseController = TextEditingController(
      text: widget.initialPlan.initialDoseMg.toString(),
    );
    _selectedStartDate = widget.initialPlan.startDate;
  }

  @override
  void dispose() {
    _medicationNameController.dispose();
    _cycleDaysController.dispose();
    _initialDoseController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    try {
      // Validate inputs
      if (_medicationNameController.text.trim().isEmpty) {
        _showErrorSnackBar('약물명을 입력하세요');
        return;
      }

      final cycleDays = int.tryParse(_cycleDaysController.text);
      if (cycleDays == null || cycleDays < 1) {
        _showErrorSnackBar('투여 주기는 1일 이상이어야 합니다');
        return;
      }

      final initialDose = double.tryParse(_initialDoseController.text);
      if (initialDose == null || initialDose <= 0) {
        _showErrorSnackBar('초기 용량은 0보다 커야 합니다');
        return;
      }

      // Create updated plan
      final updatedPlan = widget.initialPlan.copyWith(
        medicationName: _medicationNameController.text.trim(),
        cycleDays: cycleDays,
        initialDoseMg: initialDose,
        startDate: _selectedStartDate,
        updatedAt: DateTime.now(),
      );

      // Get analyze impact usecase
      final analyzeImpactUseCase = ref.read(analyzePlanChangeImpactUseCaseProvider);

      // Analyze impact
      final impact = analyzeImpactUseCase.execute(
        oldPlan: widget.initialPlan,
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
        oldPlan: widget.initialPlan,
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
        title: const Text('투여 계획 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('투여 계획 변경 시 이후 스케줄이 재계산됩니다.'),
            const SizedBox(height: 16),
            if (impact.affectedScheduleCount > 0)
              Text('영향받는 스케줄: ${impact.affectedScheduleCount}개'),
            if (impact.changedFields.isNotEmpty)
              Text('변경되는 항목: ${impact.changedFields.join(', ')}'),
            if (impact.warningMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    impact.warningMessage!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('확인'),
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
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Medication Name
        TextField(
          controller: _medicationNameController,
          decoration: InputDecoration(
            labelText: '약물명',
            border: OutlineInputBorder(),
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
        const SizedBox(height: 16),

        // Cycle Days
        TextField(
          controller: _cycleDaysController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '투여 주기 (일)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Initial Dose
        TextField(
          controller: _initialDoseController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: '초기 용량 (mg)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 32),

        // Save Button
        ElevatedButton(
          onPressed: _handleSave,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              '저장',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
