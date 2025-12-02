import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_toast.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/application/notifiers/tracking_notifier.dart';
import 'package:n06/features/tracking/presentation/widgets/date_selection_widget.dart';
import 'package:n06/features/tracking/presentation/widgets/input_validation_widget.dart';
import 'package:n06/features/tracking/presentation/widgets/severity_level_indicator.dart';
import 'package:n06/features/tracking/presentation/widgets/conditional_section.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 데일리 기록 화면 (체중 전용)
///
/// 체중을 기록하는 화면입니다.
/// 식욕 점수 및 컨디션 기록은 daily_checkin 기능으로 이동되었습니다.
///
/// Design System: Gabium v1.0 적용
class DailyTrackingScreen extends ConsumerStatefulWidget {
  const DailyTrackingScreen({super.key});

  @override
  ConsumerState<DailyTrackingScreen> createState() =>
      _DailyTrackingScreenState();
}

class _DailyTrackingScreenState extends ConsumerState<DailyTrackingScreen> {
  // 증상 목록 (상수)
  static const List<String> _symptoms = [
    '메스꺼움',
    '구토',
    '변비',
    '설사',
    '복통',
    '두통',
    '피로',
  ];

  // 컨텍스트 태그 목록
  static const List<String> _contextTags = [
    '기름진음식',
    '과식',
    '음주',
    '공복',
    '스트레스',
    '수면부족',
  ];

  // 상태 변수
  late DateTime _selectedDate;
  String _weightInput = '';

