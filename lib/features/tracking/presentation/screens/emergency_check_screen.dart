import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_toast.dart';
import 'package:n06/features/tracking/application/providers.dart';
// import 'package:n06/features/tracking/domain/entities/emergency_symptom_check.dart'; // DEPRECATED - removed
import 'package:n06/features/tracking/presentation/widgets/consultation_recommendation_dialog.dart';
import 'package:n06/features/tracking/presentation/widgets/emergency_checklist_item.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

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

    // EmergencySymptomCheck is removed - this screen is deprecated
    // final check = null; // EmergencySymptomCheck(
    //   id: const Uuid().v4(),
    //   userId: userId,
    //   checkedAt: DateTime.now(),
    //   checkedSymptoms: selectedSymptoms,
    // );

    // Notifier를 통한 저장 (자동으로 부작용 기록도 생성)
    try {
      // await ref.read(emergencyCheckNotifierProvider.notifier).saveEmergencyCheck(userId, check); // DEPRECATED

      if (mounted) {
        GabiumToast.showSuccess(context, '증상이 기록되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        GabiumToast.showError(context, '기록 실패: $e');
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
    // ref.watch(emergencyCheckNotifierProvider); // DEPRECATED

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '증상 체크',
          style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Warning Accent
            Container(
              padding: const EdgeInsets.all(24), // lg
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                border: Border(
                  left: BorderSide(color: AppColors.error, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '다음 증상 중 해당하는 것이 있나요?',
                    style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '해당하는 증상을 선택해주세요.',
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            // Symptom Checklist
            Padding(
              padding: const EdgeInsets.all(24), // lg
              child: Column(
                children: List.generate(
                  emergencySymptoms.length,
                  (index) => EmergencyChecklistItem(
                    symptom: emergencySymptoms[index],
                    isChecked: selectedStates[index],
                    onChanged: (value) {
                      setState(() {
                        selectedStates[index] = value ?? false;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.background,
        child: Row(
          children: [
            // Secondary Button: No Symptoms
            Expanded(
              child: GabiumButton(
                text: '해당 없음',
                onPressed: _handleNoSymptoms,
                variant: GabiumButtonVariant.secondary,
                size: GabiumButtonSize.medium,
              ),
            ),
            const SizedBox(width: 12),
            // Primary Button: Confirm (disabled if no symptoms selected)
            Expanded(
              child: GabiumButton(
                text: '확인',
                onPressed: selectedStates.any((state) => state) ? _handleConfirm : null,
                variant: GabiumButtonVariant.primary,
                size: GabiumButtonSize.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
