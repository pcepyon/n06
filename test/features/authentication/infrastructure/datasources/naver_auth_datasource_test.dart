import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/authentication/infrastructure/datasources/naver_auth_datasource.dart';

void main() {
  group('NaverAuthDataSource', () {
    late NaverAuthDataSource dataSource;

    setUp(() {
      dataSource = NaverAuthDataSource();
    });

    group('method signatures', () {
      test('should define login method', () {
        expect(dataSource.login, isA<Function>());
      });

      test('should define logout method', () {
        expect(dataSource.logout, isA<Function>());
      });

      test('should define getUser method', () {
        expect(dataSource.getUser, isA<Function>());
      });

      test('should define getCurrentToken method', () {
        expect(dataSource.getCurrentToken, isA<Function>());
      });
    });

    group('implementation', () {
      test('should be instance of NaverAuthDataSource', () {
        expect(dataSource, isA<NaverAuthDataSource>());
      });
    });
  });
}
