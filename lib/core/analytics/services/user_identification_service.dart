import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/repositories/i_auth_repository.dart';
import 'device_info_service.dart';

/// 用户识别服务
/// 负责生成和管理用户标识符，支持登录用户和游客
class UserIdentificationService {
  final IAuthRepository _authRepository;
  final DeviceInfoService _deviceInfoService;
  final SharedPreferences _prefs;
  
  static const String _guestIdKey = 'analytics_guest_id';
  
  UserIdentificationService(
    this._authRepository,
    this._deviceInfoService,
    this._prefs,
  );

  /// 获取用户标识符
  /// 登录用户返回用户ID，游客返回设备生成的唯一标识
  Future<dynamic> getUserSign() async {
    try {
      // 尝试获取当前登录用户ID
      final result = await _authRepository.getCurrentUserId();
      
      return result.fold(
        (failure) async {
          // 获取失败，返回游客ID
          return await _getGuestId();
        },
        (userId) {
          // 获取成功，返回用户ID
          return int.tryParse(userId) ?? userId;
        },
      );
    } catch (e) {
      // 如果获取失败，返回游客ID
      return await _getGuestId();
    }
  }

  /// 获取游客ID
  Future<String> _getGuestId() async {
    // 尝试从本地存储获取已有的游客ID
    String? guestId = _prefs.getString(_guestIdKey);
    
    if (guestId == null || guestId.isEmpty) {
      // 如果没有，生成新的游客ID
      final deviceId = await _deviceInfoService.getDeviceId();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      guestId = 'guest_${deviceId}_$timestamp';
      
      // 保存到本地存储
      await _prefs.setString(_guestIdKey, guestId);
    }
    
    return guestId;
  }

  /// 检查当前是否为游客
  Future<bool> isGuest() async {
    try {
      final result = await _authRepository.getCurrentUserId();
      return result.isLeft(); // 如果获取失败，说明是游客
    } catch (e) {
      return true; // 默认认为是游客
    }
  }

  /// 获取当前用户ID（仅登录用户）
  Future<int?> getCurrentUserId() async {
    try {
      final result = await _authRepository.getCurrentUserId();
      return result.fold(
        (failure) => null,
        (userId) => int.tryParse(userId),
      );
    } catch (e) {
      return null;
    }
  }

  /// 清除游客标识（用户登录时调用）
  Future<void> clearGuestId() async {
    await _prefs.remove(_guestIdKey);
  }

  /// 生成格式化的用户标识符字符串
  /// 格式：user_[用户ID]_[时间戳] 或 guest_[设备ID]_[时间戳]
  Future<String> getFormattedUserSign() async {
    final userSign = await getUserSign();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    if (userSign is int) {
      // 登录用户
      return 'user_${userSign}_$timestamp';
    } else {
      // 游客用户，userSign已经是格式化的字符串
      return userSign.toString();
    }
  }
} 