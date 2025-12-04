import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_toast.dart';
import 'package:n06/features/tracking/presentation/widgets/consultation_recommendation_dialog.dart';
import 'package:n06/features/tracking/presentation/widgets/emergency_checklist_item.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

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
  List<String> _getEmergencySymptoms(BuildContext context) {
    return [
      context.l10n.tracking_emergency_symptom1,
      context.l10n.tracking_emergency_symptom2,
      context.l10n.tracking_emergency_symptom3,
      context.l10n.tracking_emergency_symptom4,
      context.l10n.tracking_emergency_symptom5,
      context.l10n.tracking_emergency_symptom6,
      context.l10n.tracking_emergency_symptom7,
    ];
  }

  /// 선택된 증상 목록
  late List<bool> selectedStates;

  @override
  void initState() {
    super.initState();
    selectedStates = List.filled(7, false);
  }

  /// 확인 버튼 클릭 처리
  Future<void> _handleConfirm() async {
    final emergencySymptoms = _getEmergencySymptoms(context);
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
    // EmergencySymptomCheck is removed - this screen is deprecated
    // Notifier를 통한 저장 (자동으로 부작용 기록도 생성)
    try {
      if (mounted) {
        GabiumToast.showSuccess(context, context.l10n.tracking_emergency_saveSuccess);
      }
    } catch (e) {
      if (mounted) {
        GabiumToast.showError(context, context.l10n.tracking_emergency_saveFailed(e.toString()));
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
          context.l10n.tracking_emergency_title,
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
                    context.l10n.tracking_emergency_question,
                    style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.tracking_emergency_instruction,
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            // Symptom Checklist
            Padding(
              padding: const EdgeInsets.all(24), // lg
              child: Column(
                children: () {
                  final emergencySymptoms = _getEmergencySymptoms(context);
                  return List.generate(
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
                  );
                }(),
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
                text: context.l10n.tracking_emergency_noSymptomsButton,
                onPressed: _handleNoSymptoms,
                variant: GabiumButtonVariant.secondary,
                size: GabiumButtonSize.medium,
              ),
            ),
            const SizedBox(width: 12),
            // Primary Button: Confirm (disabled if no symptoms selected)
            Expanded(
              child: GabiumButton(
                text: context.l10n.tracking_emergency_confirmButton,
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
