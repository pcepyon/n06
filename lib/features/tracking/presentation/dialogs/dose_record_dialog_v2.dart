import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n06/features/tracking/domain/entities/dose_schedule.dart';
import 'package:n06/features/tracking/domain/entities/dose_record.dart';
import 'package:n06/features/tracking/application/notifiers/medication_notifier.dart';
import 'package:n06/features/tracking/presentation/widgets/injection_site_selector_v2.dart';
import 'package:n06/features/authentication/presentation/widgets/gabium_button.dart';

class DoseRecordDialogV2 extends ConsumerStatefulWidget {
  final DoseSchedule schedule;
  final List<DoseRecord> recentRecords;

  const DoseRecordDialogV2({
    required this.schedule,
    required this.recentRecords,
    super.key,
  });

  @override
  ConsumerState<DoseRecordDialogV2> createState() => _DoseRecordDialogV2State();
}

class _DoseRecordDialogV2State extends ConsumerState<DoseRecordDialogV2> {
  String? selectedSite;
  final noteController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        '투여 기록',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.schedule.scheduledDoseMg} mg를 투여했습니다.',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 16),

            InjectionSiteSelectorV2(
              onSiteSelected: (site) {
                setState(() {
                  selectedSite = site;
                });
              },
              recentRecords: widget.recentRecords,
            ),

            const SizedBox(height: 16),
            const Text(
              '메모 (선택사항)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                hintText: '메모를 입력하세요',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFCBD5E1),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF4ADE80),
                    width: 2,
                  ),
                ),
              ),
              maxLines: 3,
              maxLength: 100,
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.all(24),
      actions: [
        Expanded(
          child: GabiumButton(
            text: '취소',
            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
            variant: GabiumButtonVariant.secondary,
            size: GabiumButtonSize.medium,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GabiumButton(
            text: '저장',
            onPressed: isLoading || selectedSite == null
                ? null
                : _saveDoseRecord,
            variant: GabiumButtonVariant.primary,
            size: GabiumButtonSize.medium,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }

  // ✅ CORRECT: Presentation Layer에서 네비게이션/스낵바 처리
  Future<void> _saveDoseRecord() async {
    if (selectedSite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주사 부위를 선택해주세요')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final medicationNotifier = ref.read(medicationNotifierProvider.notifier);
      final medicationState = ref.read(medicationNotifierProvider);

      final state = medicationState.asData?.value;
      if (state?.activePlan == null) {
        throw Exception('활성 투여 계획이 없습니다');
      }

      final doseRecord = DoseRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        doseScheduleId: widget.schedule.id,
        dosagePlanId: state!.activePlan!.id,
        administeredAt: DateTime.now(),
        actualDoseMg: widget.schedule.scheduledDoseMg,
        injectionSite: selectedSite,
        note: noteController.text.isEmpty ? null : noteController.text,
      );

      // ✅ Application Layer: 저장만 수행
      await medicationNotifier.recordDose(doseRecord);

      // ✅ Presentation Layer: 저장 성공 후 네비게이션/스낵바
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('투여 기록이 저장되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
