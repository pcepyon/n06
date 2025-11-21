import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/core/theme/app_colors.dart';
import 'package:n06/core/theme/app_text_styles.dart';
import 'package:n06/core/widgets/app_button.dart';
import 'package:n06/core/widgets/app_card.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/data_sharing/application/notifiers/data_sharing_notifier.dart';
import 'package:n06/features/data_sharing/domain/repositories/date_range.dart';

class DataSharingScreen extends ConsumerStatefulWidget {
  final String? userId;

  const DataSharingScreen({super.key, this.userId});

  @override
  ConsumerState<DataSharingScreen> createState() => _DataSharingScreenState();
}

class _DataSharingScreenState extends ConsumerState<DataSharingScreen> {
  DateRange _selectedPeriod = DateRange.lastMonth;

  @override
  void initState() {
    super.initState();
    // Enter sharing mode on screen initialization
    Future.microtask(() {
      // Get userId from authNotifierProvider (standard pattern)
      final userId = ref.read(authNotifierProvider).value?.id;

      if (userId != null) {
        ref.read(dataSharingNotifierProvider.notifier).enterSharingMode(userId, _selectedPeriod);
      } else {
        // Explicit error handling when userId is not available
        ref.read(dataSharingNotifierProvider.notifier).setError('사용자 인증 정보를 찾을 수 없습니다.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dataSharingNotifierProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _showExitDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('기록 보여주기'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitDialog(context),
          ),
          automaticallyImplyLeading: false,
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
            ? _buildErrorState(state.error!)
            : _buildReportContent(state, context),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('오류가 발생했습니다: $error', style: AppTextStyles.body1.copyWith(color: AppColors.error)),
          const SizedBox(height: 16),
          AppButton(
            text: '다시 시도',
            onPressed: () {
              final userId = ref.read(authNotifierProvider).value?.id;
              if (userId != null) {
                ref
                    .read(dataSharingNotifierProvider.notifier)
                    .enterSharingMode(userId, _selectedPeriod);
              }
            },
            type: AppButtonType.secondary,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(DataSharingState state, BuildContext context) {
    final report = state.report;
    if (report == null) {
      return const Center(child: Text('데이터를 불러올 수 없습니다.'));
    }

    if (!report.hasData()) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: AppColors.gray),
            const SizedBox(height: 16),
            Text('선택된 기간에 기록이 없습니다.', style: AppTextStyles.body1.copyWith(color: AppColors.gray)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            _buildPeriodSelector(state),
            const SizedBox(height: 24),

            // Dose Records Section
            if (report.doseRecords.isNotEmpty) ...[
              _buildSectionTitle('투여 기록'),
              _buildDoseRecordsSection(report),
              const SizedBox(height: 24),
            ],

            // Adherence Rate
            _buildAdherenceRateSection(report),
            const SizedBox(height: 24),

            // Injection Site History
            if (report.getInjectionSiteHistory().isNotEmpty) ...[
              _buildSectionTitle('주사 부위 순환 이력'),
              _buildInjectionSiteSection(report),
              const SizedBox(height: 24),
            ],

            // Weight Logs Section
            if (report.weightLogs.isNotEmpty) ...[
              _buildSectionTitle('체중 변화'),
              _buildWeightLogsSection(report),
              const SizedBox(height: 24),
            ],

            // Symptom Logs Section
            if (report.symptomLogs.isNotEmpty) ...[
              _buildSectionTitle('부작용 기록'),
              _buildSymptomLogsSection(report),
              const SizedBox(height: 24),
            ],

            // Exit Sharing Mode Button
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: '공유 종료',
                onPressed: () {
                  ref.read(dataSharingNotifierProvider.notifier).exitSharingMode();
                  Navigator.of(context).pop();
                },
                icon: Icons.exit_to_app,
                type: AppButtonType.primary,
                backgroundColor: AppColors.warning,
                borderColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(DataSharingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('표시 기간', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Row(
          children: DateRange.values.map<Widget>((period) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(
                    period.label,
                    textAlign: TextAlign.center,
                    style: _selectedPeriod == period
                        ? AppTextStyles.caption.copyWith(color: Colors.white)
                        : AppTextStyles.caption,
                  ),
                  selected: _selectedPeriod == period,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.lightGray,
                  onSelected: (selected) {
                    setState(() => _selectedPeriod = period);
                    if (selected) {
                      final userId = ref.read(authNotifierProvider).value?.id;
                      if (userId != null) {
                        ref
                            .read(dataSharingNotifierProvider.notifier)
                            .changePeriod(userId, period);
                      }
                    }
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTextStyles.h3),
    );
  }

  Widget _buildDoseRecordsSection(dynamic report) {
    final records = report.getDoseRecordsSorted();
    return Column(
      children: records.map<Widget>((record) {
        return AppCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.medical_services, color: AppColors.primary),
            title: Text('${record.actualDoseMg} mg', style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${record.administeredAt.toLocal().toString().split('.')[0]} | ${record.injectionSite ?? '부위 미지정'}',
              style: AppTextStyles.caption,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdherenceRateSection(dynamic report) {
    final rate = report.calculateAdherenceRate();
    final rate = report.calculateAdherenceRate();
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('투여 순응도', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${rate.toStringAsFixed(1)}%',
                style: AppTextStyles.h1.copyWith(color: AppColors.primary),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: rate / 100,
                      minHeight: 8,
                      backgroundColor: AppColors.lightGray,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInjectionSiteSection(dynamic report) {
    final sites = report.getInjectionSiteHistory();
    return Column(
      children: sites.entries.map<Widget>((entry) {
        return AppCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.zero,
          child: ListTile(
            title: Text(entry.key, style: AppTextStyles.body2),
            trailing: Text('${entry.value}회', style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeightLogsSection(dynamic report) {
    final logs = report.getWeightLogsSorted();
    return Column(
      children: logs.map<Widget>((log) {
        return AppCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.scale, color: AppColors.primary),
            title: Text('${log.weightKg} kg', style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text(log.logDate.toString().split(' ')[0], style: AppTextStyles.caption),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSymptomLogsSection(dynamic report) {
    final logs = report.getSymptomLogsSorted();
    return Column(
      children: logs.map<Widget>((log) {
        return AppCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.warning, color: AppColors.warning),
            title: Text(log.symptomName, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text('심각도: ${log.severity}/10', style: AppTextStyles.caption),
            trailing: Text(log.logDate.toString().split(' ')[0], style: AppTextStyles.caption),
          ),
        );
      }).toList(),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('공유 종료', style: AppTextStyles.h3),
        content: Text('공유를 종료하시겠습니까?', style: AppTextStyles.body1),
        actions: [
          AppButton(
            text: '취소',
            onPressed: () => Navigator.of(context).pop(),
            type: AppButtonType.ghost,
            isFullWidth: false,
          ),
          AppButton(
            text: '종료',
            onPressed: () {
              ref.read(dataSharingNotifierProvider.notifier).exitSharingMode();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            type: AppButtonType.primary,
            isFullWidth: false,
            backgroundColor: AppColors.warning,
            borderColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}
