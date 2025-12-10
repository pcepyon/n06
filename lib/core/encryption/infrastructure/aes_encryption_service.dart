import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as aes_lib;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/encryption_service.dart';

/// AES-256-GCM 암호화 서비스 구현체
///
/// 암호화 알고리즘: AES-256-GCM (인증된 암호화)
/// IV: 매 암호화마다 16바이트 랜덤 생성
/// 암호문 형식: Base64(IV + Ciphertext + AuthTag)
/// 키 저장: Supabase user_encryption_keys 테이블에 저장 (다중 기기 지원)
class AesEncryptionService implements EncryptionService {
  final SupabaseClient _supabase;

  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 16; // 128 bits

  aes_lib.Key? _key;
  String? _currentUserId;

  AesEncryptionService(this._supabase);

  @override
  Future<void> initialize(String userId) async {
    // 이미 같은 사용자로 초기화된 경우 스킵
    if (_currentUserId == userId && _key != null) return;

    // 1. Supabase에서 저장된 키 조회
    final response = await _supabase
        .from('user_encryption_keys')
        .select('encryption_key')
        .eq('user_id', userId)
        .maybeSingle();

    if (response != null) {
      // 기존 키 사용
      final storedKey = response['encryption_key'] as String;
      final keyBytes = base64Decode(storedKey);
      _key = aes_lib.Key(Uint8List.fromList(keyBytes));
    } else {
      // 2. 새 키 생성 및 Supabase에 저장
      final random = Random.secure();
      final keyBytes = List<int>.generate(_keyLength, (_) => random.nextInt(256));
      _key = aes_lib.Key(Uint8List.fromList(keyBytes));

      // Supabase에 저장
      await _supabase.from('user_encryption_keys').insert({
        'user_id': userId,
        'encryption_key': base64Encode(keyBytes),
      });
    }

    _currentUserId = userId;
  }

  /// 초기화 여부 확인
  void _ensureInitialized() {
    if (_currentUserId == null || _key == null) {
      throw EncryptionException('EncryptionService가 초기화되지 않았습니다. initialize()를 먼저 호출하세요.');
    }
  }

  @override
  String? encrypt(String? plainText) {
    if (plainText == null) return null;
    _ensureInitialized();

    try {
      // 1. 랜덤 IV 생성
      final random = Random.secure();
      final ivBytes = List<int>.generate(_ivLength, (_) => random.nextInt(256));
      final iv = aes_lib.IV(Uint8List.fromList(ivBytes));

      // 2. AES-GCM 암호화
      final encrypter = aes_lib.Encrypter(
        aes_lib.AES(_key!, mode: aes_lib.AESMode.gcm),
      );
      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // 3. IV + Ciphertext (AuthTag 포함) → Base64
      final combined = Uint8List.fromList([
        ...ivBytes,
        ...encrypted.bytes,
      ]);

      return base64Encode(combined);
    } catch (e) {
      throw EncryptionException('암호화 실패', originalError: e);
    }
  }

  @override
  String? decrypt(String? cipherText) {
    if (cipherText == null) return null;
    _ensureInitialized();

    try {
      // 1. Base64 디코딩
      final combined = base64Decode(cipherText);

      // 2. IV와 Ciphertext 분리
      if (combined.length < _ivLength) {
        throw EncryptionException('잘못된 암호문 형식: 길이가 너무 짧습니다');
      }

      final ivBytes = combined.sublist(0, _ivLength);
      final encryptedBytes = combined.sublist(_ivLength);

      final iv = aes_lib.IV(Uint8List.fromList(ivBytes));
      final encrypted = aes_lib.Encrypted(Uint8List.fromList(encryptedBytes));

      // 3. AES-GCM 복호화
      final encrypter = aes_lib.Encrypter(
        aes_lib.AES(_key!, mode: aes_lib.AESMode.gcm),
      );
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      if (e is EncryptionException) rethrow;
      throw EncryptionException('복호화 실패: 암호문이 손상되었거나 키가 일치하지 않습니다', originalError: e);
    }
  }

  @override
  String? encryptDouble(double? value) {
    if (value == null) return null;
    return encrypt(value.toString());
  }

  @override
  double? decryptDouble(String? cipherText) {
    if (cipherText == null) return null;
    final decrypted = decrypt(cipherText);
    if (decrypted == null) return null;

    try {
      return double.parse(decrypted);
    } catch (e) {
      throw EncryptionException('복호화된 값을 double로 변환할 수 없습니다: $decrypted', originalError: e);
    }
  }

  @override
  String? encryptInt(int? value) {
    if (value == null) return null;
    return encrypt(value.toString());
  }

  @override
  int? decryptInt(String? cipherText) {
    if (cipherText == null) return null;
    final decrypted = decrypt(cipherText);
    if (decrypted == null) return null;

    try {
      return int.parse(decrypted);
    } catch (e) {
      throw EncryptionException('복호화된 값을 int로 변환할 수 없습니다: $decrypted', originalError: e);
    }
  }

  @override
  String? encryptJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final jsonString = jsonEncode(json);
    return encrypt(jsonString);
  }

  @override
  Map<String, dynamic>? decryptJson(String? cipherText) {
    if (cipherText == null) return null;
    final decrypted = decrypt(cipherText);
    if (decrypted == null) return null;

    try {
      return jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (e) {
      throw EncryptionException('복호화된 값을 JSON으로 변환할 수 없습니다', originalError: e);
    }
  }

  @override
  String? encryptJsonList(List<dynamic>? jsonList) {
    if (jsonList == null) return null;
    final jsonString = jsonEncode(jsonList);
    return encrypt(jsonString);
  }

  @override
  List<dynamic>? decryptJsonList(String? cipherText) {
    if (cipherText == null) return null;
    final decrypted = decrypt(cipherText);
    if (decrypted == null) return null;

    try {
      return jsonDecode(decrypted) as List<dynamic>;
    } catch (e) {
      throw EncryptionException('복호화된 값을 JSON List로 변환할 수 없습니다', originalError: e);
    }
  }
}
