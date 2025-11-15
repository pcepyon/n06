import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/coping_guide.dart';
import '../../domain/entities/coping_guide_state.dart';
import '../../domain/entities/guide_feedback.dart';
import '../providers.dart';

part 'coping_guide_notifier.g.dart';

/// 부작용 대처 가이드 조회 및 관리 Notifier
@riverpod
class CopingGuideNotifier extends _$CopingGuideNotifier {
  @override
  Future<CopingGuideState> build() async {
    final defaultGuide = CopingGuide(
      symptomName: '일반',
      shortGuide: '전문가와 상담하여 구체적인 조언을 받으시기 바랍니다.',
    );
    return CopingGuideState(guide: defaultGuide);
  }

  /// 증상명으로 가이드 조회
  Future<void> getGuideBySymptom(String symptomName) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(copingGuideRepositoryProvider);
      final guide = await repository.getGuideBySymptom(symptomName);

      if (guide == null) {
        // 기본 가이드 반환
        return CopingGuideState(
          guide: CopingGuide(
            symptomName: '일반',
            shortGuide: '전문가와 상담하여 구체적인 조언을 받으시기 바랍니다.',
          ),
        );
      }

      return CopingGuideState(guide: guide);
    });
  }

  /// 심각도 확인 및 가이드 조회
  /// [symptomName]: 증상명
  /// [severity]: 심각도 (1-10)
  /// [isPersistent24h]: 24시간 이상 지속 여부
  Future<void> checkSeverityAndGuide(
    String symptomName,
    int severity,
    bool isPersistent24h,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(copingGuideRepositoryProvider);
      final guide = await repository.getGuideBySymptom(symptomName) ??
          CopingGuide(
            symptomName: '일반',
            shortGuide: '전문가와 상담하여 구체적인 조언을 받으시기 바랍니다.',
          );

      // 심각도 7-10점 AND 24시간 이상 지속 시 경고 활성화
      final showWarning = severity >= 7 && isPersistent24h;

      return CopingGuideState(
        guide: guide,
        showSeverityWarning: showWarning,
      );
    });
  }

  /// 피드백 제출
  Future<void> submitFeedback(String symptomName, {required bool helpful}) async {
    final repository = ref.read(feedbackRepositoryProvider);
    final feedback = GuideFeedback(
      symptomName: symptomName,
      helpful: helpful,
      timestamp: DateTime.now(),
    );
    await repository.saveFeedback(feedback);
  }
}

/// 모든 가이드 목록 조회 Notifier
@riverpod
class CopingGuideListNotifier extends _$CopingGuideListNotifier {
  @override
  Future<List<CopingGuide>> build() async {
    return [];
  }

  /// 모든 가이드 로드
  Future<void> loadAllGuides() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(copingGuideRepositoryProvider);
      return repository.getAllGuides();
    });
  }
}

/// Aliases for backwards compatibility
const copingGuideNotifierProvider = copingGuideProvider;
const copingGuideListNotifierProvider = copingGuideListProvider;
