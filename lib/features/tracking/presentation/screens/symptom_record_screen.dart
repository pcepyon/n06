import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/presentation/widgets/date_selection_widget.dart';
import 'package:n06/features/tracking/presentation/widgets/coping_guide_widget.dart';

/// F002: 증상 기록 화면
///
/// 사용자가 부작용 증상을 기록할 수 있는 화면입니다.
/// 증상 선택, 심각도 선택, 태그 선택, 경과일 표시, 대처 가이드 연동 기능을 제공합니다.
class SymptomRecordScreen extends ConsumerStatefulWidget {
  const SymptomRecordScreen({super.key});

  @override
  ConsumerState<SymptomRecordScreen> createState() =>
      _SymptomRecordScreenState();
}

class _SymptomRecordScreenState extends ConsumerState<SymptomRecordScreen> {
  static const List<String> _symptoms = [
    '메스꺼움',
    '구토',
    '변비',
    '설사',
    '복통',
    '두통',
    '피로',
  ];

  static const List<String> _contextTags = [
    '기름진음식',
    '과식',
    '음주',
    '공복',
    '스트레스',
    '수면부족',
  ];

  late DateTime selectedDate;
  final Set<String> selectedSymptoms = {};
  int severity = 5;
  bool? isPersistent24h;
  final Set<String> selectedTags = {};
  String memo = '';
  int? daysSinceEscalation;
  bool isLoading = false;
  SymptomLog? savedLog;

  @override
  void initState() {
    super.initState();
    // 오늘 날짜로 초기화
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    _loadEscalationDate();
  }

  Future<void> _loadEscalationDate() async {
    final userId = _getCurrentUserId();
    final notifier = ref.read(trackingNotifierProvider.notifier);
    final escalationDate = await notifier.getLatestDoseEscalationDate(userId);

    if (escalationDate != null && mounted) {
      final days = selectedDate.difference(escalationDate).inDays;
      setState(() {
        daysSinceEscalation = days;
      });
    }
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    _loadEscalationDate();
  }

  Future<void> _handleSave() async {
    // 입력값 검증
    if (selectedSymptoms.isEmpty) {
      _showErrorDialog('증상을 선택해주세요');
      return;
    }

    // 심각도 7-10점인 경우 24시간 지속 여부 확인 필수
    if (severity >= 7 && isPersistent24h == null) {
      _showErrorDialog('24시간 이상 지속 여부를 선택해주세요');
      return;
    }

    setState(() => isLoading = true);

    try {
      final userId = _getCurrentUserId();
      final notifier = ref.read(trackingNotifierProvider.notifier);

      // 각 증상별로 기록 저장
      for (final symptom in selectedSymptoms) {
        final log = SymptomLog(
          id: const Uuid().v4(),
          userId: userId,
          logDate: selectedDate,
          symptomName: symptom,
          severity: severity,
          daysSinceEscalation: daysSinceEscalation,
          isPersistent24h: severity >= 7 ? isPersistent24h : null,
          note: memo.isNotEmpty ? memo : null,
          tags: selectedTags.toList(),
          createdAt: DateTime.now(),
        );

        await notifier.saveSymptomLog(log);
        savedLog = log;
      }

      if (!mounted) return;

      // 대처 가이드 표시
      await _showCopingGuide();
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

  Future<void> _showCopingGuide() async {
    if (savedLog == null) return;

    if (!mounted) return;

    // 대처 가이드 위젯 표시
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: CopingGuideWidget(
            symptomName: savedLog!.symptomName,
            severity: savedLog!.severity,
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );

    // 심각도 7-10점이고 24시간 지속인 경우 증상 체크 화면 안내
    if (severity >= 7 && isPersistent24h == true) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _showEmergencyCheckPrompt();
      }
    }
  }

  void _showEmergencyCheckPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('증상 체크'),
        content: const Text(
          '심각한 증상이 지속되고 있습니다.\n증상 체크 화면에서 더 자세히 확인하시겠어요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('나중에'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // F005 증상 체크 화면으로 이동
              context.push('/emergency/check');
            },
            child: const Text('이동'),
          ),
        ],
      ),
    );
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

  String _getCurrentUserId() {
    // TODO: AuthNotifier에서 현재 사용자 ID 가져오기
    return 'current-user-id';
  }

  @override
  Widget build(BuildContext context) {
    // Provider를 구독하여 화면이 활성화된 동안 유지
    ref.watch(trackingNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('증상 기록'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날짜 선택
              const Text(
                '날짜 선택',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DateSelectionWidget(
                initialDate: selectedDate,
                onDateSelected: _handleDateSelected,
              ),

              // 경과일 표시
              if (daysSinceEscalation != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '용량 증량 후 $daysSinceEscalation일째',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              // 증상 선택
              const SizedBox(height: 24),
              const Text(
                '증상 선택',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _symptoms.map((symptom) {
                  final isSelected = selectedSymptoms.contains(symptom);
                  return FilterChip(
                    label: Text(symptom),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedSymptoms.add(symptom);
                        } else {
                          selectedSymptoms.remove(symptom);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              // 심각도 선택
              const SizedBox(height: 24),
              const Text(
                '심각도 (1-10점)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  Slider(
                    value: severity.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: severity.toString(),
                    onChanged: (value) {
                      setState(() {
                        severity = value.toInt();
                        // 심각도가 6 이하로 낮아지면 isPersistent24h 리셋
                        if (severity < 7) {
                          isPersistent24h = null;
                        }
                      });
                    },
                  ),
                  Text(
                    '현재: $severity점',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

              // 심각도 7-10점인 경우 24시간 지속 여부 질문
              if (severity >= 7) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '24시간 이상 지속되고 있나요?',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() => isPersistent24h = false);
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isPersistent24h == false
                                    ? Colors.grey.shade200
                                    : Colors.transparent,
                              ),
                              child: const Text('아니오'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => isPersistent24h = true);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isPersistent24h == true
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                              child: const Text(
                                '예',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // 컨텍스트 태그 선택 (심각도 1-6점일 때만)
              if (severity < 7) ...[
                const SizedBox(height: 24),
                const Text(
                  '컨텍스트 태그 (선택)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _contextTags.map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    return ChoiceChip(
                      label: Text('#$tag'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedTags.add(tag);
                          } else {
                            selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],

              // 메모 입력
              const SizedBox(height: 24),
              const Text(
                '메모 (선택)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) {
                  setState(() => memo = value);
                },
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '추가 정보를 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),

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

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
