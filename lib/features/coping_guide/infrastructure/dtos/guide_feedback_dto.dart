import '../../domain/entities/guide_feedback.dart';

/// Supabase DTO for GuideFeedback entity.
///
/// Stores guide feedback information in Supabase database.
class GuideFeedbackDto {
  final String id;
  final String userId;
  final String symptomName;
  final bool helpful;
  final DateTime timestamp;

  const GuideFeedbackDto({
    required this.id,
    required this.userId,
    required this.symptomName,
    required this.helpful,
    required this.timestamp,
  });

  /// Creates DTO from Supabase JSON.
  factory GuideFeedbackDto.fromJson(Map<String, dynamic> json) {
    return GuideFeedbackDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      symptomName: json['symptom_name'] as String,
      helpful: json['helpful'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'symptom_name': symptomName,
      'helpful': helpful,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Entity로 변환
  GuideFeedback toEntity() => GuideFeedback(
        symptomName: symptomName,
        helpful: helpful,
        timestamp: timestamp,
      );

  /// Entity에서 DTO로 생성
  static GuideFeedbackDto fromEntity(GuideFeedback entity, {required String id, required String userId}) {
    return GuideFeedbackDto(
      id: id,
      userId: userId,
      symptomName: entity.symptomName,
      helpful: entity.helpful,
      timestamp: entity.timestamp,
    );
  }
}
