import 'package:flutter/widgets.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/daily_checkin/domain/entities/weekly_report.dart';
import 'package:n06/features/daily_checkin/presentation/utils/weekly_report_i18n.dart';

/// 텍스트 형식 리포트 생성기
///
/// WeeklyReport를 의료진과 공유할 수 있는 텍스트 형식으로 변환합니다.
/// i18n을 지원하며 Presentation Layer에서만 사용됩니다.
class TextReportFormatter {
  const TextReportFormatter._();

  /// WeeklyReport를 텍스트 형식으로 변환
  static String format(BuildContext context, WeeklyReport report) {
    final buffer = StringBuffer();
    final l10n = context.l10n;

    // 헤더
    buffer.writeln('═' * 40);
    buffer.writeln(l10n.report_share_cardTitle);
    buffer.writeln('═' * 40);
    buffer.writeln();

    // 기본 정보
    if (report.userName != null) {
      buffer.writeln('👤 ${report.userName}');
    }
    if (report.medicationName != null) {
      buffer.writeln('💊 ${report.medicationName}');
    }
    buffer.writeln(
      '📅 ${_formatDate(report.periodStart)} - ${_formatDate(report.periodEnd)}',
    );
    buffer.writeln();

    // 주요 지표 섹션
    buffer.writeln('▶ ${l10n.report_share_metricCheckin}');
    buffer.writeln(
      '   ${l10n.report_share_metricCheckinValue(
        report.checkinAchievement.checkinDays,
        report.checkinAchievement.totalDays,
        report.checkinAchievement.percentage,
      )}',
    );
    buffer.writeln();

    // 체중 변화
    if (report.weightSummary != null) {
      buffer.writeln('▶ ${l10n.report_share_metricWeight}');
      buffer.writeln(
        '   ${l10n.report_share_metricWeightValue(
          report.weightSummary!.startWeight.toStringAsFixed(1),
          report.weightSummary!.endWeight.toStringAsFixed(1),
          WeeklyReportI18n.weightChange(
            context,
            report.weightSummary!.direction,
            report.weightSummary!.change,
          ),
        )}',
      );
      buffer.writeln();
    }

    // 식욕
    buffer.writeln('▶ ${l10n.report_share_metricAppetite}');
    buffer.writeln(
      '   ${l10n.report_share_metricAppetiteValue(
        report.appetiteSummary.averageScore.toStringAsFixed(1),
        WeeklyReportI18n.appetiteStabilityName(
          context,
          report.appetiteSummary.stability,
        ),
      )}',
    );
    buffer.writeln();

    // 증상 발생 현황
    if (report.symptomOccurrences.isNotEmpty) {
      buffer.writeln('▶ ${l10n.report_share_sectionSymptoms}');
      for (final symptom in report.symptomOccurrences.take(5)) {
        buffer.writeln(
          '   ${l10n.report_share_symptomItem(
            WeeklyReportI18n.symptomTypeName(context, symptom.type),
            symptom.daysOccurred,
            WeeklyReportI18n.severitySummary(context, symptom.severityCounts),
          )}',
        );
      }
      buffer.writeln();
    }

    // Red Flag 기록
    if (report.redFlagRecords.isNotEmpty) {
      buffer.writeln('▶ ⚠️ 주의 필요 기록');
      for (final record in report.redFlagRecords) {
        buffer.writeln(
          '   ${_formatDate(record.date)}: ${WeeklyReportI18n.redFlagTypeName(context, record.type)}',
        );
        if (record.symptoms.isNotEmpty) {
          buffer.writeln('      증상: ${record.symptoms.join(', ')}');
        }
      }
      buffer.writeln();
    }

    // 컨디션 추이
    buffer.writeln('▶ ${l10n.report_share_sectionCondition}');
    final emojis = report.dailyConditions.map((c) {
      return c.mood != null ? WeeklyReportI18n.moodToEmoji(c.mood!) : '--';
    }).join(' ');
    buffer.writeln('   $emojis');

    final days = report.dailyConditions.map((c) {
      return WeeklyReportI18n.dayOfWeekShort(context, c.date);
    }).join(' ');
    buffer.writeln('   $days');
    buffer.writeln();

    buffer.writeln('═' * 40);

    return buffer.toString();
  }

  static String _formatDate(DateTime date) {
    return '${date.month}.${date.day}';
  }
}
