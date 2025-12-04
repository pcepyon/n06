import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/application/providers.dart';
import 'package:n06/features/tracking/application/notifiers/medication_notifier.dart';
import 'package:n06/features/tracking/domain/entities/weight_log.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/authentication/application/notifiers/auth_notifier.dart';
import 'package:n06/features/record_management/presentation/widgets/record_list_card.dart';
import 'package:n06/core/presentation/widgets/record_type_icon.dart';
import 'package:n06/core/presentation/widgets/empty_state_widget.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_toast.dart';
import 'package:n06/features/daily_checkin/application/providers.dart';
import 'package:n06/features/daily_checkin/domain/entities/daily_checkin.dart';
import 'package:n06/features/daily_checkin/domain/entities/symptom_detail.dart';
import 'package:intl/intl.dart';
import 'package:n06/core/presentation/theme/app_colors.dart';
import 'package:n06/core/presentation/theme/app_typography.dart';
import 'package:n06/core/extensions/l10n_extension.dart';

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
          title: Text(
            context.l10n.records_screen_title,
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
                  child: TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textTertiary,
                    labelStyle: const TextStyle(
                      fontSize: 16, // Typography - base
                      fontWeight: FontWeight.w500, // Medium (500)
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2, // 2px
                      ),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: context.l10n.records_tab_weight),
                      Tab(text: context.l10n.records_tab_checkin),
                      Tab(text: context.l10n.records_tab_dose),
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
              _CheckinRecordsTab(),
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
      loading: () => _buildLoadingState(context),
      error: (err, stack) => Center(
        child: Text(
          context.l10n.records_error(err.toString()),
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFFEF4444), // Error
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Center(
            child: Text(
              context.l10n.records_loginRequired,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B), // Neutral-500
              ),
            ),
          );
        }

        return trackingState.when(
          loading: () => _buildLoadingState(context),
          error: (err, stack) => Center(
            child: Text(
              context.l10n.records_error(err.toString()),
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
              return EmptyStateWidget(
                icon: Icons.monitor_weight_outlined,
                title: context.l10n.records_weight_empty_title,
                description: context.l10n.records_weight_empty_description,
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
        context.l10n.records_weight_unit(record.weightKg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Change 3: 기본 정보 (lg, Semibold)
          Text(
            context.l10n.records_weight_unit(record.weightKg),
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
        GabiumToast.showSuccess(context, context.l10n.records_delete_success);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        GabiumToast.showError(
            context, context.l10n.records_delete_error);
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
        title: Text(
          context.l10n.records_delete_confirm_title,
          style: AppTypography.heading1,
        ),
        content: Text(
          context.l10n.records_delete_confirm_message,
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
            child: Text(
              context.l10n.common_button_cancel,
              style: const TextStyle(
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
            child: Text(
              context.l10n.common_button_delete,
              style: const TextStyle(
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

/// 체크인 기록 탭
class _CheckinRecordsTab extends ConsumerWidget {
  const _CheckinRecordsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final checkinsAsync = ref.watch(allCheckinsProvider);

    return authState.when(
      loading: () => _buildLoadingState(context),
      error: (err, stack) => Center(
        child: Text(
          context.l10n.records_error(err.toString()),
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.error,
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Center(
            child: Text(
              context.l10n.records_loginRequired,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          );
        }

        return checkinsAsync.when(
          loading: () => _buildLoadingState(context),
          error: (err, stack) => Center(
            child: Text(
              context.l10n.records_error(err.toString()),
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          data: (checkins) {
            if (checkins.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.check_circle_outline,
                title: context.l10n.records_checkin_empty_title,
                description: context.l10n.records_checkin_empty_description,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: checkins.length,
              itemBuilder: (context, index) {
                final checkin = checkins[index];
                return _CheckinRecordTile(checkin: checkin);
              },
            );
          },
        );
      },
    );
  }
}

/// 체크인 기록 항목
class _CheckinRecordTile extends ConsumerWidget {
  final DailyCheckin checkin;

  const _CheckinRecordTile({required this.checkin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(checkin.checkinDate);
    final summary = _buildSummary(context);
    final symptoms = _buildSymptomSummary(context);

    return RecordListCard(
      recordType: RecordType.checkin,
      onDelete: () => _showDeleteDialog(context, ref),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜
          Text(
            dateStr,
            style: AppTypography.heading3,
          ),
          const SizedBox(height: 8),
          // 컨디션 요약
          Text(
            summary,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          // 증상 정보 (있는 경우)
          if (symptoms.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              symptoms,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _buildSummary(BuildContext context) {
    final parts = <String>[];

    // 식사 상태
    switch (checkin.mealCondition) {
      case ConditionLevel.good:
        parts.add(context.l10n.records_checkin_summary_mealGood);
        break;
      case ConditionLevel.moderate:
        parts.add(context.l10n.records_checkin_summary_mealModerate);
        break;
      case ConditionLevel.difficult:
        parts.add(context.l10n.records_checkin_summary_mealDifficult);
        break;
    }

    // 에너지 수준
    switch (checkin.energyLevel) {
      case EnergyLevel.good:
        parts.add(context.l10n.records_checkin_summary_energyGood);
        break;
      case EnergyLevel.normal:
        parts.add(context.l10n.records_checkin_summary_energyNormal);
        break;
      case EnergyLevel.tired:
        parts.add(context.l10n.records_checkin_summary_energyTired);
        break;
    }

    return parts.join(' | ');
  }

  String _buildSymptomSummary(BuildContext context) {
    final symptoms = checkin.symptomDetails;
    if (symptoms == null || symptoms.isEmpty) return '';

    final symptomNames = symptoms.map((s) => _getSymptomName(context, s.type)).take(3).toList();
    final suffix = symptoms.length > 3 ? context.l10n.records_checkin_symptoms_more(symptoms.length - 3) : '';
    return context.l10n.records_checkin_symptoms(symptomNames.join(', ')) + suffix;
  }

  String _getSymptomName(BuildContext context, SymptomType type) {
    switch (type) {
      case SymptomType.nausea:
        return context.l10n.records_symptom_nausea;
      case SymptomType.vomiting:
        return context.l10n.records_symptom_vomiting;
      case SymptomType.lowAppetite:
        return context.l10n.records_symptom_lowAppetite;
      case SymptomType.earlySatiety:
        return context.l10n.records_symptom_earlySatiety;
      case SymptomType.heartburn:
        return context.l10n.records_symptom_heartburn;
      case SymptomType.abdominalPain:
        return context.l10n.records_symptom_abdominalPain;
      case SymptomType.bloating:
        return context.l10n.records_symptom_bloating;
      case SymptomType.constipation:
        return context.l10n.records_symptom_constipation;
      case SymptomType.diarrhea:
        return context.l10n.records_symptom_diarrhea;
      case SymptomType.fatigue:
        return context.l10n.records_symptom_fatigue;
      case SymptomType.dizziness:
        return context.l10n.records_symptom_dizziness;
      case SymptomType.coldSweat:
        return context.l10n.records_symptom_coldSweat;
      case SymptomType.swelling:
        return context.l10n.records_symptom_swelling;
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('yyyy년 MM월 dd일').format(checkin.checkinDate);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.records_checkin_delete_confirm_title,
                style: AppTypography.heading2,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.records_checkin_delete_confirm_message(dateStr),
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        context.l10n.common_button_cancel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _deleteCheckin(dialogContext, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        context.l10n.common_button_delete,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteCheckin(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(dailyCheckinRepositoryProvider);
      await repository.delete(checkin.id);

      // Provider 갱신
      ref.invalidate(allCheckinsProvider);

      if (context.mounted) {
        Navigator.pop(context);
        GabiumToast.showSuccess(context, context.l10n.records_checkin_delete_success);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        GabiumToast.showError(context, context.l10n.records_delete_error);
      }
    }
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
      loading: () => _buildLoadingState(context),
      error: (err, stack) => Center(
        child: Text(
          context.l10n.records_error(err.toString()),
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.error,
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Center(
            child: Text(
              context.l10n.records_loginRequired,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          );
        }

        return medicationState.when(
          loading: () => _buildLoadingState(context),
          error: (err, stack) => Center(
            child: Text(
              context.l10n.records_error(err.toString()),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
          data: (state) {
            final records = state.records;

            if (records.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.medical_services_outlined,
                title: context.l10n.records_dose_empty_title,
                description: context.l10n.records_dose_empty_description,
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
    final siteDisplay = record.injectionSite ?? context.l10n.records_dose_site_unspecified;

    return RecordListCard(
      recordType: RecordType.dose,
      onDelete: () => _showDeleteDialog(
        context,
        ref,
        '${context.l10n.records_dose_unit(record.actualDoseMg)} ($siteDisplay)',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기본 정보
          Text(
            context.l10n.records_dose_unit(record.actualDoseMg),
            style: AppTypography.heading3,
          ),
          const SizedBox(height: 4),
          // 보조 정보
          Text(
            context.l10n.records_dose_site(siteDisplay),
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
        GabiumToast.showSuccess(context, context.l10n.records_delete_success);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        GabiumToast.showError(
            context, context.l10n.records_delete_error);
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
        title: Text(
          context.l10n.records_delete_confirm_title,
          style: AppTypography.heading1,
        ),
        content: Text(
          context.l10n.records_delete_confirm_message,
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
            child: Text(
              context.l10n.common_button_cancel,
              style: const TextStyle(
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
            child: Text(
              context.l10n.common_button_delete,
              style: const TextStyle(
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
Widget _buildLoadingState(BuildContext context) {
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
          context.l10n.records_loading,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    ),
  );
}
