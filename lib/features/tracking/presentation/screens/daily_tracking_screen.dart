import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/application/notifiers/tracking_notifier.dart';
import 'package:n06/features/tracking/presentation/widgets/date_selection_widget.dart';
import 'package:n06/features/tracking/presentation/widgets/input_validation_widget.dart';

/// 통합 데일리 기록 화면
///
/// 하나의 화면에서 체중, 식욕 조절, 부작용 증상을 모두 기록할 수 있습니다.
/// - 체중 기록
/// - 식욕 조절 점수 (필수)
/// - 부작용 기록 (선택, 증상별 개별 심각도)
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

  void _handleSeverityChanged(String symptom, double value) {
    setState(() {
      _symptomSeverities[symptom] = value.round();

      // 심각도 변경 시 옵션 초기화
      final severity = value.round();
      if (severity >= 7) {
        // 7-10점: 태그 제거, persistent 옵션 표시
        _symptomTags[symptom] = [];
        _symptomPersistent[symptom] ??= null;
      } else {
        // 1-6점: persistent 제거, 태그 옵션 표시
        _symptomPersistent[symptom] = null;
        _symptomTags[symptom] ??= [];
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
      _showErrorDialog('체중을 입력해주세요');
      return;
    }

    final weight = double.tryParse(_weightInput);
    if (weight == null || weight < 20 || weight > 300) {
      _showErrorDialog('유효한 체중을 입력해주세요 (20-300kg)');
      return;
    }

    // 2. 식욕 점수 검증 (필수)
    if (_appetiteScore == null) {
      _showErrorDialog('식욕 조절을 선택해주세요');
      return;
    }

    // 3. 증상별 검증 (심각도 7-10점인 경우 24시간 지속 여부 필수)
    for (final symptom in _selectedSymptoms) {
      final severity = _symptomSeverities[symptom] ?? 5;
      if (severity >= 7 && _symptomPersistent[symptom] == null) {
        _showErrorDialog('$symptom: 24시간 이상 지속 여부를 선택해주세요');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        _showErrorDialog('로그인이 필요합니다');
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
        _showErrorDialog('저장 중 오류가 발생했습니다: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('입력 확인'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('데일리 기록'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 날짜 선택
                  DateSelectionWidget(
                    initialDate: _selectedDate,
                    onDateSelected: _handleDateSelected,
                  ),
                  const SizedBox(height: 24),

                  // 2. 신체 기록 섹션
                  _buildBodySection(),
                  const SizedBox(height: 24),

                  // 3. 부작용 기록 섹션 (접힌 상태)
                  _buildSideEffectsSection(),
                  const SizedBox(height: 32),

                  // 4. 저장 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        '저장',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBodySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '신체 기록',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // 체중 입력
        InputValidationWidget(
          fieldName: '체중',
          label: '체중 (kg)',
          hint: '예: 75.5',
          onChanged: _handleWeightChanged,
        ),
        const SizedBox(height: 24),

        // 식욕 조절 점수 (필수)
        const Text(
          '식욕 조절 *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        _buildAppetiteButtons(),
      ],
    );
  }

  Widget _buildAppetiteButtons() {
    const appetiteLabels = {
      5: '폭발',
      4: '보통',
      3: '약간↓',
      2: '많이↓',
      1: '없음',
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: appetiteLabels.entries.map((entry) {
        final score = entry.key;
        final label = entry.value;
        final isSelected = _appetiteScore == score;

        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => _handleAppetiteScoreSelected(score),
        );
      }).toList(),
    );
  }

  Widget _buildSideEffectsSection() {
    return ExpansionTile(
      title: const Text(
        '부작용 기록 (선택)',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: false,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 증상 선택 칩
              const Text(
                '증상 선택',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _symptoms.map((symptom) {
                  return FilterChip(
                    label: Text(symptom),
                    selected: _selectedSymptoms.contains(symptom),
                    onSelected: (_) => _handleSymptomToggle(symptom),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 선택된 증상별 개별 설정
              if (_selectedSymptoms.isNotEmpty) ...[
                const Text(
                  '선택된 증상',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                ..._selectedSymptoms.map((symptom) {
                  return _buildSymptomDetail(symptom);
                }).toList(),
              ],

              // 공통 메모
              const SizedBox(height: 24),
              TextField(
                decoration: const InputDecoration(
                  labelText: '메모 (선택)',
                  hintText: '추가 메모를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) => setState(() => _note = value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomDetail(String symptom) {
    final severity = _symptomSeverities[symptom] ?? 5;
    final isPersistent = _symptomPersistent[symptom];
    final tags = _symptomTags[symptom] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 증상명
            Text(
              symptom,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 심각도 슬라이더
            Row(
              children: [
                const Text('심각도:'),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: severity.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '$severity점',
                    onChanged: (value) => _handleSeverityChanged(symptom, value),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '$severity점',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 심각도 7-10점: 24시간 지속 여부
            if (severity >= 7) ...[
              const Text(
                '24시간 이상 지속 여부',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('예'),
                      value: true,
                      groupValue: isPersistent,
                      onChanged: (value) =>
                          _handlePersistentChanged(symptom, value),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('아니오'),
                      value: false,
                      groupValue: isPersistent,
                      onChanged: (value) =>
                          _handlePersistentChanged(symptom, value),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ],

            // 심각도 1-6점: 컨텍스트 태그
            if (severity < 7) ...[
              const Text(
                '관련 상황 (선택)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _contextTags.map((tag) {
                  return FilterChip(
                    label: Text(tag),
                    selected: tags.contains(tag),
                    onSelected: (_) => _handleTagToggle(symptom, tag),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
