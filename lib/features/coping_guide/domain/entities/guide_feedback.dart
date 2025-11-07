import 'package:flutter/foundation.dart';

/// 가이드 피드백 엔터티 (도움이 되었는지 여부)
@immutable
class GuideFeedback {
  final String symptomName;
  final bool helpful;
  final DateTime timestamp;

  const GuideFeedback({
    required this.symptomName,
    required this.helpful,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuideFeedback &&
          runtimeType == other.runtimeType &&
          symptomName == other.symptomName &&
          helpful == other.helpful &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      symptomName.hashCode ^ helpful.hashCode ^ timestamp.hashCode;

  @override
  String toString() =>
      'GuideFeedback(symptomName: $symptomName, helpful: $helpful, timestamp: $timestamp)';
}
