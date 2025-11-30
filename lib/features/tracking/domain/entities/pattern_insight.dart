import 'package:flutter/foundation.dart';

/// 패턴 인사이트 엔티티
///
/// Phase 2: 컨텍스트 인식 가이드
/// 최근 N일간 증상 기록에서 발견된 패턴 인사이트
@immutable
class PatternInsight {
  final PatternType type;
  final String symptomName;
  final String message;
  final String? suggestion;
  final double confidence;

  const PatternInsight({
    required this.type,
    required this.symptomName,
    required this.message,
    this.suggestion,
    required this.confidence,
  }) : assert(confidence >= 0.0 && confidence <= 1.0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatternInsight &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          symptomName == other.symptomName &&
          message == other.message &&
          suggestion == other.suggestion &&
          confidence == other.confidence;

  @override
  int get hashCode =>
      type.hashCode ^
      symptomName.hashCode ^
      message.hashCode ^
      suggestion.hashCode ^
      confidence.hashCode;

  @override
  String toString() =>
      'PatternInsight(type: $type, symptomName: $symptomName, message: $message, confidence: $confidence)';
}

/// 패턴 유형
enum PatternType {
  /// 최근 N일간 동일 증상 반복
  recurring,

  /// 특정 컨텍스트(음식, 시간대)와 증상 연관성
  contextRelated,

  /// 개선 추세
  improving,

  /// 악화 추세
  worsening,
}
