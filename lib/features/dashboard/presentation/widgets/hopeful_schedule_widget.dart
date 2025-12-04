import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import '../../domain/entities/next_schedule.dart';

/// 의료 용어를 여정/성장 언어로 변환
///
/// 심리학적 근거:
/// - "투여" -> "단계" : 치료를 여정의 일부로 인식
/// - "증량" -> "성장" : 용량 증가를 부담이 아닌 발전으로
String getHopefulTitle(BuildContext context, String scheduleType) {
  switch (scheduleType) {
    case 'dose':
      return context.l10n.dashboard_schedule_dose_title;
    case 'escalation':
      return context.l10n.dashboard_schedule_escalation_title;
    default:
      return scheduleType;
  }
}

/// 각 일정에 따뜻한 격려 메시지 제공
///
/// 심리학적 근거:
/// - 불안 감소: 미리 준비하면 덜 두렵다
/// - 정상화: "많은 분들이 이 단계를 거쳐요"
String getSupportMessage(BuildContext context, String scheduleType) {
  switch (scheduleType) {
    case 'dose':
      return context.l10n.dashboard_schedule_dose_supportMessage;
    case 'escalation':
      return context.l10n.dashboard_schedule_escalation_supportMessage;
    default:
      return '';
  }
}

/// HopefulScheduleWidget - 희망적 프레이밍의 일정 위젯
///
/// NextScheduleWidget의 감정적 UX 개선 버전
/// Forest 스타일의 성장 은유와 Headspace 스타일의 부드러운 안내를 적용
///
/// 주요 변경점:
/// - "다음 투여" -> "다음 단계" (여정의 일부로 프레이밍)
/// - "다음 증량" -> "성장의 순간" (긍정적 의미 부여)
/// - 각 일정에 격려 메시지 추가
/// - 아이콘에 원형 배경 추가 (시각적 따뜻함)
class HopefulScheduleWidget extends StatelessWidget {
  final NextSchedule schedule;

  const HopefulScheduleWidget({
    super.key,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A), // sm shadow
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24), // lg padding
      child: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Text(
              context.l10n.dashboard_schedule_title,
              style: AppTypography.heading2,
            ),

            const SizedBox(height: 16), // md spacing

            // Next Dose Schedule (다음 단계)
            _HopefulScheduleItem(
              icon: Icons.medication_outlined,
              iconColor: AppColors.primary,
              scheduleType: 'dose',
              date: schedule.nextDoseDate,
              subtitle: context.l10n.dashboard_schedule_dose_subtitle(
                schedule.nextDoseMg.toStringAsFixed(schedule.nextDoseMg.truncateToDouble() == schedule.nextDoseMg ? 0 : 1),
              ),
            ),

            if (schedule.nextEscalationDate != null) ...[
              const SizedBox(height: 24), // lg spacing between items

              // Next Escalation Schedule (성장의 순간)
              _HopefulScheduleItem(
                icon: Icons.trending_up,
                iconColor: AppColors.textTertiary,
                scheduleType: 'escalation',
                date: schedule.nextEscalationDate!,
                subtitle: null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}


/// 개별 일정 아이템 위젯
///
/// 각 일정을 희망적인 언어와 격려 메시지로 표시
class _HopefulScheduleItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String scheduleType;
  final DateTime date;
  final String? subtitle;

  const _HopefulScheduleItem({
    required this.icon,
    required this.iconColor,
    required this.scheduleType,
    required this.date,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M월 d일 (E)', 'ko_KR');
    final dateString = dateFormat.format(date);
    final hopefulTitle = getHopefulTitle(context, scheduleType);
    final supportMessage = getSupportMessage(context, scheduleType);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon Container (40x40px, 원형 배경)
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20), // full radius
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
              semanticLabel: hopefulTitle,
            ),
          ),
        ),

        const SizedBox(width: 16), // md spacing

        // Text Column (Expanded)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title (희망적 언어)
              Text(
                hopefulTitle,
                style: AppTypography.caption,
              ),

              const SizedBox(height: 2),

              // Date
              Text(
                dateString,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Subtitle (mg 정보)
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTypography.bodySmall,
                ),
              ],

              // Support Message (격려 메시지)
              if (supportMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    supportMessage,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
