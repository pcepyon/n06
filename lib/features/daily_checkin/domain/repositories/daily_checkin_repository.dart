import '../entities/daily_checkin.dart';

/// 데일리 체크인 저장소 인터페이스
///
/// 이 Repository는 daily_checkins 테이블을 관리합니다.
/// 사용자의 일상적 컨디션 체크인 데이터를 저장하고 조회합니다.
///
/// Repository Pattern에 따라 단일 구현체를 통해 데이터 접근을 추상화합니다.
/// Current: SupabaseDailyCheckinRepository (cloud-first architecture)
///
abstract class DailyCheckinRepository {
  /// 데일리 체크인 저장
  ///
  /// 동일한 날짜(checkin_date)에 이미 체크인이 존재하면
  /// UNIQUE 제약으로 인해 에러가 발생합니다.
  /// 같은 날짜의 체크인을 수정하려면 기존 체크인을 먼저 삭제하거나
  /// 업데이트 로직을 별도로 구현해야 합니다.
  Future<DailyCheckin> save(DailyCheckin checkin);

  /// 특정 날짜의 체크인 조회
  ///
  /// 해당 날짜에 체크인이 없으면 null을 반환합니다.
  Future<DailyCheckin?> getByDate(String userId, DateTime date);

  /// 날짜 범위로 체크인 목록 조회
  ///
  /// start와 end를 포함한 범위의 체크인을 반환합니다.
  /// 날짜 내림차순으로 정렬됩니다 (최근 것이 먼저).
  Future<List<DailyCheckin>> getByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  );

  /// 가장 최근 체크인 조회
  ///
  /// 체크인 기록이 없으면 null을 반환합니다.
  Future<DailyCheckin?> getLatest(String userId);

  /// 연속 체크인 일수 계산
  ///
  /// 오늘 기준으로 연속으로 체크인한 일수를 계산합니다.
  /// 오늘 체크인이 없으면 0을 반환합니다.
  ///
  /// 연속 기록 판정 정책 (spec 7.2절):
  /// - 체크인 완료 = 6개 질문 응답 완료
  /// - 체중 입력 여부는 연속성에 영향 없음
  Future<int> getConsecutiveDays(String userId);

  /// 체크인 삭제
  ///
  /// id에 해당하는 체크인을 삭제합니다.
  Future<void> delete(String id);
}
