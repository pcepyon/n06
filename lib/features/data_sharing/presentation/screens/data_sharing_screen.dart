import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/data_sharing/application/notifiers/data_sharing_notifier.dart';
import 'package:n06/features/data_sharing/domain/repositories/date_range.dart';
import 'package:n06/features/data_sharing/presentation/widgets/data_sharing_period_selector.dart';
import 'package:n06/features/data_sharing/presentation/widgets/exit_confirmation_dialog.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          title: const Text(
            '기록 보여주기',
            style: AppTypography.heading2,
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, size: 24),
            color: AppColors.textSecondary,
            onPressed: () => _showExitDialog(context),
            tooltip: '공유 종료',
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: AppColors.border,
              height: 1,
            ),
          ),
        ),
        body: state.isLoading
            ? Center(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.education,
                    ),
                    strokeWidth: 2,
                  ),
                ),
              )
            : state.error != null
            ? _buildErrorState(state.error!)
            : _buildReportContent(state, context),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32), // xl
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 32, // lg
              color: AppColors.error,
            ),
            const SizedBox(height: 24), // lg
            const Text(
              '오류가 발생했습니다',
              style: AppTypography.heading3,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24), // lg
            GabiumButton(
              text: '다시 시도',
              onPressed: () {
                final userId = ref.read(authNotifierProvider).value?.id;
                if (userId != null) {
                  ref
                      .read(dataSharingNotifierProvider.notifier)
                      .enterSharingMode(userId, _selectedPeriod);
                }
              },
              variant: GabiumButtonVariant.primary,
              size: GabiumButtonSize.medium,
            ),
          ],
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(32), // xl
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 32, // lg
                color: AppColors.borderDark,
              ),
              const SizedBox(height: 24), // lg
              const Text(
                '선택된 기간에 기록이 없습니다',
                style: AppTypography.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '다른 기간을 선택하거나 기록을 추가해보세요',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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

            // Exit Sharing Mode Button
            SizedBox(
              width: double.infinity,
              child: GabiumButton(
                text: '공유 종료',
                onPressed: () => _showExitDialog(context),
                variant: GabiumButtonVariant.secondary,
                size: GabiumButtonSize.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(DataSharingState state) {
    return DataSharingPeriodSelector(
      selectedPeriod: _selectedPeriod,
      onPeriodChanged: (period) {
        setState(() => _selectedPeriod = period);
        final userId = ref.read(authNotifierProvider).value?.id;
        if (userId != null) {
          ref
              .read(dataSharingNotifierProvider.notifier)
              .changePeriod(userId, period);
        }
      },
      label: '표시 기간',
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16), // lg spacing
      child: Text(
        title,
        style: AppTypography.heading3,
      ),
    );
  }

  Widget _buildDoseRecordsSection(dynamic report) {
    final records = report.getDoseRecordsSorted();
    return Column(
      children: records.map<Widget>((record) {
        return Card(
          color: AppColors.historyBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // md
            side: const BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
          elevation: 2, // sm shadow
          margin: const EdgeInsets.only(bottom: 12), // md
          child: Padding(
            padding: const EdgeInsets.all(16), // md
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.education,
                    borderRadius: BorderRadius.circular(8), // sm
                  ),
                  child: const Icon(Icons.medical_services, color: AppColors.surface, size: 20),
                ),
                const SizedBox(width: 16), // md
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${record.actualDoseMg} mg',
                        style: AppTypography.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${record.administeredAt.toLocal().toString().split('.')[0]} | '
                        '${record.injectionSite ?? '부위 미지정'}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdherenceRateSection(dynamic report) {
    final rate = report.calculateAdherenceRate();
    return Card(
      color: AppColors.educationBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // md
        side: const BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      elevation: 2, // sm shadow
      child: Padding(
        padding: const EdgeInsets.all(16), // md
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '투여 순응도',
              style: AppTypography.heading3,
            ),
            const SizedBox(height: 16), // md
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${rate.toStringAsFixed(1)}%',
                  style: AppTypography.heading1,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: LinearProgressIndicator(
                      value: rate / 100,
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.education,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInjectionSiteSection(dynamic report) {
    final sites = report.getInjectionSiteHistory();
    return Column(
      children: sites.entries.map<Widget>((entry) {
        return ListTile(
          title: Text(entry.key),
          trailing: Text('${entry.value}회', style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      }).toList(),
    );
  }

  Widget _buildWeightLogsSection(dynamic report) {
    final logs = report.getWeightLogsSorted();
    return Column(
      children: logs.map<Widget>((log) {
        return Card(
          color: AppColors.historyBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // md
            side: const BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
          elevation: 2, // sm shadow
          margin: const EdgeInsets.only(bottom: 12), // md
          child: Padding(
            padding: const EdgeInsets.all(16), // md
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.history,
                    borderRadius: BorderRadius.circular(8), // sm
                  ),
                  child: const Icon(Icons.scale, color: AppColors.surface, size: 20),
                ),
                const SizedBox(width: 16), // md
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${log.weightKg} kg',
                        style: AppTypography.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        log.logDate.toString().split(' ')[0],
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExitConfirmationDialog(
        onCancel: () => Navigator.of(context).pop(),
        onConfirm: () {
          ref.read(dataSharingNotifierProvider.notifier).exitSharingMode();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
