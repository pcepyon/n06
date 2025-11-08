import 'package:isar/isar.dart';
import 'package:n06/features/dashboard/domain/entities/badge_definition.dart';

part 'badge_definition_dto.g.dart';

@collection
class BadgeDefinitionDto {
  Id? isarId;
  late String id;
  late String name;
  late String description;
  late String category; // enum string: streak, weight, dose, record
  String? iconUrl;
  late int displayOrder;

  BadgeDefinitionDto();

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

  factory BadgeDefinitionDto.fromEntity(BadgeDefinition entity) {
    return BadgeDefinitionDto()
      ..id = entity.id
      ..name = entity.name
      ..description = entity.description
      ..category = entity.category.toString().split('.').last
      ..iconUrl = entity.iconUrl
      ..displayOrder = entity.displayOrder;
  }

  static BadgeCategory _stringToCategory(String value) {
    return BadgeCategory.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => BadgeCategory.streak,
    );
  }
}
