import 'package:isar/isar.dart';
import 'package:n06/features/onboarding/domain/entities/user.dart';
import 'package:n06/features/onboarding/domain/repositories/user_repository.dart';
import 'package:n06/features/authentication/infrastructure/dtos/user_dto.dart';

/// Isar 기반 UserRepository 구현
class IsarUserRepository implements UserRepository {
  final Isar _isar;

  IsarUserRepository(this._isar);

  @override
  Future<void> updateUserName(String userId, String name) async {
    final userIsarId = int.tryParse(userId);
    if (userIsarId == null) {
      throw Exception('잘못된 사용자 ID 형식: $userId');
    }

    final dto = await _isar.userDtos.get(userIsarId);
    if (dto == null) {
      throw Exception('사용자를 찾을 수 없습니다: $userId');
    }

    dto.name = name;
    await _isar.writeTxn(() async {
      await _isar.userDtos.put(dto);
    });
  }

  @override
  Future<User?> getUser(String userId) async {
    final userIsarId = int.tryParse(userId);
    if (userIsarId == null) return null;

    final dto = await _isar.userDtos.get(userIsarId);
    if (dto == null) return null;

    // Authentication UserDto를 Onboarding User 엔티티로 변환
    return User(
      id: dto.id.toString(),
      name: dto.name,
      createdAt: dto.lastLoginAt, // lastLoginAt를 createdAt로 사용
    );
  }

  @override
  Future<void> saveUser(User user) async {
    // 온보딩에서는 saveUser를 사용하지 않음
    // Authentication feature에서 이미 User를 저장했음
    throw UnimplementedError('Onboarding should not create users. Users are created during authentication.');
  }
}
