import 'package:flutter/foundation.dart';
import 'coping_guide.dart';

/// 가이드 상태 (심각도 경고 포함)
@immutable
class CopingGuideState {
  final CopingGuide guide;
  final bool showSeverityWarning;

  const CopingGuideState({
    required this.guide,
    this.showSeverityWarning = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CopingGuideState &&
          runtimeType == other.runtimeType &&
          guide == other.guide &&
          showSeverityWarning == other.showSeverityWarning;

  @override
  int get hashCode => guide.hashCode ^ showSeverityWarning.hashCode;

  @override
  String toString() =>
      'CopingGuideState(guide: $guide, showSeverityWarning: $showSeverityWarning)';
}
