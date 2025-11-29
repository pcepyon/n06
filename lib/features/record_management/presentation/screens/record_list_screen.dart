import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/application/notifiers/medication_notifier.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/symptom_log.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/record_management/presentation/widgets/record_list_card.dart';
import 'package:n06/core/presentation/widgets/record_type_icon.dart';
import 'package:n06/core/presentation/widgets/empty_state_widget.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_toast.dart';
import 'package:intl/intl.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';

/// 과거 기록 목록 화면 (체중/증상/투여)
/// Gabium Design System 기반 UI 개선 완료
class RecordListScreen extends ConsumerWidget {
  const RecordListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        // Change 1: AppBar 색상 및 스타일 적용
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          title: const Text(
            '기록 관리',
            style: AppTypography.heading2,
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(49),
            child: Column(
              children: [
                // Change 1: TabBar 색상 및 스타일 적용
                Container(
                  color: Colors.transparent,
                  child: const TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textTertiary,
                    labelStyle: TextStyle(
                      fontSize: 16, // Typography - base
                      fontWeight: FontWeight.w500, // Medium (500)
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2, // 2px
                      ),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: '체중'),
                      Tab(text: '증상'),
                      Tab(text: '투여'),
                    ],
                  ),
                ),
                // 하단 테두리
                Container(
                  height: 1,
                  color: AppColors.border,
                ),
              ],
            ),
          ),
        ),
        // TabBarView 배경색
        body: Container(
          color: AppColors.background,
          child: const TabBarView(
            children: [
              _WeightRecordsTab(),
              _SymptomRecordsTab(),
              _DoseRecordsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 체중 기록 탭
class _WeightRecordsTab extends ConsumerWidget {
  const _WeightRecordsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final trackingState = ref.watch(trackingProvider);

    return authState.when(
      // Change 7: 로딩 상태
      loading: () => _buildLoadingState(),
      error: (err, stack) => Center(
        child: Text(
          '오류: $err',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFEF4444), // Error
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return const Center(
            child: Text(
              '로그인이 필요합니다',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B), // Neutral-500
              ),
            ),
          );
        }

        return trackingState.when(
          loading: () => _buildLoadingState(),
          error: (err, stack) => Center(
            child: Text(
              '오류: $err',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFEF4444), // Error
              ),
            ),
          ),
          data: (state) {
            final weights = state.weights;

            // Change 5: 빈 상태
            if (weights.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.monitor_weight_outlined,
                title: '체중 기록이 없습니다',
                description: '아직 체중 기록이 없습니다.\n첫 번째 기록을 추가해보세요.',
              );
            }

            // 최신순으로 정렬
            final sortedWeights = List<WeightLog>.from(weights)
              ..sort((a, b) => b.logDate.compareTo(a.logDate));

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16), // md
              itemCount: sortedWeights.length,
              itemBuilder: (context, index) {
                final record = sortedWeights[index];
                return _WeightRecordTile(
                  record: record,
                  userId: user.id,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// 체중 기록 항목
class _WeightRecordTile extends ConsumerWidget {
  final WeightLog record;
  final String userId;

  const _WeightRecordTile({
    required this.record,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('yyyy년 MM월 dd일').format(record.logDate);
    final timeStr = DateFormat('HH:mm').format(record.createdAt);

    // Change 2: RecordListCard 사용
    return RecordListCard(
      recordType: RecordType.weight,
      onDelete: () => _showDeleteDialog(
        context,
        ref,
        '${record.weightKg} kg',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Change 3: 기본 정보 (lg, Semibold)
          Text(
            '${record.weightKg} kg',
            style: AppTypography.heading3,
          ),
          const SizedBox(height: 4), // xs
          // Change 3: 메타데이터 (sm, Regular)
          Text(
            '$dateStr $timeStr',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWeight(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(trackingProvider.notifier).deleteWeightLog(record.id);

      if (context.mounted) {
        Navigator.pop(context); // 다이얼로그 닫기
        // Change 6: GabiumToast 사용
        GabiumToast.showSuccess(context, '기록이 삭제되었습니다');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        GabiumToast.showError(
            context, '기록 삭제 중 오류가 발생했습니다. 다시 시도해주세요.');
      }
    }
  }

  // Change 6: 개선된 삭제 확인 다이얼로그
  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String info,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // lg
        ),
        elevation: 4, // xl shadow approximation
        title: const Text(
          '기록을 삭제하시겠습니까?',
          style: AppTypography.heading1,
        ),
        content: Text(
          '삭제된 기록은 복구할 수 없습니다.',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        actions: [
          // 취소 버튼 (Secondary 스타일)
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // sm
                side: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            child: const Text(
              '취소',
              style: TextStyle(
                fontSize: 16, // base
                fontWeight: FontWeight.w600, // Semibold
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 삭제 버튼 (Danger 스타일)
          ElevatedButton(
            onPressed: () => _deleteWeight(dialogContext, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // sm
              ),
              elevation: 0,
            ),
            child: const Text(
              '삭제',
              style: TextStyle(
                fontSize: 16, // base
                fontWeight: FontWeight.w600, // Semibold
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 증상 기록 탭
class _SymptomRecordsTab extends ConsumerWidget {
  const _SymptomRecordsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final trackingState = ref.watch(trackingProvider);

    return authState.when(
      loading: () => _buildLoadingState(),
      error: (err, stack) => Center(
        child: Text(
          '오류: $err',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.error,
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Center(
            child: Text(
              '로그인이 필요합니다',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          );
        }

        return trackingState.when(
          loading: () => _buildLoadingState(),
          error: (err, stack) => Center(
            child: Text(
              '오류: $err',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
          data: (state) {
            final symptoms = state.symptoms;

            if (symptoms.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.warning_amber_outlined,
                title: '증상 기록이 없습니다',
                description: '아직 증상 기록이 없습니다.\n첫 번째 기록을 추가해보세요.',
              );
            }

            final sortedSymptoms = List<SymptomLog>.from(symptoms)
              ..sort((a, b) => b.logDate.compareTo(a.logDate));

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: sortedSymptoms.length,
              itemBuilder: (context, index) {
                final record = sortedSymptoms[index];
                return _SymptomRecordTile(
                  record: record,
                  userId: user.id,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// 증상 기록 항목
class _SymptomRecordTile extends ConsumerWidget {
  final SymptomLog record;
  final String userId;

  const _SymptomRecordTile({
    required this.record,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('yyyy년 MM월 dd일').format(record.logDate);
    final timeStr =
        DateFormat('HH:mm').format(record.createdAt ?? DateTime.now());

    return RecordListCard(
      recordType: RecordType.symptom,
      onDelete: () => _showDeleteDialog(
        context,
        ref,
        '${record.symptomName} (심각도: ${record.severity})',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기본 정보
          Text(
            record.symptomName,
            style: AppTypography.heading3,
          ),
          const SizedBox(height: 4),
          // 보조 정보
          Text(
            '심각도: ${record.severity}/10',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          // 메타데이터
          Text(
            '$dateStr $timeStr',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSymptom(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(trackingProvider.notifier).deleteSymptomLog(record.id);

      if (context.mounted) {
        Navigator.pop(context);
        GabiumToast.showSuccess(context, '기록이 삭제되었습니다');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        GabiumToast.showError(
            context, '기록 삭제 중 오류가 발생했습니다. 다시 시도해주세요.');
      }
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String info,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        title: const Text(
          '기록을 삭제하시겠습니까?',
          style: AppTypography.heading1,
        ),
        content: Text(
          '삭제된 기록은 복구할 수 없습니다.',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            child: const Text(
              '취소',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _deleteSymptom(dialogContext, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              '삭제',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 투여 기록 탭
class _DoseRecordsTab extends ConsumerWidget {
  const _DoseRecordsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final medicationState = ref.watch(medicationNotifierProvider);

    return authState.when(
      loading: () => _buildLoadingState(),
      error: (err, stack) => Center(
        child: Text(
          '오류: $err',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.error,
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Center(
            child: Text(
              '로그인이 필요합니다',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          );
        }

        return medicationState.when(
          loading: () => _buildLoadingState(),
          error: (err, stack) => Center(
            child: Text(
              '오류: $err',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
          data: (state) {
            final records = state.records;

            if (records.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.medical_services_outlined,
                title: '투여 기록이 없습니다',
                description: '아직 투여 기록이 없습니다.\n첫 번째 기록을 추가해보세요.',
              );
            }

            final sortedRecords = List<DoseRecord>.from(records)
              ..sort((a, b) => b.administeredAt.compareTo(a.administeredAt));

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: sortedRecords.length,
              itemBuilder: (context, index) {
                final record = sortedRecords[index];
                return _DoseRecordTile(
                  record: record,
                  userId: user.id,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// 투여 기록 항목
class _DoseRecordTile extends ConsumerWidget {
  final DoseRecord record;
  final String userId;

  const _DoseRecordTile({
    required this.record,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr =
        DateFormat('yyyy년 MM월 dd일 HH:mm').format(record.administeredAt);
    final siteDisplay = record.injectionSite ?? '미지정';

    return RecordListCard(
      recordType: RecordType.dose,
      onDelete: () => _showDeleteDialog(
        context,
        ref,
        '${record.actualDoseMg} mg ($siteDisplay)',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기본 정보
          Text(
            '${record.actualDoseMg} mg',
            style: AppTypography.heading3,
          ),
          const SizedBox(height: 4),
          // 보조 정보
          Text(
            '부위: $siteDisplay',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          // 메타데이터
          Text(
            dateStr,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDose(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(doseRecordEditNotifierProvider.notifier).deleteDoseRecord(
            recordId: record.id,
            userId: userId,
          );

      if (context.mounted) {
        Navigator.pop(context);
        GabiumToast.showSuccess(context, '기록이 삭제되었습니다');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        GabiumToast.showError(
            context, '기록 삭제 중 오류가 발생했습니다. 다시 시도해주세요.');
      }
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String info,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        title: const Text(
          '기록을 삭제하시겠습니까?',
          style: AppTypography.heading1,
        ),
        content: Text(
          '삭제된 기록은 복구할 수 없습니다.',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            child: const Text(
              '취소',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _deleteDose(dialogContext, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              '삭제',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Change 7: 로딩 상태 위젯
Widget _buildLoadingState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.primary,
          ),
          strokeWidth: 3,
        ),
        const SizedBox(height: 16), // md
        Text(
          '기록을 불러오는 중...',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    ),
  );
}
