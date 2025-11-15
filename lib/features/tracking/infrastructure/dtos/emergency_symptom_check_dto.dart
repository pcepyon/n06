import 'package:n06/features/tracking/domain/entities/emergency_symptom_check.dart';

/// Supabase DTO for EmergencySymptomCheck entity.
///
/// Stores emergency symptom check information in Supabase database.
class EmergencySymptomCheckDto {
  final String id;
  final String userId;
  final DateTime checkedAt;
  final List<String> checkedSymptoms;

  const EmergencySymptomCheckDto({
    required this.id,
    required this.userId,
    required this.checkedAt,
    required this.checkedSymptoms,
  });

  /// Creates DTO from Supabase JSON.
  factory EmergencySymptomCheckDto.fromJson(Map<String, dynamic> json) {
    return EmergencySymptomCheckDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      checkedAt: DateTime.parse(json['checked_at'] as String),
      checkedSymptoms: List<String>.from(json['checked_symptoms'] as List),
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'checked_at': checkedAt.toIso8601String(),
      'checked_symptoms': checkedSymptoms,
    };
  }

  /// Domain Entity로 변환
  EmergencySymptomCheck toEntity() {
    return EmergencySymptomCheck(
      id: id,
      userId: userId,
      checkedAt: checkedAt,
      checkedSymptoms: checkedSymptoms,
    );
  }

  /// Domain Entity로부터 생성
  factory EmergencySymptomCheckDto.fromEntity(
    EmergencySymptomCheck entity,
  ) {
    return EmergencySymptomCheckDto(
      id: entity.id,
      userId: entity.userId,
      checkedAt: entity.checkedAt,
      checkedSymptoms: entity.checkedSymptoms,
    );
  }
}
