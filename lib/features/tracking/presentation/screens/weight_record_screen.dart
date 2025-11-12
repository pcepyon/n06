import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/presentation/widgets/date_selection_widget.dart';
import 'package:n06/features/tracking/presentation/widgets/input_validation_widget.dart';
import 'package:n06/features/tracking/domain/usecases/validate_weight_create_usecase.dart';

/// F002: 체중 기록 화면
///
/// 사용자가 체중을 기록할 수 있는 화면입니다.
/// 날짜 선택, 체중 입력, 중복 확인, 저장 기능을 제공합니다.
class WeightRecordScreen extends ConsumerStatefulWidget {
  const WeightRecordScreen({super.key});

  @override
  ConsumerState<WeightRecordScreen> createState() => _WeightRecordScreenState();
}

class _WeightRecordScreenState extends ConsumerState<WeightRecordScreen> {
  late DateTime selectedDate;
  late TextEditingController _weightController;
  late ValidateWeightCreateUseCase _validateUseCase;
  bool isLoading = false;
  String? _validationWarning;

  @override
  void initState() {
    super.initState();
    // 오늘 날짜로 초기화
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    _weightController = TextEditingController();
    _validateUseCase = ValidateWeightCreateUseCase();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  Future<void> _handleSave() async {
    // 입력값 파싱
    final weight = double.tryParse(_weightController.text);
    if (weight == null) {
      _showErrorDialog('유효한 체중 값을 입력해주세요');
      return;
    }

    // UseCase를 사용한 검증
    final validationResult = _validateUseCase.execute(weight);

    if (validationResult.isFailure) {
      _showErrorDialog(validationResult.error ?? '유효하지 않은 체중 값입니다');
      return;
    }

    // 경고 메시지가 있으면 상태에 저장 (UI에 표시 가능)
    if (validationResult.warning != null) {
      setState(() {
        _validationWarning = validationResult.warning;
      });
    }

    setState(() => isLoading = true);

    try {
      final userId = _getCurrentUserId(); // 실제 구현에서는 AuthNotifier에서 가져올 것
      final notifier = ref.read(trackingNotifierProvider.notifier);

      // 중복 기록 확인
      final hasExisting = await notifier.hasWeightLogOnDate(userId, selectedDate);

      if (!mounted) return;

      if (hasExisting) {
        // 중복 확인 다이얼로그 표시
        final shouldOverwrite = await _showConfirmDialog(
          '이미 기록이 있습니다.',
          '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일의 체중 기록이 이미 존재합니다.\n덮어쓰시겠어요?',
        );

        if (!shouldOverwrite) {
          setState(() => isLoading = false);
          return;
        }

        // 기존 기록 조회 후 업데이트
        final existing = await notifier.getWeightLog(userId, selectedDate);
        if (existing != null && mounted) {
          await notifier.updateWeightLog(existing.id, weight);
        }
      } else {
        // 새로운 기록 저장
        final newLog = WeightLog(
          id: const Uuid().v4(),
          userId: userId,
          logDate: selectedDate,
          weightKg: weight,
          createdAt: DateTime.now(),
        );

        await notifier.saveWeightLog(newLog);
      }

      if (!mounted) return;

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('체중이 기록되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );

      // 홈 화면으로 이동
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        _showErrorDialog('저장 중 오류가 발생했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('확인'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // 현재 사용자 ID 조회
  String _getCurrentUserId() {
    // AuthNotifier에서 현재 사용자 ID 가져오기
    final userId = ref.read(authNotifierProvider).value?.id;
    return userId ?? 'current-user-id'; // fallback
  }

  @override
  Widget build(BuildContext context) {
    // Provider를 구독하여 화면이 활성화된 동안 유지
    ref.watch(trackingNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('체중 기록'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜 선택 섹션
              const SizedBox(height: 8),
              const Text(
                '날짜 선택',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DateSelectionWidget(
                initialDate: selectedDate,
                onDateSelected: _handleDateSelected,
              ),

              // 체중 입력 섹션
              const SizedBox(height: 24),
              const Text(
                '체중 입력',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              InputValidationWidget(
                controller: _weightController, // 외부 controller 전달
                fieldName: '체중',
                onChanged: (_) {
                  setState(() {
                    // 입력 변경 시 경고 메시지 초기화
                    _validationWarning = null;
                  });
                },
                label: '체중 (kg)',
                hint: '예: 75.5',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
              ),
              // 경고 메시지 표시
              if (_validationWarning != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _validationWarning!,
                          style: const TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 저장 버튼
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSave,
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
