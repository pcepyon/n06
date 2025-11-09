import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/application/providers.dart';

const List<String> _injectionSites = ['복부', '허벅지', '상완'];

class DoseEditDialog extends ConsumerStatefulWidget {
  final DoseRecord currentRecord;
  final String userId;
  final VoidCallback? onSaveSuccess;

  const DoseEditDialog({
    super.key,
    required this.currentRecord,
    required this.userId,
    this.onSaveSuccess,
  });

  @override
  ConsumerState<DoseEditDialog> createState() => _DoseEditDialogState();
}

class _DoseEditDialogState extends ConsumerState<DoseEditDialog> {
  late TextEditingController _doseController;
  late String? _selectedSite;
  late TextEditingController _noteController;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _doseController = TextEditingController(text: widget.currentRecord.actualDoseMg.toString());
    _selectedSite = widget.currentRecord.injectionSite;
    _noteController = TextEditingController(text: widget.currentRecord.note ?? '');
  }

  @override
  void dispose() {
    _doseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _validateDose(String value) {
    setState(() {
      _errorMessage = null;
    });

    if (value.isEmpty) return;

    try {
      final dose = double.parse(value);
      if (dose <= 0) {
        setState(() {
          _errorMessage = '투여량은 0보다 커야 합니다';
        });
      }
    } on FormatException {
      setState(() {
        _errorMessage = '숫자를 입력해주세요';
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_errorMessage != null || _doseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage ?? '유효한 값을 입력해주세요'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedSite == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('투여 부위를 선택해주세요'), backgroundColor: Colors.red));
      return;
    }

    final newDose = double.parse(_doseController.text);

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(doseRecordEditNotifierProvider.notifier);
      await notifier.updateDoseRecord(
        recordId: widget.currentRecord.id,
        newDoseMg: newDose,
        injectionSite: _selectedSite!,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        userId: widget.userId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('투여 기록이 수정되었습니다'), backgroundColor: Colors.green),
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
              const Text('투여 기록 수정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              // 투여량 입력
              Text('투여량 (mg)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _doseController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: _validateDose,
                decoration: InputDecoration(
                  hintText: '투여량을 입력해주세요',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  errorText: _errorMessage,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              // 투여 부위 선택
              Text('투여 부위', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedSite,
                isExpanded: true,
                hint: const Text('부위를 선택해주세요'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSite = newValue;
                  });
                },
                items: _injectionSites.map((String site) {
                  return DropdownMenuItem<String>(value: site, child: Text(site));
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
                    onPressed: (_isLoading || _errorMessage != null || _selectedSite == null)
                        ? null
                        : _saveChanges,
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
