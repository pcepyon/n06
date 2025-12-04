import 'package:flutter/material.dart';
import 'package:n06/l10n/generated/app_localizations.dart';
import 'package:n06/features/coping_guide/domain/entities/coping_guide.dart';
import 'package:n06/features/coping_guide/domain/entities/default_guide_message_type.dart';

/// CopingGuide를 i18n 문자열로 변환하는 확장
///
/// 기본 가이드 마커 문자열을 i18n 키로 변환합니다.
extension CopingGuideExtension on CopingGuide {
  /// 증상명 i18n 처리
  String getLocalizedSymptomName(BuildContext context) {
    if (symptomName == DefaultGuideMessageType.defaultSymptomName) {
      final l10n = L10n.of(context);
      return l10n.copingGuide_defaultSymptomName;
    }
    return symptomName;
  }

  /// 짧은 안내 i18n 처리
  String getLocalizedShortGuide(BuildContext context) {
    if (shortGuide == DefaultGuideMessageType.defaultShortGuide) {
      final l10n = L10n.of(context);
      return l10n.copingGuide_defaultShortGuide;
    }
    return shortGuide;
  }

  /// 안심 메시지 i18n 처리
  String getLocalizedReassuranceMessage(BuildContext context) {
    if (reassuranceMessage ==
        DefaultGuideMessageType.defaultReassuranceMessage) {
      final l10n = L10n.of(context);
      return l10n.copingGuide_defaultReassuranceMessage;
    }
    return reassuranceMessage;
  }

  /// 즉시 조치 i18n 처리
  String getLocalizedImmediateAction(BuildContext context) {
    if (immediateAction == DefaultGuideMessageType.defaultImmediateAction) {
      final l10n = L10n.of(context);
      return l10n.copingGuide_defaultImmediateAction;
    }
    return immediateAction;
  }

  /// 기본 가이드 여부 확인
  bool get isDefaultGuide =>
      symptomName == DefaultGuideMessageType.defaultSymptomName;
}
