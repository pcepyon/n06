import 'package:isar/isar.dart';
import 'package:n06/features/onboarding/domain/entities/user_profile.dart';
import 'package:n06/features/profile/domain/repositories/profile_repository.dart';
import 'package:n06/features/profile/infrastructure/dtos/user_profile_dto.dart';

/// Isar implementation of ProfileRepository
class IsarProfileRepository implements ProfileRepository {
  final Isar isar;

  IsarProfileRepository(this.isar);

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    final dto = await isar.userProfileDtos.filter().userIdEqualTo(userId).findFirst();

    if (dto == null) {
      throw Exception('User profile not found for user: $userId');
    }

    return dto.toEntity();
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    final dto = UserProfileDto.fromEntity(profile);
    await isar.writeTxn(() async {
      await isar.userProfileDtos.put(dto);
    });
  }

  @override
  Stream<UserProfile> watchUserProfile(String userId) {
    return isar.userProfileDtos
        .filter()
        .userIdEqualTo(userId)
        .watch(fireImmediately: true)
        .map((dtos) {
      if (dtos.isEmpty) {
        throw Exception('User profile not found for user: $userId');
      }
      return dtos.first.toEntity();
    });
  }
}
