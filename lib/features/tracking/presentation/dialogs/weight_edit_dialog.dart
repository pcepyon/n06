import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/domain/usecases/validate_weight_edit_usecase.dart';

class WeightEditDialog extends ConsumerStatefulWidget {
  final WeightLog currentLog;
  final String userId;
  final VoidCallback? onSaveSuccess;

  const WeightEditDialog({
    Key? key,
    required this.currentLog,
    required this.userId,
    this.onSaveSuccess,
  }) : super(key: key);

  @override
  ConsumerState<WeightEditDialog> createState() => _WeightEditDialogState();
}

class _WeightEditDialogState extends ConsumerState<WeightEditDialog> {
  late TextEditingController _weightController;
  late DateTime _selectedDate;
  late ValidateWeightEditUseCase _validateUseCase;
  String? _errorMessage;
  String? _warningMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.currentLog.weightKg.toString(),
    );
    _selectedDate = widget.currentLog.logDate;
    _validateUseCase = ValidateWeightEditUseCase();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _validateWeight(String value) {
    setState(() {
      _errorMessage = null;
      _warningMessage = null;
    });

    if (value.isEmpty) return;

    try {
      final weight = double.parse(value);
      final result = _validateUseCase.execute(weight);

      setState(() {
        if (result.isFailure) {
          _errorMessage = result.error;
        } else if (result.warning != null) {
          _warningMessage = result.warning;
        }
      });
    } on FormatException {
      setState(() {
        _errorMessage = '숫자를 입력해주세요';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_errorMessage != null || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? '유효한 값을 입력해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newWeight = double.parse(_weightController.text);

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(weightRecordEditNotifierProvider.notifier);
      await notifier.updateWeight(
        recordId: widget.currentLog.id,
        newWeight: newWeight,
        userId: widget.userId,
        newDate: _selectedDate,
        allowOverwrite: false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('체중 기록이 수정되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSaveSuccess?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '체중 수정',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // 날짜 선택
              Text(
                '기록 날짜',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 체중 입력
              Text(
                '체중 (kg)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: _validateWeight,
                decoration: InputDecoration(
                  hintText: '체중을 입력해주세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: _errorMessage,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              if (_warningMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    '⚠ $_warningMessage',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // 버튼들
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: (_isLoading || _errorMessage != null)
                        ? null
                        : _saveChanges,
                    child: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('저장'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
