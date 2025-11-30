import 'package:flutter/foundation.dart';

import 'guide_section.dart';

/// 부작용 대처 가이드 엔터티
@immutable
class CopingGuide {
  final String symptomName;
  final String shortGuide;
  final List<GuideSection>? detailedSections;

  // Phase 1: 안심 퍼스트 가이드 필드
  final String reassuranceMessage;
  final String? reassuranceStat;
  final String immediateAction;
  final String? positiveFraming;

  const CopingGuide({
    required this.symptomName,
    required this.shortGuide,
    this.detailedSections,
    required this.reassuranceMessage,
    this.reassuranceStat,
    required this.immediateAction,
    this.positiveFraming,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CopingGuide &&
          runtimeType == other.runtimeType &&
          symptomName == other.symptomName &&
          shortGuide == other.shortGuide &&
          detailedSections == other.detailedSections &&
          reassuranceMessage == other.reassuranceMessage &&
          reassuranceStat == other.reassuranceStat &&
          immediateAction == other.immediateAction &&
          positiveFraming == other.positiveFraming;

  @override
  int get hashCode =>
      symptomName.hashCode ^
      shortGuide.hashCode ^
      detailedSections.hashCode ^
      reassuranceMessage.hashCode ^
      reassuranceStat.hashCode ^
      immediateAction.hashCode ^
      positiveFraming.hashCode;

  @override
  String toString() =>
      'CopingGuide(symptomName: $symptomName, shortGuide: $shortGuide, detailedSections: $detailedSections)';
}
