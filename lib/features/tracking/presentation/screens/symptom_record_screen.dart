import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import 'package:n06/core/theme/app_colors.dart';
import 'package:n06/core/theme/app_text_styles.dart';
import 'package:n06/core/widgets/app_button.dart';
import 'package:n06/core/widgets/app_card.dart';
import 'package:n06/core/widgets/app_text_field.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
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

    // Task 3-2: 심각도 7-10 + 24시간 지속 선택 시 긴급 증상 체크 제안
    if (severity >= 7 && isPersistent24h == true) {
      final shouldCheck = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning_amber, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('긴급 증상 체크'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '심각한 증상이 24시간 이상 지속되고 있습니다.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                '긴급 증상 체크를 통해 즉시 병원 방문이 필요한지 확인하시겠습니까?',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                '※ 매우 심각한 증상이 지속되는 경우 즉시 의료 기관을 방문하세요.',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('나중에'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('확인하기'),
            ),
          ],
        ),
      );

      if (shouldCheck == true && mounted) {
        // 증상 저장 먼저
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

            // 저장 완료 대기
            await notifier.saveSymptomLog(log);
            savedLog = log;
          }

          if (!mounted) return;

          // 긴급 체크 화면으로 이동
          context.push('/emergency/check');
          return; // 아래 대처 가이드 다이얼로그 스킵
        } catch (e) {
          if (mounted) {
            _showErrorDialog('저장 중 오류가 발생했습니다: $e');
          }
        } finally {
          if (mounted) {
            setState(() => isLoading = false);
          }
        }
        return;
      }
    }

    // Task 3-1: 일반 저장 흐름
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

        // 저장 완료 대기
        await notifier.saveSymptomLog(log);
        savedLog = log;
      }

      // 저장 완료 후 mounted 체크
      if (!mounted) return;

      // 저장 완료 피드백 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('증상이 기록되었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );

      // Task 3-1: 대처 가이드 표시 (저장이 완전히 완료된 후)
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

    // Task 3-1: 대처 가이드 자동 표시
    // 모달 바텀시트로 대처 가이드 위젯 표시
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
              Text(
                '날짜 선택',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: DateSelectionWidget(
                  initialDate: selectedDate,
                  onDateSelected: _handleDateSelected,
                ),
              ),

              // 경과일 표시
              if (daysSinceEscalation != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '용량 증량 후 $daysSinceEscalation일째',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              // 증상 선택
              const SizedBox(height: 24),
              Text(
                '증상 선택',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _symptoms.map((symptom) {
                  final isSelected = selectedSymptoms.contains(symptom);
                  return FilterChip(
                    label: Text(
                      symptom,
                      style: isSelected
                          ? AppTextStyles.body2.copyWith(color: Colors.white)
                          : AppTextStyles.body2,
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.lightGray,
                    checkmarkColor: Colors.white,
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
              Text(
                '심각도 (1-10점)',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Slider(
                      value: severity.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: severity.toString(),
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.lightGray,
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
                      style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // 심각도 7-10점인 경우 24시간 지속 여부 질문
              if (severity >= 7) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '24시간 이상 지속되고 있나요?',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: '아니오',
                              onPressed: () {
                                setState(() => isPersistent24h = false);
                              },
                              type: isPersistent24h == false
                                  ? AppButtonType.secondary
                                  : AppButtonType.outline,
                              backgroundColor: isPersistent24h == false
                                  ? AppColors.lightGray
                                  : Colors.transparent,
                              textColor: isPersistent24h == false
                                  ? AppColors.black
                                  : AppColors.gray,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              text: '예',
                              onPressed: () {
                                setState(() => isPersistent24h = true);
                              },
                              type: isPersistent24h == true
                                  ? AppButtonType.primary
                                  : AppButtonType.outline,
                              backgroundColor: isPersistent24h == true
                                  ? AppColors.warning
                                  : Colors.transparent,
                              textColor: isPersistent24h == true
                                  ? Colors.white
                                  : AppColors.gray,
                              borderColor: isPersistent24h == true
                                  ? Colors.transparent
                                  : AppColors.lightGray,
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
                Text(
                  '컨텍스트 태그 (선택)',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _contextTags.map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    return ChoiceChip(
                      label: Text(
                        '#$tag',
                        style: isSelected
                            ? AppTextStyles.caption.copyWith(color: Colors.white)
                            : AppTextStyles.caption,
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.lightGray,
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
              Text(
                '메모 (선택)',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 12),
              AppTextField(
                onChanged: (value) {
                  setState(() => memo = value);
                },
                maxLines: 3,
                hintText: '추가 정보를 입력하세요',
              ),

              // 저장 버튼
              const SizedBox(height: 32),
              AppButton(
                text: '저장',
                onPressed: isLoading ? null : _handleSave,
                isLoading: isLoading,
                type: AppButtonType.primary,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
