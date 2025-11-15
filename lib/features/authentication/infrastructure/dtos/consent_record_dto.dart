import 'package:n06/features/authentication/domain/entities/consent_record.dart';

/// Supabase DTO for ConsentRecord entity.
///
/// Stores user consent information in Supabase database.
class ConsentRecordDto {
  final String id;
  final String userId;
  final bool termsOfService;
  final bool privacyPolicy;
  final DateTime agreedAt;

  const ConsentRecordDto({
    required this.id,
    required this.userId,
    required this.termsOfService,
    required this.privacyPolicy,
    required this.agreedAt,
  });

  /// Creates DTO from Supabase JSON.
  factory ConsentRecordDto.fromJson(Map<String, dynamic> json) {
    return ConsentRecordDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      termsOfService: json['terms_of_service'] as bool,
      privacyPolicy: json['privacy_policy'] as bool,
      agreedAt: DateTime.parse(json['agreed_at'] as String),
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'terms_of_service': termsOfService,
      'privacy_policy': privacyPolicy,
      'agreed_at': agreedAt.toIso8601String(),
    };
  }

  /// Converts DTO to Domain Entity.
  ConsentRecord toEntity() {
    return ConsentRecord(
      id: id,
      userId: userId,
      termsOfService: termsOfService,
      privacyPolicy: privacyPolicy,
      agreedAt: agreedAt,
    );
  }

  /// Creates DTO from Domain Entity.
  factory ConsentRecordDto.fromEntity(ConsentRecord entity) {
    return ConsentRecordDto(
      id: entity.id,
      userId: entity.userId,
      termsOfService: entity.termsOfService,
      privacyPolicy: entity.privacyPolicy,
      agreedAt: entity.agreedAt,
    );
  }
}
