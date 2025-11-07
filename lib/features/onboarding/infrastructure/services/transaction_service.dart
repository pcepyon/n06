import 'package:isar/isar.dart';

/// Isar 트랜잭션을 관리하는 Service
class TransactionService {
  final Isar _isar;

  TransactionService(this._isar);

  /// 주어진 작업을 트랜잭션으로 실행한다.
  /// 작업 실패 시 자동으로 롤백된다.
  Future<T> executeInTransaction<T>(Future<T> Function() operation) async {
    return await _isar.writeTxn(() async {
      return await operation();
    });
  }
}
