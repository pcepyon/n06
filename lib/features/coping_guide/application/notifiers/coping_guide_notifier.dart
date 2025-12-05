import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/coping_guide.dart';
import '../../domain/entities/coping_guide_state.dart';
import '../../domain/entities/default_guide_message_type.dart';
import '../../domain/entities/guide_feedback.dart';
import '../providers.dart';

part 'coping_guide_notifier.g.dart';

/// 부작용 대처 가이드 조회 및 관리 Notifier
@riverpod
class CopingGuideNotifier extends _$CopingGuideNotifier {
  // ✅ 의존성을 late final 필드로 선언
  late final _repository = ref.read(copingGuideRepositoryProvider);
  late final _feedbackRepository = ref.read(feedbackRepositoryProvider);

  @override
  Future<CopingGuideState> build() async {
    final defaultGuide = _createDefaultGuide();
    return CopingGuideState(guide: defaultGuide);
  }

  /// 기본 가이드 생성 (마커 문자열 사용)
  CopingGuide _createDefaultGuide() {
    return const CopingGuide(
      symptomName: DefaultGuideMessageType.defaultSymptomName,
      shortGuide: DefaultGuideMessageType.defaultShortGuide,
      reassuranceMessage: DefaultGuideMessageType.defaultReassuranceMessage,
      immediateAction: DefaultGuideMessageType.defaultImmediateAction,
    );
  }

  /// 증상명으로 가이드 조회
  Future<void> getGuideBySymptom(String symptomName) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final guide = await _repository.getGuideBySymptom(symptomName);

      if (guide == null) {
        // 기본 가이드 반환
        return CopingGuideState(guide: _createDefaultGuide());
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
      final guide =
          await _repository.getGuideBySymptom(symptomName) ?? _createDefaultGuide();

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
    final feedback = GuideFeedback(
      symptomName: symptomName,
      helpful: helpful,
      timestamp: DateTime.now(),
    );
    await _feedbackRepository.saveFeedback(feedback);
  }
}

/// 모든 가이드 목록 조회 Notifier
@riverpod
class CopingGuideListNotifier extends _$CopingGuideListNotifier {
  // ✅ 의존성을 late final 필드로 선언
  late final _repository = ref.read(copingGuideRepositoryProvider);

  @override
  Future<List<CopingGuide>> build() async {
    return [];
  }

  /// 모든 가이드 로드
  Future<void> loadAllGuides() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.getAllGuides();
    });
  }
}

/// Aliases for backwards compatibility
const copingGuideNotifierProvider = copingGuideProvider;
const copingGuideListNotifierProvider = copingGuideListProvider;
