import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/data_sharing/application/notifiers/data_sharing_notifier.dart';
import 'package:n06/features/data_sharing/application/providers.dart';
import 'package:n06/features/data_sharing/domain/repositories/date_range.dart';

class DataSharingScreen extends ConsumerStatefulWidget {
  final String? userId;

  const DataSharingScreen({
    Key? key,
    this.userId,
  }) : super(key: key);

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
      final userId = widget.userId;
      if (userId != null) {
        ref.read(dataSharingNotifierProvider.notifier).enterSharingMode(
              userId,
              _selectedPeriod,
            );
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
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('오류가 발생했습니다: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(dataSharingNotifierProvider.notifier).enterSharingMode(
                    widget.userId,
                    _selectedPeriod,
                  );
            },
            child: const Text('다시 시도'),
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
            const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('선택된 기간에 기록이 없습니다.'),
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
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(dataSharingNotifierProvider.notifier).exitSharingMode();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.exit_to_app),
                label: const Text('공유 종료'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
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
        const Text(
          '표시 기간',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: DateRange.values.map((period) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(period.label, textAlign: TextAlign.center),
                  selected: _selectedPeriod == period,
                  onSelected: (selected) {
                    setState(() => _selectedPeriod = period);
                    if (selected) {
                      ref.read(dataSharingNotifierProvider.notifier).changePeriod(
                            widget.userId,
                            period,
                          );
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
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildDoseRecordsSection(dynamic report) {
    final records = report.getDoseRecordsSorted();
    return Column(
      children: records.map((record) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.medical_services),
            title: Text('${record.actualDoseMg} mg'),
            subtitle: Text(
              '${record.administeredAt.toLocal().toString().split('.')[0]} | ${record.injectionSite ?? '부위 미지정'}',
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdherenceRateSection(dynamic report) {
    final rate = report.calculateAdherenceRate();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '투여 순응도',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${rate.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: LinearProgressIndicator(
                      value: rate / 100,
                      minHeight: 8,
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
      children: sites.entries.map((entry) {
        return ListTile(
          title: Text(entry.key),
          trailing: Text('${entry.value}회',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      }).toList(),
    );
  }

  Widget _buildWeightLogsSection(dynamic report) {
    final logs = report.getWeightLogsSorted();
    return Column(
      children: logs.map((log) {
        return ListTile(
          leading: const Icon(Icons.scale),
          title: Text('${log.weightKg} kg'),
          subtitle: Text(log.logDate.toString().split(' ')[0]),
        );
      }).toList(),
    );
  }

  Widget _buildSymptomLogsSection(dynamic report) {
    final logs = report.getSymptomLogsSorted();
    return Column(
      children: logs.map((log) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.warning),
            title: Text(log.symptomName),
            subtitle: Text('심각도: ${log.severity}/10'),
            trailing: Text(log.logDate.toString().split(' ')[0]),
          ),
        );
      }).toList(),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공유 종료'),
        content: const Text('공유를 종료하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(dataSharingNotifierProvider.notifier).exitSharingMode();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('종료'),
          ),
        ],
      ),
    );
  }
}
