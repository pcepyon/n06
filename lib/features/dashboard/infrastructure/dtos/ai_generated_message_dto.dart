import 'package:n06/features/dashboard/domain/entities/ai_generated_message.dart';

/// Supabase DTO for AIGeneratedMessage entity.
///
/// Handles conversion between Supabase JSON and domain entity.
class AIGeneratedMessageDto {
  final String id;
  final String userId;
  final String message;
  final Map<String, dynamic>? contextSnapshot;
  final DateTime generatedAt;
  final String triggerType;

  const AIGeneratedMessageDto({
    required this.id,
    required this.userId,
    required this.message,
    this.contextSnapshot,
    required this.generatedAt,
    required this.triggerType,
  });

  /// Creates DTO from Supabase JSON.
  factory AIGeneratedMessageDto.fromJson(Map<String, dynamic> json) {
    return AIGeneratedMessageDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      message: json['message'] as String,
      contextSnapshot: json['context_snapshot'] as Map<String, dynamic>?,
      generatedAt: DateTime.parse(json['generated_at'] as String).toLocal(),
      triggerType: json['trigger_type'] as String,
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'message': message,
      'context_snapshot': contextSnapshot,
      'generated_at': generatedAt.toUtc().toIso8601String(),
      'trigger_type': triggerType,
    };
  }

  /// Converts DTO to Domain Entity.
  AIGeneratedMessage toEntity() {
    return AIGeneratedMessage(
      id: id,
      userId: userId,
      message: message,
      contextSnapshot: contextSnapshot,
      generatedAt: generatedAt,
      triggerType: _stringToTriggerType(triggerType),
    );
  }

  /// Creates DTO from Domain Entity.
  factory AIGeneratedMessageDto.fromEntity(AIGeneratedMessage entity) {
    return AIGeneratedMessageDto(
      id: entity.id,
      userId: entity.userId,
      message: entity.message,
      contextSnapshot: entity.contextSnapshot,
      generatedAt: entity.generatedAt,
      triggerType: _triggerTypeToString(entity.triggerType),
    );
  }

  static MessageTriggerType _stringToTriggerType(String value) {
    switch (value) {
      case 'daily_first_open':
        return MessageTriggerType.dailyFirstOpen;
      case 'post_checkin':
        return MessageTriggerType.postCheckin;
      default:
        return MessageTriggerType.dailyFirstOpen;
    }
  }

  static String _triggerTypeToString(MessageTriggerType type) {
    switch (type) {
      case MessageTriggerType.dailyFirstOpen:
        return 'daily_first_open';
      case MessageTriggerType.postCheckin:
        return 'post_checkin';
    }
  }
}
