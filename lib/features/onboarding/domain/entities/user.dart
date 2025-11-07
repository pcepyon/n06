/// 사용자 계정 정보를 나타내는 Entity
class User {
  final String id;
  final String name;
  final DateTime createdAt;

  /// User 엔티티를 생성한다.
  /// id와 name이 비어있으면 ArgumentError를 던진다.
  User({
    required this.id,
    required this.name,
    required this.createdAt,
  }) {
    if (id.isEmpty) {
      throw ArgumentError('id는 비워둘 수 없습니다.');
    }
    if (name.isEmpty) {
      throw ArgumentError('name은 비워둘 수 없습니다.');
    }
  }

  /// 현재 User의 일부 필드를 변경한 새로운 User를 반환한다.
  User copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.name == name &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ createdAt.hashCode;

  @override
  String toString() =>
      'User(id: $id, name: $name, createdAt: $createdAt)';
}
