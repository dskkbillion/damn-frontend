import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:injectable/injectable.dart';

/// 设备信息服务
/// 负责获取设备相关信息用于埋点
@injectable
class DeviceInfoService {

  /// 获取设备信息
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      return {
        'branch': _getPlatformBranch(),
        'buildNumber': int.tryParse(packageInfo.buildNumber) ?? 1,
        'deviceId': _getBasicDeviceId(),
        'deviceName': _getDeviceName(),
        'appVersion': packageInfo.version,
        'platform': Platform.operatingSystem,
        'packageName': packageInfo.packageName,
      };
    } catch (e) {
      // 如果获取失败，返回基本信息
      return {
        'branch': _getPlatformBranch(),
        'buildNumber': 1,
        'deviceId': 'unknown',
        'deviceName': 'unknown',
        'platform': Platform.operatingSystem,
        'error': e.toString(),
      };
    }
  }

  /// 获取平台品牌
  String _getPlatformBranch() {
    if (Platform.isIOS) {
      return 'Apple';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isWindows) {
      return 'Microsoft';
    } else if (Platform.isMacOS) {
      return 'Apple';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else {
      return 'Web';
    }
  }

  /// 获取基本设备ID
  String _getBasicDeviceId() {
    // 这里返回平台标识，在生产环境中应该使用更复杂的设备标识
    return '${Platform.operatingSystem}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 获取设备名称
  String _getDeviceName() {
    if (Platform.isIOS) {
      return 'iOS Device';
    } else if (Platform.isAndroid) {
      return 'Android Device';
    } else if (Platform.isWindows) {
      return 'Windows Device';
    } else if (Platform.isMacOS) {
      return 'macOS Device';
    } else if (Platform.isLinux) {
      return 'Linux Device';
    } else {
      return 'Web Device';
    }
  }

  /// 获取设备唯一标识符
  Future<String> getDeviceId() async {
    // 简化版本，生产环境应该使用更可靠的设备标识
    return _getBasicDeviceId();
  }
} 