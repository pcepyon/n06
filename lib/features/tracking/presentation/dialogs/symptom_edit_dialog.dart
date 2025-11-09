import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/domain/usecases/validate_symptom_edit_usecase.dart';

const List<String> _symptomOptions = ['메스꺼움', '구토', '변비', '설사', '복통', '두통', '피로'];

const List<String> _contextTags = ['기름진음식', '과식', '음주', '공복', '스트레스', '수면부족'];

class SymptomEditDialog extends ConsumerStatefulWidget {
  final SymptomLog currentLog;
  final String userId;
  final VoidCallback? onSaveSuccess;

  const SymptomEditDialog({
    super.key,
    required this.currentLog,
    required this.userId,
    this.onSaveSuccess,
  });

  @override
  ConsumerState<SymptomEditDialog> createState() => _SymptomEditDialogState();
}

class _SymptomEditDialogState extends ConsumerState<SymptomEditDialog> {
  late String _selectedSymptom;
  late int _selectedSeverity;
  late List<String> _selectedTags;
  late TextEditingController _noteController;
  late ValidateSymptomEditUseCase _validateUseCase;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedSymptom = widget.currentLog.symptomName;
    _selectedSeverity = widget.currentLog.severity;
    _selectedTags = List.from(widget.currentLog.tags);
    _noteController = TextEditingController(text: widget.currentLog.note ?? '');
    _validateUseCase = ValidateSymptomEditUseCase();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      _errorMessage = null;
    });

    final result = _validateUseCase.execute(
      severity: _selectedSeverity,
      symptomName: _selectedSymptom,
    );

    if (result.isFailure) {
      setState(() {
        _errorMessage = result.error;
      });
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _saveChanges() async {
    _validateFields();

    if (_errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage ?? '유효한 값을 입력해주세요'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedLog = SymptomLog(
        id: widget.currentLog.id,
        userId: widget.currentLog.userId,
        logDate: widget.currentLog.logDate,
        symptomName: _selectedSymptom,
        severity: _selectedSeverity,
        daysSinceEscalation: widget.currentLog.daysSinceEscalation,
        isPersistent24h: widget.currentLog.isPersistent24h,
        tags: _selectedTags,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      final notifier = ref.read(symptomRecordEditNotifierProvider.notifier);
      await notifier.updateSymptom(recordId: widget.currentLog.id, updatedLog: updatedLog);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('증상 기록이 수정되었습니다'), backgroundColor: Colors.green),
        );
        widget.onSaveSuccess?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: ${e.toString()}'), backgroundColor: Colors.red),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('증상 수정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              // 증상 선택
              Text('증상', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedSymptom,
                isExpanded: true,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedSymptom = newValue;
                    });
                    _validateFields();
                  }
                },
                items: _symptomOptions.map((String symptom) {
                  return DropdownMenuItem<String>(value: symptom, child: Text(symptom));
                }).toList(),
              ),
              const SizedBox(height: 24),
              // 심각도 슬라이더
              Text('심각도: $_selectedSeverity/10', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Slider(
                value: _selectedSeverity.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (double value) {
                  setState(() {
                    _selectedSeverity = value.toInt();
                  });
                  _validateFields();
                },
              ),
              const SizedBox(height: 24),
              // 컨텍스트 태그
              Text('컨텍스트 (선택 사항)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _contextTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (_) => _toggleTag(tag),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // 메모
              Text('메모 (선택 사항)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '추가 정보를 입력해주세요',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    '❌ $_errorMessage',
                    style: TextStyle(fontSize: 14, color: Colors.red.shade800),
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
                    onPressed: (_isLoading || _errorMessage != null) ? null : _saveChanges,
                    child: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
