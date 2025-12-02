import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:n06/features/daily_checkin/domain/entities/daily_checkin.dart';
import 'package:n06/features/daily_checkin/domain/entities/symptom_detail.dart';
import 'package:n06/features/daily_checkin/domain/entities/red_flag_detection.dart';
import 'package:n06/features/coping_guide/domain/repositories/coping_guide_repository.dart';
import 'package:n06/features/coping_guide/application/providers.dart';

part 'checkin_feedback_notifier.g.dart';

/// 피드백 톤
enum FeedbackTone {
  positive, // 긍정 (잘한 경우)
  supportive, // 지지 (힘든 경우)
  cautious, // 주의 (Red Flag 감지)
}

/// 체크인 피드백
class CheckinFeedback {
  final String message; // 메인 메시지
  final String? stat; // 통계 (선택)
  final String? action; // 즉각 행동 제안 (선택)
  final FeedbackTone tone; // 톤

  const CheckinFeedback({
    required this.message,
    this.stat,
    this.action,
    required this.tone,
  });
}

@riverpod
class CheckinFeedbackNotifier extends _$CheckinFeedbackNotifier {
  CopingGuideRepository get _copingGuideRepository =>
      ref.read(copingGuideRepositoryProvider);

  @override
  Future<void> build() async {
    // 상태 없음 (stateless service)
  }

  /// 긍정 답변용 피드백
  CheckinFeedback getPositiveFeedback(int questionIndex, String answer) {
    final feedbackMap = _positiveFeedbackMap[questionIndex];
    if (feedbackMap != null && feedbackMap.containsKey(answer)) {
      return feedbackMap[answer]!;
    }

    return const CheckinFeedback(
      message: '좋아요!',
      tone: FeedbackTone.positive,
    );
  }

  /// 증상 선택 시 피드백 (CopingGuide 연동)
  Future<CheckinFeedback> getSupportiveFeedback(SymptomType symptomType) async {
    final symptomName = _mapSymptomTypeToName(symptomType);
    final guide = await _copingGuideRepository.getGuideBySymptom(symptomName);

    if (guide != null) {
      return CheckinFeedback(
        message: guide.reassuranceMessage,
        stat: guide.reassuranceStat,
        action: guide.immediateAction,
        tone: FeedbackTone.supportive,
      );
    }

    return CheckinFeedback(
      message: _defaultSupportiveMessage(symptomType),
      tone: FeedbackTone.supportive,
    );
  }

  /// 완료 시 종합 피드백
  CheckinFeedback getCompletionFeedback(DailyCheckin checkin) {
    final positives = <String>[];
    final encouragements = <String>[];

    // 긍정적 요소 찾기
    if (checkin.mealCondition == ConditionLevel.good) {
      positives.add('식사를 잘 하셨네요');
    }
    if (checkin.hydrationLevel == HydrationLevel.good) {
      positives.add('수분 섭취도 충분히 하셨고요');
    }
    if (checkin.energyLevel == EnergyLevel.good) {
      positives.add('에너지도 괜찮으셨군요');
    }
    if (checkin.symptomDetails == null || checkin.symptomDetails!.isEmpty) {
      positives.add('오늘 특별한 불편함 없이 잘 보내셨네요');
    }

    // 격려 요소
    if (checkin.symptomDetails != null && checkin.symptomDetails!.isNotEmpty) {
      encouragements.add('몸이 적응하는 중이에요. 잘 견디고 계세요');
    }

    final consecutiveDays = checkin.context?.consecutiveDays ?? 0;
    if (consecutiveDays >= 3) {
      encouragements.add('벌써 $consecutiveDays일째 기록 중이시네요!');
    }

    // 메시지 조합
    final message = _buildCompletionMessage(positives, encouragements);

    return CheckinFeedback(
      message: message,
      tone: FeedbackTone.positive,
    );
  }

  /// Red Flag 안내 메시지
  CheckinFeedback getRedFlagGuidance(RedFlagType redFlagType) {
    final guidance = _redFlagGuidanceMap[redFlagType];
    if (guidance != null) {
      return guidance;
    }

    return const CheckinFeedback(
      message: '오늘 기록해주신 증상이 조금 확인이 필요해 보여요.\n'
          '가까운 병원에서 확인받아 보시는 게 좋겠어요.',
      tone: FeedbackTone.cautious,
    );
  }

