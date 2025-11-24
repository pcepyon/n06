import 'package:flutter/material.dart';
import 'package:n06/features/tracking/domain/usecases/analyze_plan_change_impact_usecase.dart';

/// ImpactAnalysisDialog: 투여 계획 변경 영향 분석 다이얼로그
///
/// Design System 준수:
/// - Max Width: 480px
/// - Border Radius: 16px (lg)
/// - Shadow: xl
/// - Modal 패턴 준수
/// - 색상: Primary (#4ADE80), Warning (#F59E0B), Info (#3B82F6), Success (#10B981)
class ImpactAnalysisDialog extends StatelessWidget {
  final PlanChangeImpact impact;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ImpactAnalysisDialog({
    super.key,
    required this.impact,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // lg
          boxShadow: [
            // xl shadow
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.12),
              blurRadius: 32,
              spreadRadius: 8,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ====== 헤더 ======
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE2E8F0), // Neutral-200
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '투여 계획 변경',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF1E293B), // Neutral-800
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  GestureDetector(
                    onTap: onCancel,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: const Color(0xFF64748B), // Neutral-500
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ====== 바디 ======
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 설명 텍스트
                  Text(
                    '투여 계획 변경 시 이후 스케줄이 재계산됩니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF475569), // Neutral-600
                      height: 1.5,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 영향받는 스케줄 수
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4), // Success light
                      border: Border.all(
                        color: const Color(0xFFD1FAE5), // Success lighter
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          size: 20,
                          color: const Color(0xFF10B981), // Success
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '영향받는 스케줄: ${impact.affectedScheduleCount}개',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF065F46), // Success dark
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 변경되는 항목 (칩 형식)
                  if (impact.changedFields.isNotEmpty) ...[
                    Text(
                      '변경되는 항목:',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF334155), // Neutral-700
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: impact.changedFields.map((field) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF), // Info light
                            border: Border.all(
                              color: const Color(0xFFBFDBFE), // Info lighter
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(20), // full
                          ),
                          child: Text(
                            field,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF1E40AF), // Info dark
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 경고 메시지
                  if (impact.warningMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7), // Warning light
                        border: Border.all(
                          color: const Color(0xFFFDE68A), // Warning lighter
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 20,
                            color: const Color(0xFFB45309), // Warning dark
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              impact.warningMessage!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFFB45309), // Warning dark
                                height: 1.4,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ====== 푸터 (버튼) ======
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE2E8F0), // Neutral-200
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 취소 버튼
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF4ADE80), // Primary
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // sm
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF4ADE80), // Primary
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 확인 버튼
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ADE80), // Primary
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // sm
                          ),
                        ),
                        child: Text(
                          '확인',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