  // 증상별 개별 상태 (DEPRECATED - 증상 기능 제거됨)
  final Set<String> _selectedSymptoms = {};
  final Map<String, int> _symptomSeverities = {};
  final Map<String, bool?> _symptomPersistent = {};
  final Map<String, List<String>> _symptomTags = {};
  String _note = '';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  String? _getCurrentUserId() {
    final authState = ref.read(authProvider);
    return authState.value?.id;
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _handleWeightChanged(String value) {
    setState(() {
      _weightInput = value;
    });
  }


  void _handleSymptomToggle(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        // 증상 선택 해제
        _selectedSymptoms.remove(symptom);
        _symptomSeverities.remove(symptom);
        _symptomPersistent.remove(symptom);
        _symptomTags.remove(symptom);
      } else {
        // 증상 선택
        _selectedSymptoms.add(symptom);
        _symptomSeverities[symptom] = 5; // 기본 심각도 5
        _symptomPersistent[symptom] = null;
        _symptomTags[symptom] = [];
      }
    });
  }

  void _handleSeverityChanged(String symptom, int value) {
    setState(() {
      _symptomSeverities[symptom] = value;

      // 심각도 변경 시 옵션 초기화
      if (value >= 7) {
        // 7-10점: 태그 제거, persistent 옵션 표시
        _symptomTags[symptom] = [];
        if (!_symptomPersistent.containsKey(symptom)) {
          _symptomPersistent[symptom] = null;
        }
      } else {
        // 1-6점: persistent 제거, 태그 옵션 표시
        _symptomPersistent[symptom] = null;
        if (!_symptomTags.containsKey(symptom)) {
          _symptomTags[symptom] = [];
        }
      }
    });
  }

  void _handlePersistentChanged(String symptom, bool? value) {
    setState(() {
      _symptomPersistent[symptom] = value;
    });

    // UF-F005: 24시간 이상 지속 = 예 선택 시 증상 체크 화면으로 안내
    if (value == true) {
      context.pushNamed('emergency_check');
    }
  }

  void _handleTagToggle(String symptom, String tag) {
    setState(() {
      final tags = _symptomTags[symptom] ?? [];
      if (tags.contains(tag)) {
        tags.remove(tag);
      } else {
        tags.add(tag);
      }
      _symptomTags[symptom] = tags;
    });
  }

  Future<void> _handleSave() async {
    // 1. 체중 검증
    if (_weightInput.isEmpty) {
      if (!mounted) return;
      GabiumToast.showError(context, '체중을 입력해주세요');
      return;
    }

    final weight = double.tryParse(_weightInput);
    if (weight == null || weight < 20 || weight > 300) {
      if (!mounted) return;
      GabiumToast.showError(context, '유효한 체중을 입력해주세요 (20-300kg)');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        if (!mounted) return;
        GabiumToast.showError(context, '로그인이 필요합니다');
        setState(() => _isLoading = false);
        return;
      }

      // WeightLog 생성 및 저장
      final weightLog = WeightLog(
        id: const Uuid().v4(),
        userId: userId,
        logDate: _selectedDate,
        weightKg: weight,
        createdAt: DateTime.now(),
      );

      // 저장
      await ref.read(trackingProvider.notifier).saveWeightLog(weightLog);

      // 7. 저장 성공 시 대시보드로 이동 (Presentation Layer 책임)
      if (!mounted) return;
      context.goNamed('home');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        GabiumToast.showError(context, '저장 중 오류가 발생했습니다: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Change 1: AppBar 스타일 Design System 적용
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          '데일리 기록',
          style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.border,
            height: 1.0,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // Change 11: 전체 간격 시스템 8px 배수로 정렬
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0, // md
                vertical: 24.0, // lg
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 날짜 선택
                  DateSelectionWidget(
                    initialDate: _selectedDate,
                    onDateSelected: _handleDateSelected,
                  ),
                  const SizedBox(height: 24.0), // lg

                  // 2. 신체 기록 섹션
                  _buildBodySection(),
                  const SizedBox(height: 24.0), // lg

                  // 3. 부작용 기록 섹션 (초기 확장 상태)
                  _buildSideEffectsSection(),
                  const SizedBox(height: 24.0), // lg

                  // 4. 저장 버튼 (Change 9: 로딩 상태 시각화 강화)
                  GabiumButton(
                    text: '저장',
                    onPressed: _isLoading ? null : _handleSave,
                    size: GabiumButtonSize.large, // 52px
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 32.0), // xl
                ],
              ),
            ),
    );
  }

  Widget _buildBodySection() {
    return Container(
      // Change 3: 카드 스타일 개선
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ), // sm shadow
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Change 10: 섹션 제목 타이포그래피 계층 개선
          Text(
            '신체 기록',
            style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12.0), // sm + xs

          // 체중 입력
          InputValidationWidget(
            fieldName: '체중',
            label: '체중 (kg)',
            hint: '예: 75.5',
            onChanged: _handleWeightChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSideEffectsSection() {
    return Container(
      // Change 3: 카드 스타일 개선, 초기 확장 상태
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ), // sm shadow
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 제목
          Text(
            '부작용 기록 (선택)',
            style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12.0), // sm + xs

          // 증상 선택 칩
          Text(
            '증상 선택',
            style: AppTypography.heading3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12.0), // sm + xs

          // Change 6: FilterChip Design System 적용
          Wrap(
            spacing: 4.0, // xs
            runSpacing: 8.0, // sm
            children: _symptoms.map((symptom) {
              final isSelected = _selectedSymptoms.contains(symptom);
              return FilterChip(
                label: Text(symptom),
                selected: isSelected,
                onSelected: (_) => _handleSymptomToggle(symptom),
                backgroundColor: AppColors.surfaceVariant,
                selectedColor: AppColors.primary,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.0), // full
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // sm
                labelStyle: TextStyle(
                  fontSize: 14.0, // sm
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              );
            }).toList(),
          ),

          // Phase 2: 컨텍스트 인식 가이드 카드 (DEPRECATED - 증상 기능 제거됨)
          // Symptom guide UI removed

          const SizedBox(height: 24.0), // lg

          // 선택된 증상별 개별 설정
          if (_selectedSymptoms.isNotEmpty) ...[
            Text(
              '선택된 증상',
              style: AppTypography.heading3.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12.0), // sm + xs
            ..._selectedSymptoms.map((symptom) {
              return _buildSymptomDetail(symptom);
            }),
          ],

          // 공통 메모
          const SizedBox(height: 16.0), // md
          // Change 7: 입력 필드 높이 & 스타일 통일
          Text(
            '메모 (선택)',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8.0), // sm
          TextField(
            decoration: InputDecoration(
              hintText: '추가 메모를 입력하세요',
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: AppColors.borderDark,
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2.0,
                ),
              ),
            ),
            maxLines: 4,
            minLines: 4,
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
            onChanged: (value) => setState(() => _note = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomDetail(String symptom) {
    final severity = _symptomSeverities[symptom] ?? 5;
    final isPersistent = _symptomPersistent[symptom];
    final tags = _symptomTags[symptom] ?? [];

    return Container(
      // 증상 상세 카드
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 증상명
          Text(
            symptom,
            style: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16.0), // md

          // Change 4: 심각도 슬라이더 의미 시각화 (SeverityLevelIndicator 사용)
          Text(
            '심각도',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8.0), // sm
          SeverityLevelIndicator(
            severity: severity,
            onChanged: (value) => _handleSeverityChanged(symptom, value),
          ),
          const SizedBox(height: 12.0), // sm

          // Phase 1: 심각도 피드백 칩 (DEPRECATED - 증상 기능 제거됨)
          const SizedBox.shrink(),
          const SizedBox(height: 16.0), // md

          // Change 5: 조건부 UI 섹션 시각적 구분 강화 (ConditionalSection 사용)
          // 심각도 7-10점: 24시간 지속 여부
          if (severity >= 7) ...[
            ConditionalSection(
              isHighSeverity: true,
              child: Column(
                children: [
                  // Change 6: 라디오 버튼 Design System 적용
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text(
                            '예',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          value: true,
                          groupValue: isPersistent,
                          onChanged: (value) =>
                              _handlePersistentChanged(symptom, value),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: Text(
                            '아니오',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          value: false,
                          groupValue: isPersistent,
                          onChanged: (value) =>
                              _handlePersistentChanged(symptom, value),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // 심각도 1-6점: 컨텍스트 태그
          if (severity < 7) ...[
            ConditionalSection(
              isHighSeverity: false,
              child: Wrap(
                spacing: 4.0, // xs
                runSpacing: 8.0, // sm
                children: _contextTags.map((tag) {
                  final isSelected = tags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (_) => _handleTagToggle(symptom, tag),
                    backgroundColor: AppColors.surfaceVariant,
                    selectedColor: AppColors.primary,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    labelStyle: TextStyle(
                      fontSize: 14.0,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
