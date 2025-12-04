import 'package:flutter/widgets.dart';
import 'package:n06/core/extensions/l10n_extension.dart';
import 'package:n06/features/daily_checkin/domain/entities/checkin_feedback.dart';
import 'package:n06/features/daily_checkin/domain/entities/feedback_type.dart';

/// 피드백 l10n 매퍼
///
/// Application Layer에서 반환한 enum 타입을
/// Presentation Layer에서 l10n 문자열로 변환합니다.
class FeedbackL10nMapper {
  /// CheckinFeedback → 표시할 메시지 (주요 메시지)
  static String getFeedbackMessage(
    BuildContext context,
    CheckinFeedback feedback,
  ) {
    final l10n = context.l10n;

    // CopingGuide 메시지가 있으면 우선 사용
    if (feedback.copingGuideMessage != null) {
      return feedback.copingGuideMessage!;
    }

    // 긍정 피드백
    if (feedback.positiveFeedbackType != null) {
      return _getPositiveFeedbackText(l10n, feedback.positiveFeedbackType!);
    }

    // 지지 피드백
    if (feedback.supportiveFeedbackType != null) {
      return _getSupportiveFeedbackText(l10n, feedback.supportiveFeedbackType!);
    }

    // 완료 피드백
    if (feedback.completionElements != null) {
      return _buildCompletionMessage(
        l10n,
        feedback.completionElements!,
        feedback.consecutiveDays,
      );
    }

    // Red Flag 안내
    if (feedback.redFlagGuidanceType != null) {
      return _getRedFlagGuidanceText(l10n, feedback.redFlagGuidanceType!);
    }

    return '';
  }

  /// 통계 정보 (선택적)
  static String? getFeedbackStat(CheckinFeedback feedback) {
    return feedback.copingGuideStat;
  }

  /// 즉각 행동 제안 (선택적)
  static String? getFeedbackAction(CheckinFeedback feedback) {
    return feedback.copingGuideAction;
  }

  // === Private Helper Methods ===

  /// 긍정 피드백 타입 → 문자열
  static String _getPositiveFeedbackText(
    dynamic l10n,
    PositiveFeedbackType type,
  ) {
    switch (type) {
      case PositiveFeedbackType.goodMeal:
        return l10n.checkin_feedback_goodMeal;
      case PositiveFeedbackType.moderateMeal:
        return l10n.checkin_feedback_moderateMeal;
      case PositiveFeedbackType.goodHydration:
        return l10n.checkin_feedback_goodHydration;
      case PositiveFeedbackType.moderateHydration:
        return l10n.checkin_feedback_moderateHydration;
      case PositiveFeedbackType.goodComfort:
        return l10n.checkin_feedback_goodComfort;
      case PositiveFeedbackType.normalBowel:
        return l10n.checkin_feedback_normalBowel;
      case PositiveFeedbackType.goodEnergy:
        return l10n.checkin_feedback_goodEnergy;
      case PositiveFeedbackType.normalEnergy:
        return l10n.checkin_feedback_normalEnergy;
      case PositiveFeedbackType.goodMood:
        return l10n.checkin_feedback_goodMood;
      case PositiveFeedbackType.neutralMood:
        return l10n.checkin_feedback_neutralMood;
      case PositiveFeedbackType.lowMood:
        return l10n.checkin_feedback_lowMood;
      case PositiveFeedbackType.generic:
        return l10n.checkin_feedback_generic;
    }
  }

