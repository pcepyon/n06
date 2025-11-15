import 'package:n06/features/dashboard/domain/entities/badge_definition.dart';

/// Supabase DTO for BadgeDefinition entity.
///
/// Stores badge definition information in Supabase database.
class BadgeDefinitionDto {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? iconUrl;
  final int displayOrder;
  final Map<String, dynamic>? achievementCondition;

  const BadgeDefinitionDto({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.iconUrl,
    required this.displayOrder,
    this.achievementCondition,
  });

  /// Creates DTO from Supabase JSON.
  factory BadgeDefinitionDto.fromJson(Map<String, dynamic> json) {
    return BadgeDefinitionDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      iconUrl: json['icon_url'] as String?,
      displayOrder: json['display_order'] as int,
      achievementCondition: json['achievement_condition'] as Map<String, dynamic>?,
    );
  }

  /// Converts DTO to Supabase JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'icon_url': iconUrl,
      'display_order': displayOrder,
      'achievement_condition': achievementCondition,
    };
  }

  /// Converts DTO to Domain Entity.
  BadgeDefinition toEntity() {
    return BadgeDefinition(
      id: id,
      name: name,
      description: description,
      category: _stringToCategory(category),
      iconUrl: iconUrl,
      displayOrder: displayOrder,
    );
  }

  /// Creates DTO from Domain Entity.
  factory BadgeDefinitionDto.fromEntity(BadgeDefinition entity) {
    return BadgeDefinitionDto(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      category: entity.category.toString().split('.').last,
      iconUrl: entity.iconUrl,
      displayOrder: entity.displayOrder,
      achievementCondition: null,
    );
  }

  static BadgeCategory _stringToCategory(String value) {
    return BadgeCategory.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => BadgeCategory.streak,
    );
  }
}
