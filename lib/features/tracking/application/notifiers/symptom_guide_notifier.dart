import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/coping_guide/domain/entities/coping_guide.dart';
import 'package:n06/features/coping_guide/application/providers.dart';

part 'symptom_guide_notifier.g.dart';

/// 증상별 가이드 로딩 Notifier
///
/// Phase 1: 안심 퍼스트 가이드 리뉴얼
/// - 증상 선택 시 즉시 가이드 데이터 로딩
/// - 캐싱을 통한 빠른 재로딩
@riverpod
class SymptomGuideNotifier extends _$SymptomGuideNotifier {
  @override
  Future<CopingGuide?> build(String symptomName) async {
    // 증상명으로 가이드 조회
    final repository = ref.read(copingGuideRepositoryProvider);
    return await repository.getGuideBySymptom(symptomName);
  }

  /// 가이드 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(copingGuideRepositoryProvider);
      return await repository.getGuideBySymptom(symptomName);
    });
  }
}
