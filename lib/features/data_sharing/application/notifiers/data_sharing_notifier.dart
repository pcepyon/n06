import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/data_sharing/domain/entities/shared_data_report.dart';
import 'package:n06/features/data_sharing/domain/repositories/date_range.dart';
import 'package:n06/features/data_sharing/domain/repositories/shared_data_repository.dart';
import 'package:n06/features/data_sharing/application/providers.dart';

part 'data_sharing_notifier.g.dart';

class DataSharingState {
  final bool isActive;
  final DateRange? selectedPeriod;
  final SharedDataReport? report;
  final String? error;
  final bool isLoading;

  DataSharingState({
    this.isActive = false,
    this.selectedPeriod,
    this.report,
    this.error,
    this.isLoading = false,
  });

  DataSharingState copyWith({
    bool? isActive,
    DateRange? selectedPeriod,
    SharedDataReport? report,
    String? error,
    bool? isLoading,
  }) {
    return DataSharingState(
      isActive: isActive ?? this.isActive,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      report: report ?? this.report,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class DataSharingNotifier extends _$DataSharingNotifier {
  @override
  DataSharingState build() {
    return DataSharingState(isActive: false);
  }

  Future<void> enterSharingMode(String userId, DateRange period) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final repository = ref.read(sharedDataRepositoryProvider);
      final report = await repository.getReportData(userId, period);

      state = state.copyWith(
        isActive: true,
        selectedPeriod: period,
        report: report,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> changePeriod(String userId, DateRange period) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final repository = ref.read(sharedDataRepositoryProvider);
      final report = await repository.getReportData(userId, period);

      state = state.copyWith(
        selectedPeriod: period,
        report: report,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  void exitSharingMode() {
    state = DataSharingState(isActive: false);
  }
}
