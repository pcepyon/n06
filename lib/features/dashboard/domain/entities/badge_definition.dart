import 'package:equatable/equatable.dart';

enum BadgeCategory {
  streak,
  weight,
  dose,
  record,
}

class BadgeDefinition extends Equatable {
  final String id;
  final String name;
  final String description;
  final BadgeCategory category;
  final String? iconUrl;
  final int displayOrder;

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.iconUrl,
    required this.displayOrder,
  });

  BadgeDefinition copyWith({
    String? id,
    String? name,
    String? description,
    BadgeCategory? category,
    String? iconUrl,
    int? displayOrder,
  }) {
    return BadgeDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      iconUrl: iconUrl ?? this.iconUrl,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, description, category, iconUrl, displayOrder];

  @override
  String toString() => 'BadgeDefinition(id: $id, name: $name, category: $category)';
}
