import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:n06/core/theme/app_colors.dart';
import 'package:n06/core/theme/app_text_styles.dart';
import 'package:n06/core/widgets/app_button.dart';
import 'package:n06/core/widgets/app_card.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
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
  const EmergencyCheckScreen({super.key});

  @override
  ConsumerState<EmergencyCheckScreen> createState() => _EmergencyCheckScreenState();
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
  Future<void> _handleConfirm() async {
    final selectedSymptoms = <String>[];
    for (int i = 0; i < selectedStates.length; i++) {
      if (selectedStates[i]) {
        selectedSymptoms.add(emergencySymptoms[i]);
      }
    }

    // BR3: 전문가 상담 권장 조건 (하나라도 선택 시)
    if (selectedSymptoms.isNotEmpty) {
      // 증상 체크 저장 - await 추가하여 저장 완료 후 다이얼로그 표시
      await _saveEmergencyCheck(selectedSymptoms);

      // mounted 체크: 저장 중 화면이 종료되었을 수 있음
      if (!mounted) return;

      // 전문가 상담 권장 다이얼로그 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ConsultationRecommendationDialog(selectedSymptoms: selectedSymptoms),
      ).then((_) {
        // 다이얼로그 닫힌 후 화면 종료
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  /// 증상 체크 저장
  /// BR4: emergency_symptom_checks + symptom_logs 저장
  Future<void> _saveEmergencyCheck(List<String> selectedSymptoms) async {
    // AuthNotifier에서 현재 사용자 ID 가져오기
    final userId = ref.read(authNotifierProvider).value?.id ?? 'current-user-id';

    final check = EmergencySymptomCheck(
      id: const Uuid().v4(),
      userId: userId,
      checkedAt: DateTime.now(),
      checkedSymptoms: selectedSymptoms,
    );

    // Notifier를 통한 저장 (자동으로 부작용 기록도 생성)
    try {
      await ref.read(emergencyCheckNotifierProvider.notifier).saveEmergencyCheck(userId, check);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('증상이 기록되었습니다.'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
          content: Text('기록 실패: $e', style: AppTextStyles.body2.copyWith(color: Colors.white)),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  /// 해당 없음 버튼 클릭 처리
  void _handleNoSymptoms() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Provider를 구독하여 화면이 활성화된 동안 유지
    ref.watch(emergencyCheckNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('증상 체크'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '다음 증상 중 해당하는 것이 있나요?',
                    style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '해당하는 증상을 선택해주세요.',
                    style: AppTextStyles.body2.copyWith(color: AppColors.gray),
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
                  (index) => AppCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.zero,
                    child: CheckboxListTile(
                      value: selectedStates[index],
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          selectedStates[index] = value ?? false;
                        });
                      },
                      title: Text(emergencySymptoms[index], style: AppTextStyles.body2),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
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
              child: AppButton(
                text: '해당 없음',
                onPressed: _handleNoSymptoms,
                type: AppButtonType.outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: '확인',
                onPressed: selectedStates.any((state) => state) ? _handleConfirm : null,
                type: AppButtonType.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