  // === Private Helper Methods ===

  /// SymptomType → CopingGuide symptomName 매핑
  String _mapSymptomTypeToName(SymptomType type) {
    switch (type) {
      case SymptomType.nausea:
        return '메스꺼움';
      case SymptomType.vomiting:
        return '구토';
      case SymptomType.lowAppetite:
        return '식욕 감소';
      case SymptomType.earlySatiety:
        return '조기 포만감';
      case SymptomType.heartburn:
        return '속쓰림';
      case SymptomType.abdominalPain:
        return '복통';
      case SymptomType.bloating:
        return '복부 팽만';
      case SymptomType.constipation:
        return '변비';
      case SymptomType.diarrhea:
        return '설사';
      case SymptomType.fatigue:
        return '피로';
      case SymptomType.dizziness:
        return '어지러움';
      case SymptomType.coldSweat:
        return '식은땀';
      case SymptomType.swelling:
        return '부종';
    }
  }

  /// 기본 지지 메시지 (CopingGuide 없을 경우)
  String _defaultSupportiveMessage(SymptomType symptomType) {
    switch (symptomType) {
      case SymptomType.nausea:
        return '메스꺼움은 흔한 증상이에요. 조금씩 나아질 거예요';
      case SymptomType.vomiting:
        return '힘드셨죠. 물을 조금씩 자주 마셔보세요';
      case SymptomType.lowAppetite:
        return '입맛이 없는 건 약이 작용하고 있다는 신호일 수 있어요';
      case SymptomType.earlySatiety:
        return '포만감이 빨리 오는 건 약이 잘 작용하고 있는 거예요';
      case SymptomType.heartburn:
        return '식후 바로 눕지 않는 게 도움이 돼요';
      case SymptomType.abdominalPain:
        return '복통은 잠시 지켜보시고, 계속되면 병원에 연락해주세요';
      case SymptomType.bloating:
        return '배가 빵빵한 건 일시적일 수 있어요';
      case SymptomType.constipation:
        return '수분과 섬유질을 충분히 섭취해보세요';
      case SymptomType.diarrhea:
        return '수분 섭취를 충분히 해주세요';
      case SymptomType.fatigue:
        return '충분히 쉬어주세요. 몸이 적응 중이에요';
      case SymptomType.dizziness:
        return '어지러움이 계속되면 병원에 연락해주세요';
      case SymptomType.coldSweat:
        return '식은땀이 나면 당분을 섭취하고 쉬어주세요';
      case SymptomType.swelling:
        return '붓기가 심하면 병원에서 확인받아 보세요';
    }
  }

  /// 완료 메시지 조합
  String _buildCompletionMessage(
    List<String> positives,
    List<String> encouragements,
  ) {
    final parts = <String>['오늘의 체크인 완료!\n'];

    if (positives.isNotEmpty) {
      parts.add(positives.join(', '));
      parts.add('.');
    }

    if (encouragements.isNotEmpty) {
      parts.add('\n${encouragements.join('\n')}');
    }

    if (positives.isEmpty && encouragements.isEmpty) {
      parts.add('기록해주셔서 감사해요. 💚');
    } else {
      parts.add('\n\n내일도 좋은 하루 되세요! 💚');
    }

    return parts.join('');
  }

  // === Static Data ===

