import 'package:isar/isar.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/onboarding/domain/repositories/profile_repository.dart';
import 'package:n06/features/onboarding/infrastructure/dtos/user_profile_dto.dart';

/// Isar 기반 ProfileRepository 구현
class IsarProfileRepository implements ProfileRepository {
  final Isar _isar;

  IsarProfileRepository(this._isar);

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    final dto = UserProfileDto.fromEntity(profile);
    await _isar.writeTxn(() async {
      await _isar.userProfileDtos.put(dto);
    });
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    final dto = await _isar.userProfileDtos
        .filter()
        .userIdEqualTo(userId)
        .findFirst();
    return dto?.toEntity();
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    final dto = UserProfileDto.fromEntity(profile);
    await _isar.writeTxn(() async {
      await _isar.userProfileDtos.put(dto);
    });
  }
}
