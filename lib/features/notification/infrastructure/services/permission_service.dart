import 'package:permission_handler/permission_handler.dart';

/// 디바이스 알림 권한 관리 서비스
class PermissionService {
  /// 알림 권한 확인
  Future<bool> checkPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// 알림 권한 요청
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// 앱 설정 열기
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}