  /// 긍정 답변별 피드백 맵
  static final Map<int, Map<String, CheckinFeedback>> _positiveFeedbackMap = {
    1: {
      // Q1 식사
      'good': const CheckinFeedback(
        message: '좋아요! 규칙적인 식사가 치료에 도움이 돼요 💚',
        tone: FeedbackTone.positive,
      ),
      'moderate': const CheckinFeedback(
        message: '괜찮아요, 소량씩 드시는 것도 좋아요',
        tone: FeedbackTone.supportive,
      ),
    },
    2: {
      // Q2 수분
      'good': const CheckinFeedback(
        message: '잘하셨어요! 수분 섭취가 정말 중요해요 💧',
        tone: FeedbackTone.positive,
      ),
      'moderate': const CheckinFeedback(
        message: '내일은 조금 더 챙겨보세요',
        tone: FeedbackTone.supportive,
      ),
    },
    3: {
      // Q3 속 편안함
      'good': const CheckinFeedback(
        message: '다행이에요! 💚',
        tone: FeedbackTone.positive,
      ),
    },
    4: {
      // Q4 화장실
      'normal': const CheckinFeedback(
        message: '좋아요! 규칙적인 게 중요해요',
        tone: FeedbackTone.positive,
      ),
    },
    5: {
      // Q5 에너지
      'good': const CheckinFeedback(
        message: '좋은 하루였네요! ⚡',
        tone: FeedbackTone.positive,
      ),
      'normal': const CheckinFeedback(
        message: '꾸준히 유지하고 계시네요',
        tone: FeedbackTone.positive,
      ),
    },
    6: {
      // Q6 기분
      'good': const CheckinFeedback(
        message: '좋은 하루였네요! 😊',
        tone: FeedbackTone.positive,
      ),
      'neutral': const CheckinFeedback(
        message: '그런 날도 있죠. 내일은 더 좋을 거예요',
        tone: FeedbackTone.supportive,
      ),
      'low': const CheckinFeedback(
        message: '힘든 날도 있어요. 당신은 잘하고 있어요 💚',
        tone: FeedbackTone.supportive,
      ),
    },
  };

  /// Red Flag 안내 메시지 맵
  static final Map<RedFlagType, CheckinFeedback> _redFlagGuidanceMap = {
    RedFlagType.pancreatitis: const CheckinFeedback(
      message: '💛 오늘 기록해주신 증상이 조금 확인이 필요해 보여요.\n\n'
          '윗배 통증이 등 쪽으로도 느껴지고,\n'
          '몇 시간 이상 지속되셨군요.\n\n'
          '이런 경우 드물지만 확인이 필요할 때가 있어요.\n'
          '오늘 중으로 가까운 병원에 들러서\n'
          '한 번 확인받아 보시는 게 안심이 될 것 같아요.\n\n'
          '💡 응급실이 아니어도 괜찮아요.\n'
          '   가까운 내과에서 확인받으시면 돼요.',
      tone: FeedbackTone.cautious,
    ),
    RedFlagType.cholecystitis: const CheckinFeedback(
      message: '💛 오른쪽 윗배 통증과 함께\n'
          '열감/오한이 있으셨군요.\n\n'
          '이런 경우 드물지만 담낭 쪽 확인이 필요할 때가 있어요.\n'
          '오늘 중으로 병원에서 확인받아 보시는 게 좋겠어요.',
      tone: FeedbackTone.cautious,
    ),
    RedFlagType.severeDehydration: const CheckinFeedback(
      message: '💛 수분 섭취가 어려우시군요.\n\n'
          '지금 가장 중요한 건 조금이라도 수분을 유지하는 거예요.\n'
          '• 이온음료를 한 모금씩 자주 마셔보세요\n'
          '• 얼음을 입에 물고 있는 것도 도움이 돼요\n\n'
          '만약 계속 물을 못 드시겠으면,\n'
          '오늘 중으로 병원에 들러보시는 게 좋겠어요.',
      tone: FeedbackTone.cautious,
    ),
    RedFlagType.bowelObstruction: const CheckinFeedback(
      message: '💛 변비가 꽤 오래 지속되고,\n'
          '가스도 안 나오시는군요.\n\n'
          '드문 경우지만 확인이 필요할 수 있어요.\n'
          '오늘 중으로 병원에 들러보시는 게 좋겠어요.',
      tone: FeedbackTone.cautious,
    ),
    RedFlagType.hypoglycemia: const CheckinFeedback(
      message: '💛 저혈당 증상일 수 있어요.\n\n'
          '지금 바로 사탕이나 주스 등 당분을 드셔보세요.\n\n'
          '💡 15분 후에도 나아지지 않으면\n'
          '   병원에 연락해주세요.\n\n'
          '다음 진료 때 선생님께 말씀드리시면\n'
          '약 용량을 조절해주실 수 있어요.',
      tone: FeedbackTone.cautious,
    ),
    RedFlagType.renalImpairment: const CheckinFeedback(
      message: '💛 최근 구토/설사와 함께\n'
          '피로, 붓기, 소변 감소가 있으시군요.\n\n'
          '탈수로 인해 몸이 힘들어할 수 있어요.\n'
          '오늘 중으로 병원에서 확인받아 보시는 게 좋겠어요.',
      tone: FeedbackTone.cautious,
    ),
  };
}
