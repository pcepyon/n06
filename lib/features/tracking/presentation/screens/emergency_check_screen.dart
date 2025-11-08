import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/domain/entities/emergency_symptom_check.dart';
import 'package:n06/features/tracking/presentation/widgets/consultation_recommendation_dialog.dart';

/// F005: 증상 체크 화면
///
/// 긴급 증상 체크리스트를 제공하고,
/// 사용자가 선택한 증상에 따라 전문가 상담을 권장합니다.
///
/// BR1: 체크리스트 항목 (7개 고정)
/// BR3: 전문가 상담 권장 조건 (하나라도 선택 시 권장)
/// BR4: 데이터 저장 규칙 (emergency_symptom_checks, symptom_logs)
class EmergencyCheckScreen extends ConsumerStatefulWidget {
  const EmergencyCheckScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EmergencyCheckScreen> createState() =>
      _EmergencyCheckScreenState();
}

class _EmergencyCheckScreenState extends ConsumerState<EmergencyCheckScreen> {
  /// BR1: 체크리스트 항목 (7개 고정)
  static const emergencySymptoms = [
    '24시간 이상 계속 구토하고 있어요',
    '물이나 음식을 전혀 삼킬 수 없어요',
    '매우 심한 복통이 있어요 (견디기 어려운 정도)',
    '설사가 48시간 이상 계속되고 있어요',
    '소변이 진한 갈색이거나 8시간 이상 나오지 않았어요',
    '대변에 피가 섞여 있거나 검은색이에요',
    '피부나 눈 흰자위가 노랗게 변했어요',
  ];

  /// 선택된 증상 목록
  late List<bool> selectedStates;

  @override
  void initState() {
    super.initState();
    selectedStates = List.filled(emergencySymptoms.length, false);
  }

  /// 확인 버튼 클릭 처리
  void _handleConfirm() {
    final selectedSymptoms = <String>[];
    for (int i = 0; i < selectedStates.length; i++) {
      if (selectedStates[i]) {
        selectedSymptoms.add(emergencySymptoms[i]);
      }
    }

    // BR3: 전문가 상담 권장 조건 (하나라도 선택 시)
    if (selectedSymptoms.isNotEmpty) {
      // 증상 체크 저장
      _saveEmergencyCheck(selectedSymptoms);

      // 전문가 상담 권장 다이얼로그 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ConsultationRecommendationDialog(
          selectedSymptoms: selectedSymptoms,
        ),
      ).then((_) {
        // 다이얼로그 닫힌 후 화면 종료
        Navigator.of(context).pop();
      });
    }
  }

  /// 증상 체크 저장
  /// BR4: emergency_symptom_checks + symptom_logs 저장
  Future<void> _saveEmergencyCheck(List<String> selectedSymptoms) async {
    // 사용자 ID는 실제 앱에서 AuthNotifier에서 가져와야 함
    // 현재는 테스트 ID 사용
    const userId = 'current-user-id';

    final check = EmergencySymptomCheck(
      id: const Uuid().v4(),
      userId: userId,
      checkedAt: DateTime.now(),
      checkedSymptoms: selectedSymptoms,
    );

    // Notifier를 통한 저장 (자동으로 부작용 기록도 생성)
    try {
      await ref
          .read(emergencyCheckNotifierProvider.notifier)
          .saveEmergencyCheck(userId, check);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('증상이 기록되었습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('기록 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 해당 없음 버튼 클릭 처리
  void _handleNoSymptoms() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('증상 체크'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '다음 증상 중 해당하는 것이 있나요?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '해당하는 증상을 선택해주세요.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // 증상 체크리스트
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(
                  emergencySymptoms.length,
                  (index) => CheckboxListTile(
                    value: selectedStates[index],
                    onChanged: (value) {
                      setState(() {
                        selectedStates[index] = value ?? false;
                      });
                    },
                    title: Text(
                      emergencySymptoms[index],
                      style: const TextStyle(fontSize: 14),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _handleNoSymptoms,
                child: const Text('해당 없음'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                // 증상이 선택되지 않으면 비활성화
                onPressed: selectedStates.any((state) => state)
                    ? _handleConfirm
                    : null,
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
