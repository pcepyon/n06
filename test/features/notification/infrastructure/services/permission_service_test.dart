import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n06/features/notification/infrastructure/services/permission_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PermissionService', () {
    late PermissionService service;

    setUp(() {
      service = PermissionService();

      // Mock permission_handler platform channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        (call) async {
          switch (call.method) {
            case 'checkPermissionStatus':
              return 1; // PermissionStatus.granted
            case 'requestPermissions':
              // Returns Map<Permission, PermissionStatus>
              // We need to return granted for whatever permission is requested
              final permissions = call.arguments as List;
              final Map<int, int> result = {};
              for (var p in permissions) {
                result[p as int] = 1; // PermissionStatus.granted
              }
              return result;
            case 'openAppSettings':
              return true;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/permissions/methods'),
        null,
      );
    });

    test('should return true when notification permission is granted', () async {
      // Act
      final hasPermission = await service.checkPermission();

      // Assert
      expect(hasPermission, isA<bool>());
      expect(hasPermission, isTrue);
    });

    test('should attempt to request permission', () async {
      // Act
      final granted = await service.requestPermission();

      // Assert
      expect(granted, isA<bool>());
      expect(granted, isTrue);
    });

    test('should open app settings', () async {
      // Act
      final result = await service.openAppSettings();

      // Assert
      expect(result, isTrue);
    });
  });
}
