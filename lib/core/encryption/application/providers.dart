import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/encryption_service.dart';
import '../infrastructure/aes_encryption_service.dart';
import '../../providers.dart';

/// EncryptionService Provider
///
/// AES-256-GCM 암호화 서비스 인스턴스를 제공합니다.
/// 사용자별로 서버에서 암호화 키를 로드/저장합니다.
///
/// Repository 생성자에서 이 Provider를 주입받고,
/// Repository 메서드 호출 전에 initialize(userId)를 호출해야 합니다.
///
/// 사용 예 (Repository 내부):
/// ```dart
/// @override
/// Future<void> saveData(String userId, Data data) async {
///   await _encryptionService.initialize(userId);
///   final encrypted = _encryptionService.encrypt(data.value);
///   // ...
/// }
/// ```
final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return AesEncryptionService(supabase);
});
