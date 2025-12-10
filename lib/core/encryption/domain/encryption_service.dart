/// 암호화 서비스 인터페이스
///
/// 민감한 건강 정보를 AES-256-GCM으로 암호화/복호화하는 서비스입니다.
/// Repository 계층에서 사용되며, 키는 플랫폼 보안 저장소에 보관됩니다.
///
/// NULL 처리 정책:
/// - null 입력 → null 반환
/// - 빈 문자열 → 암호화된 문자열 반환
abstract class EncryptionService {
  /// 서비스 초기화
  ///
  /// [userId] 사용자 ID (서버에서 키 조회/저장 시 사용)
  ///
  /// 암호화 키를 서버에서 로드하거나, 없으면 새로 생성하여 저장합니다.
  /// 사용자 로그인 후 반드시 호출해야 합니다.
  Future<void> initialize(String userId);

  /// 문자열 암호화
  ///
  /// [plainText]를 AES-256-GCM으로 암호화합니다.
  /// 반환값: Base64(IV + Ciphertext + AuthTag)
  /// null 입력 시 null 반환
  String? encrypt(String? plainText);

  /// 문자열 복호화
  ///
  /// [cipherText]를 복호화합니다.
  /// 입력: Base64(IV + Ciphertext + AuthTag)
  /// null 입력 시 null 반환
  /// 복호화 실패 시 [EncryptionException] throw
  String? decrypt(String? cipherText);

  /// double 값 암호화 (편의 메서드)
  ///
  /// double을 문자열로 변환 후 암호화합니다.
  String? encryptDouble(double? value);

  /// double 값 복호화 (편의 메서드)
  ///
  /// 암호문을 복호화 후 double로 변환합니다.
  double? decryptDouble(String? cipherText);

  /// int 값 암호화 (편의 메서드)
  ///
  /// int를 문자열로 변환 후 암호화합니다.
  String? encryptInt(int? value);

  /// int 값 복호화 (편의 메서드)
  ///
  /// 암호문을 복호화 후 int로 변환합니다.
  int? decryptInt(String? cipherText);

  /// JSON 암호화 (편의 메서드)
  ///
  /// Map을 JSON 문자열로 변환 후 암호화합니다.
  String? encryptJson(Map<String, dynamic>? json);

  /// JSON 복호화 (편의 메서드)
  ///
  /// 암호문을 복호화 후 Map으로 변환합니다.
  Map<String, dynamic>? decryptJson(String? cipherText);

  /// JSON List 암호화 (편의 메서드)
  ///
  /// List<dynamic>을 JSON 문자열로 변환 후 암호화합니다.
  String? encryptJsonList(List<dynamic>? jsonList);

  /// JSON List 복호화 (편의 메서드)
  ///
  /// 암호문을 복호화 후 List<dynamic>으로 변환합니다.
  List<dynamic>? decryptJsonList(String? cipherText);
}

/// 암호화 관련 예외
class EncryptionException implements Exception {
  final String message;
  final Object? originalError;

  EncryptionException(this.message, {this.originalError});

  @override
  String toString() => 'EncryptionException: $message';
}
