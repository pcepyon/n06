import 'package:n06/features/onboarding/domain/entities/user.dart';

/// 사용자 정보 접근 계약을 정의하는 Repository Interface
abstract class UserRepository {
  /// 사용자명을 업데이트한다.
  Future<void> updateUserName(String userId, String name);

  /// 사용자 정보를 조회한다.
  Future<User?> getUser(String userId);

  /// 사용자 정보를 저장한다.
  Future<void> saveUser(User user);
}
