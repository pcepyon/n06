import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_toast.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/application/notifiers/tracking_notifier.dart';
import 'package:n06/features/tracking/presentation/widgets/date_selection_widget.dart';
import 'package:n06/features/tracking/presentation/widgets/input_validation_widget.dart';
import 'package:n06/features/tracking/presentation/widgets/appeal_score_chip.dart';
import 'package:n06/features/tracking/presentation/widgets/severity_level_indicator.dart';
import 'package:n06/features/tracking/presentation/widgets/conditional_section.dart';

/// 통합 데일리 기록 화면 (UI Renewed)
///
/// 하나의 화면에서 체중, 식욕 조절, 부작용 증상을 모두 기록할 수 있습니다.
/// - 체중 기록
/// - 식욕 조절 점수 (필수)
/// - 부작용 기록 (선택, 증상별 개별 심각도)
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
  int? _appetiteScore;

  // 증상별 개별 상태
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

  void _handleAppetiteScoreSelected(int score) {
    setState(() {
      _appetiteScore = score;
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

    // 2. 식욕 점수 검증 (필수)
    if (_appetiteScore == null) {
      if (!mounted) return;
      GabiumToast.showError(context, '식욕 조절을 선택해주세요');
      return;
    }

    // 3. 증상별 검증 (심각도 7-10점인 경우 24시간 지속 여부 필수)
    for (final symptom in _selectedSymptoms) {
      final severity = _symptomSeverities[symptom] ?? 5;
      if (severity >= 7 && _symptomPersistent[symptom] == null) {
        if (!mounted) return;
        GabiumToast.showError(context, '$symptom: 24시간 이상 지속 여부를 선택해주세요');
        return;
      }
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

      // 4. WeightLog 생성
      final weightLog = WeightLog(
        id: const Uuid().v4(),
        userId: userId,
        logDate: _selectedDate,
        weightKg: weight,
        appetiteScore: _appetiteScore,
        createdAt: DateTime.now(),
      );

      // 5. SymptomLog 리스트 생성 (각 증상마다 개별 심각도)
      final symptomLogs = _selectedSymptoms.map((symptom) {
        final severity = _symptomSeverities[symptom] ?? 5;
        final isPersistent = _symptomPersistent[symptom];
        final tags = _symptomTags[symptom] ?? [];

        return SymptomLog(
          id: const Uuid().v4(),
          userId: userId,
          logDate: _selectedDate,
          symptomName: symptom,
          severity: severity,
          isPersistent24h: isPersistent,
          note: _note.isEmpty ? null : _note,
          createdAt: DateTime.now(),
          tags: tags,
        );
      }).toList();

      // 6. 저장 (saveDailyLog가 자동으로 /dashboard로 이동)
      await ref.read(trackingProvider.notifier).saveDailyLog(
            weightLog: weightLog,
            symptomLogs: symptomLogs,
          );

      // 저장 성공 (자동으로 대시보드 이동됨)
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
        backgroundColor: const Color(0xFFF8FAFC), // Neutral-50
        elevation: 0,
        title: const Text(
          '데일리 기록',
          style: TextStyle(
            fontSize: 20.0, // xl
            fontWeight: FontWeight.w600, // Semibold
            color: Color(0xFF1E293B), // Neutral-800
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE2E8F0), // Neutral-200
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
        color: Colors.white, // White
        borderRadius: BorderRadius.circular(12.0), // md
        border: Border.all(
          color: const Color(0xFFE2E8F0), // Neutral-200
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
      padding: const EdgeInsets.all(16.0), // md
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Change 10: 섹션 제목 타이포그래피 계층 개선
          const Text(
            '신체 기록',
            style: TextStyle(
              fontSize: 20.0, // xl
              fontWeight: FontWeight.w600, // Semibold
              color: Color(0xFF1E293B), // Neutral-800
            ),
          ),
          const SizedBox(height: 12.0), // sm + xs

          // 체중 입력
          InputValidationWidget(
            fieldName: '체중',
            label: '체중 (kg)',
            hint: '예: 75.5',
            onChanged: _handleWeightChanged,
          ),
          const SizedBox(height: 16.0), // md

          // 식욕 조절 점수 (필수)
          const Text(
            '식욕 조절 *',
            style: TextStyle(
              fontSize: 18.0, // lg
              fontWeight: FontWeight.w600, // Semibold
              color: Color(0xFF334155), // Neutral-700
            ),
          ),
          const SizedBox(height: 12.0), // sm + xs
          _buildAppetiteButtons(),
        ],
      ),
    );
  }

  Widget _buildAppetiteButtons() {
    // Change 2: 식욕 조절 칩 스타일 개선 (AppealScoreChip 사용)
    const appetiteLabels = {
      5: '폭발',
      4: '보통',
      3: '약간↓',
      2: '많이↓',
      1: '없음',
    };

    return Wrap(
      spacing: 8.0, // sm
      runSpacing: 8.0, // sm
      children: appetiteLabels.entries.map((entry) {
        final score = entry.key;
        final label = entry.value;
        final isSelected = _appetiteScore == score;

        return AppealScoreChip(
          label: label,
          isSelected: isSelected,
          onTap: () => _handleAppetiteScoreSelected(score),
        );
      }).toList(),
    );
  }

  Widget _buildSideEffectsSection() {
    return Container(
      // Change 3: 카드 스타일 개선, 초기 확장 상태
      decoration: BoxDecoration(
        color: Colors.white, // White
        borderRadius: BorderRadius.circular(12.0), // md
        border: Border.all(
          color: const Color(0xFFE2E8F0), // Neutral-200
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
      padding: const EdgeInsets.all(16.0), // md
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 제목
          const Text(
            '부작용 기록 (선택)',
            style: TextStyle(
              fontSize: 20.0, // xl
              fontWeight: FontWeight.w600, // Semibold
              color: Color(0xFF1E293B), // Neutral-800
            ),
          ),
          const SizedBox(height: 12.0), // sm + xs

          // 증상 선택 칩
          const Text(
            '증상 선택',
            style: TextStyle(
              fontSize: 18.0, // lg
              fontWeight: FontWeight.w600, // Semibold
              color: Color(0xFF334155), // Neutral-700
            ),
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
                backgroundColor: const Color(0xFFF1F5F9), // Neutral-100
                selectedColor: const Color(0xFF4ADE80), // Primary
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.0), // full
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // sm
                labelStyle: TextStyle(
                  fontSize: 14.0, // sm
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF334155), // Neutral-700
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24.0), // lg

          // 선택된 증상별 개별 설정
          if (_selectedSymptoms.isNotEmpty) ...[
            const Text(
              '선택된 증상',
              style: TextStyle(
                fontSize: 18.0, // lg
                fontWeight: FontWeight.w600, // Semibold
                color: Color(0xFF334155), // Neutral-700
              ),
            ),
            const SizedBox(height: 12.0), // sm + xs
            ..._selectedSymptoms.map((symptom) {
              return _buildSymptomDetail(symptom);
            }),
          ],

          // 공통 메모
          const SizedBox(height: 16.0), // md
          // Change 7: 입력 필드 높이 & 스타일 통일
          const Text(
            '메모 (선택)',
            style: TextStyle(
              fontSize: 14.0, // sm
              fontWeight: FontWeight.w600, // Semibold
              color: Color(0xFF334155), // Neutral-700
            ),
          ),
          const SizedBox(height: 8.0), // sm
          TextField(
            decoration: InputDecoration(
              hintText: '추가 메모를 입력하세요',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // sm
                borderSide: const BorderSide(
                  color: Color(0xFFCBD5E1), // Neutral-300
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // sm
                borderSide: const BorderSide(
                  color: Color(0xFF4ADE80), // Primary
                  width: 2.0,
                ),
              ),
            ),
            maxLines: 4,
            minLines: 4,
            style: const TextStyle(
              fontSize: 16.0, // base
              fontWeight: FontWeight.w400, // Regular
              color: Color(0xFF0F172A), // Neutral-900
            ),
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
      margin: const EdgeInsets.only(bottom: 16.0), // md
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0), // md
        border: Border.all(
          color: const Color(0xFFE2E8F0), // Neutral-200
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
      padding: const EdgeInsets.all(16.0), // md
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 증상명
          Text(
            symptom,
            style: const TextStyle(
              fontSize: 18.0, // lg
              fontWeight: FontWeight.w600, // Semibold
              color: Color(0xFF1E293B), // Neutral-800
            ),
          ),
          const SizedBox(height: 16.0), // md

          // Change 4: 심각도 슬라이더 의미 시각화 (SeverityLevelIndicator 사용)
          const Text(
            '심각도',
            style: TextStyle(
              fontSize: 14.0, // sm
              fontWeight: FontWeight.w600, // Semibold
              color: Color(0xFF334155), // Neutral-700
            ),
          ),
          const SizedBox(height: 8.0), // sm
          SeverityLevelIndicator(
            severity: severity,
            onChanged: (value) => _handleSeverityChanged(symptom, value),
          ),
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
                          title: const Text(
                            '예',
                            style: TextStyle(
                              fontSize: 16.0, // base
                              fontWeight: FontWeight.w400, // Regular
                              color: Color(0xFF334155), // Neutral-700
                            ),
                          ),
                          value: true,
                          groupValue: isPersistent,
                          onChanged: (value) =>
                              _handlePersistentChanged(symptom, value),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: const Color(0xFF4ADE80), // Primary
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text(
                            '아니오',
                            style: TextStyle(
                              fontSize: 16.0, // base
                              fontWeight: FontWeight.w400, // Regular
                              color: Color(0xFF334155), // Neutral-700
                            ),
                          ),
                          value: false,
                          groupValue: isPersistent,
                          onChanged: (value) =>
                              _handlePersistentChanged(symptom, value),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: const Color(0xFF4ADE80), // Primary
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
                    backgroundColor: const Color(0xFFF1F5F9), // Neutral-100
                    selectedColor: const Color(0xFF4ADE80), // Primary
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999.0), // full
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0), // sm
                    labelStyle: TextStyle(
                      fontSize: 14.0, // sm
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF334155), // Neutral-700
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
