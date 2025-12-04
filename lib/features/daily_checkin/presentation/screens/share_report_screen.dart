import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/daily_checkin/domain/entities/weekly_report.dart';
import 'package:n06/features/daily_checkin/application/services/weekly_report_generator.dart';
import 'package:n06/features/daily_checkin/application/providers.dart';
import 'package:n06/features/daily_checkin/presentation/utils/weekly_report_i18n.dart';
import 'package:n06/features/tracking/application/providers.dart';

/// 주간 리포트 공유 화면
class ShareReportScreen extends ConsumerStatefulWidget {
  const ShareReportScreen({super.key});

  @override
  ConsumerState<ShareReportScreen> createState() => _ShareReportScreenState();
}

class _ShareReportScreenState extends ConsumerState<ShareReportScreen> {
  int _selectedWeekOffset = 0; // 0: 이번 주, 1: 지난주
  WeeklyReport? _report;
  String? _textReport;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = ref.read(authNotifierProvider).value?.id;
      if (userId == null) {
        throw Exception('LOGIN_REQUIRED');
      }

      final checkinRepository = ref.read(dailyCheckinRepositoryProvider);
      final trackingRepository = ref.read(trackingRepositoryProvider);
      final medicationRepository = ref.read(medicationRepositoryProvider);

      final generator = WeeklyReportGenerator(
        checkinRepository: checkinRepository,
        trackingRepository: trackingRepository,
        medicationRepository: medicationRepository,
      );

      final user = ref.read(authNotifierProvider).value;
      final report = await generator.generate(
        userId: userId,
        weekOffset: _selectedWeekOffset,
        user: user,
      );

      // Note: generateTextReport is deprecated, will be replaced with i18n version
      // For now, we skip text report generation
      // final textReport = generator.generateTextReport(report);

      setState(() {
        _report = report;
        _textReport = null; // Temporarily null until we implement i18n text report
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Text(context.l10n.report_share_title),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        actions: [
          if (_report != null)
            IconButton(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.share_outlined),
            ),
        ],
      ),
      body: Column(
        children: [
          // 기간 선택
          _buildPeriodSelector(),

          // 리포트 내용
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorView()
                    : _buildReportContent(),
          ),
        ],
      ),
      bottomNavigationBar: _report != null
          ? _buildBottomActions()
          : null,
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildPeriodChip(0, context.l10n.report_share_periodThisWeek),
          const SizedBox(width: 8),
          _buildPeriodChip(1, context.l10n.report_share_periodLastWeek),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(int weekOffset, String label) {
    final isSelected = _selectedWeekOffset == weekOffset;
    return GestureDetector(
      onTap: () {
        if (_selectedWeekOffset != weekOffset) {
          setState(() {
            _selectedWeekOffset = weekOffset;
          });
          _loadReport();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.neutral100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.neutral700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.neutral400,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.report_share_errorLoad,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.neutral700,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadReport,
            child: Text(context.l10n.common_button_retry),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    if (_report == null) {
      return Center(
        child: Text(context.l10n.report_share_errorNoData),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 리포트 미리보기 카드
          _buildReportPreviewCard(),
          const SizedBox(height: 16),

          // 텍스트 리포트 미리보기
          _buildTextReportPreview(),
        ],
      ),
    );
  }

  Widget _buildReportPreviewCard() {
    final report = _report!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.assessment_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.report_share_cardTitle,
                      style: AppTypography.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_formatDate(report.periodStart)} - ${_formatDate(report.periodEnd)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 주요 지표
          _buildMetricRow(
            context.l10n.report_share_metricCheckin,
            context.l10n.report_share_metricCheckinValue(
              report.checkinAchievement.checkinDays,
              report.checkinAchievement.totalDays,
              report.checkinAchievement.percentage,
            ),
            Icons.check_circle_outline,
          ),
          const SizedBox(height: 12),

          if (report.weightSummary != null) ...[
            _buildMetricRow(
              context.l10n.report_share_metricWeight,
              context.l10n.report_share_metricWeightValue(
                report.weightSummary!.startWeight.toStringAsFixed(1),
                report.weightSummary!.endWeight.toStringAsFixed(1),
                WeeklyReportI18n.weightChange(
                  context,
                  report.weightSummary!.direction,
                  report.weightSummary!.change,
                ),
              ),
              Icons.monitor_weight_outlined,
            ),
            const SizedBox(height: 12),
          ],

          _buildMetricRow(
            context.l10n.report_share_metricAppetite,
            context.l10n.report_share_metricAppetiteValue(
              report.appetiteSummary.averageScore.toString(),
              WeeklyReportI18n.appetiteStabilityName(
                context,
                report.appetiteSummary.stability,
              ),
            ),
            Icons.restaurant_outlined,
          ),

          if (report.symptomOccurrences.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            Text(
              context.l10n.report_share_sectionSymptoms,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral700,
              ),
            ),
            const SizedBox(height: 8),

            ...report.symptomOccurrences.take(3).map((symptom) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  context.l10n.report_share_symptomItem(
                    WeeklyReportI18n.symptomTypeName(context, symptom.type),
                    symptom.daysOccurred,
                    WeeklyReportI18n.severitySummary(context, symptom.severityCounts),
                  ),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              );
            }),
          ],

          // 컨디션 추이
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          Text(
            context.l10n.report_share_sectionCondition,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral700,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: report.dailyConditions.map((condition) {
              return Column(
                children: [
                  Text(
                    condition.mood != null
                        ? WeeklyReportI18n.moodToEmoji(condition.mood!)
                        : '--',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    WeeklyReportI18n.dayOfWeekShort(context, condition.date),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.neutral500,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.neutral800,
          ),
        ),
      ],
    );
  }

  Widget _buildTextReportPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code,
                size: 16,
                color: AppColors.neutral400,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.report_share_textPreviewTitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _textReport ?? '',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white,
              fontFamily: 'monospace',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.copy, size: 20),
              label: Text(context.l10n.report_share_buttonCopy),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.neutral700,
                side: BorderSide(color: AppColors.neutral300),
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _copyToClipboard, // 복사 기능으로 대체 (share_plus 미사용)
              icon: const Icon(Icons.share, size: 20),
              label: Text(context.l10n.report_share_buttonShare),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard() {
    if (_textReport != null) {
      Clipboard.setData(ClipboardData(text: _textReport!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.report_share_copySuccess),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}.${date.day}';
  }
}