  /// 지지 피드백 타입 → 문자열
  static String _getSupportiveFeedbackText(
    dynamic l10n,
    SupportiveFeedbackType type,
  ) {
    switch (type) {
      case SupportiveFeedbackType.nausea:
        return l10n.checkin_feedback_supportive_nausea;
      case SupportiveFeedbackType.vomiting:
        return l10n.checkin_feedback_supportive_vomiting;
      case SupportiveFeedbackType.lowAppetite:
        return l10n.checkin_feedback_supportive_lowAppetite;
      case SupportiveFeedbackType.earlySatiety:
        return l10n.checkin_feedback_supportive_earlySatiety;
      case SupportiveFeedbackType.heartburn:
        return l10n.checkin_feedback_supportive_heartburn;
      case SupportiveFeedbackType.abdominalPain:
        return l10n.checkin_feedback_supportive_abdominalPain;
      case SupportiveFeedbackType.bloating:
        return l10n.checkin_feedback_supportive_bloating;
      case SupportiveFeedbackType.constipation:
        return l10n.checkin_feedback_supportive_constipation;
      case SupportiveFeedbackType.diarrhea:
        return l10n.checkin_feedback_supportive_diarrhea;
      case SupportiveFeedbackType.fatigue:
        return l10n.checkin_feedback_supportive_fatigue;
      case SupportiveFeedbackType.dizziness:
        return l10n.checkin_feedback_supportive_dizziness;
      case SupportiveFeedbackType.coldSweat:
        return l10n.checkin_feedback_supportive_coldSweat;
      case SupportiveFeedbackType.swelling:
        return l10n.checkin_feedback_supportive_swelling;
    }
  }

  /// 완료 피드백 요소들 → 조합된 메시지
  static String _buildCompletionMessage(
    dynamic l10n,
    List<CompletionFeedbackElement> elements,
    int? consecutiveDays,
  ) {
    final parts = <String>[l10n.checkin_feedback_completion_title];

    final positives = <String>[];
    final encouragements = <String>[];

    for (final element in elements) {
      switch (element) {
        case CompletionFeedbackElement.goodMeal:
          positives.add(l10n.checkin_feedback_completion_goodMeal);
          break;
        case CompletionFeedbackElement.goodHydration:
          positives.add(l10n.checkin_feedback_completion_goodHydration);
          break;
        case CompletionFeedbackElement.goodEnergy:
          positives.add(l10n.checkin_feedback_completion_goodEnergy);
          break;
        case CompletionFeedbackElement.noSymptoms:
          positives.add(l10n.checkin_feedback_completion_noSymptoms);
          break;
        case CompletionFeedbackElement.bodyAdapting:
          encouragements.add(l10n.checkin_feedback_completion_bodyAdapting);
          break;
        case CompletionFeedbackElement.consecutiveDays:
          if (consecutiveDays != null) {
            encouragements
                .add(l10n.checkin_feedback_completion_consecutiveDays(consecutiveDays));
          }
          break;
      }
    }

    if (positives.isNotEmpty) {
      parts.add('\n${positives.join(', ')}.');
    }

    if (encouragements.isNotEmpty) {
      parts.add('\n${encouragements.join('\n')}');
    }

    if (positives.isEmpty && encouragements.isEmpty) {
      parts.add('\n${l10n.checkin_feedback_completion_thanks}');
    } else {
      parts.add('\n\n${l10n.checkin_feedback_completion_closing}');
    }

    return parts.join('');
  }

  /// Red Flag 안내 타입 → 문자열
  static String _getRedFlagGuidanceText(
    dynamic l10n,
    RedFlagGuidanceType type,
  ) {
    switch (type) {
      case RedFlagGuidanceType.pancreatitis:
        return l10n.checkin_feedback_redFlag_pancreatitis;
      case RedFlagGuidanceType.cholecystitis:
        return l10n.checkin_feedback_redFlag_cholecystitis;
      case RedFlagGuidanceType.severeDehydration:
        return l10n.checkin_feedback_redFlag_severeDehydration;
      case RedFlagGuidanceType.bowelObstruction:
        return l10n.checkin_feedback_redFlag_bowelObstruction;
      case RedFlagGuidanceType.hypoglycemia:
        return l10n.checkin_feedback_redFlag_hypoglycemia;
      case RedFlagGuidanceType.renalImpairment:
        return l10n.checkin_feedback_redFlag_renalImpairment;
      case RedFlagGuidanceType.generic:
        return l10n.checkin_feedback_redFlag_generic;
    }
  }
}
