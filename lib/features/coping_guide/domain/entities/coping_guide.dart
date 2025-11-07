import 'package:flutter/foundation.dart';

import 'guide_section.dart';

/// 부작용 대처 가이드 엔터티
@immutable
class CopingGuide {
  final String symptomName;
  final String shortGuide;
  final List<GuideSection>? detailedSections;

  const CopingGuide({
    required this.symptomName,
    required this.shortGuide,
    this.detailedSections,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CopingGuide &&
          runtimeType == other.runtimeType &&
          symptomName == other.symptomName &&
          shortGuide == other.shortGuide &&
          detailedSections == other.detailedSections;

  @override
  int get hashCode =>
      symptomName.hashCode ^ shortGuide.hashCode ^ detailedSections.hashCode;

  @override
  String toString() =>
      'CopingGuide(symptomName: $symptomName, shortGuide: $shortGuide, detailedSections: $detailedSections)';
}
