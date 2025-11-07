import 'package:n06/features/onboarding/domain/repositories/profile_repository.dart';

/// 사용자의 온보딩 완료 여부를 확인하는 UseCase
class CheckOnboardingStatusUseCase {
  final ProfileRepository _profileRepository;

  CheckOnboardingStatusUseCase(this._profileRepository);

  /// 사용자가 온보딩을 완료했는지 확인한다.
  /// - true: 온보딩 완료 (프로필 존재)
  /// - false: 온보딩 미완료 (프로필 없음)
  Future<bool> execute(String userId) async {
    try {
      final profile = await _profileRepository.getUserProfile(userId);
      return profile != null;
    } catch (e) {
      return false;
    }
  }
}
