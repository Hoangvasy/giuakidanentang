import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'database_service.dart';

/// Dịch vụ Xác thực và Quản lý phiên đăng nhập Admin
/// Yêu cầu số 2 của đề thi: "Thực hiện đăng nhập, xóa, sửa, các chức năng nâng cao khác..."
class AuthService {
  /// Đăng nhập hệ thống Admin
  /// Chấp nhận tài khoản Admin hệ thống hoặc tài khoản người dùng có sẵn trong CSDL
  static Future<bool> login({
    required String email,
    required String password,
    required DatabaseService dbService,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    // 1. Kiểm tra tài khoản Admin mặc định
    if (cleanEmail == AppConstants.defaultAdminEmail.toLowerCase() &&
        cleanPassword == AppConstants.defaultAdminPassword) {
      await _saveSession(cleanEmail, true);
      return true;
    }

    // 2. Kiểm tra trong danh sách người dùng của Cơ sở dữ liệu
    try {
      final List<UserModel> users = await dbService.fetchUsers();
      final matchedUser = users.firstWhere(
        (u) =>
            u.email.trim().toLowerCase() == cleanEmail &&
            u.matkhau.trim() == cleanPassword,
        orElse: () => UserModel(email: '', matkhau: '', hoten: '', hinhanh: ''),
      );

      if (matchedUser.email.isNotEmpty) {
        await _saveSession(cleanEmail, true);
        return true;
      }
    } catch (e) {
      debugPrint('Lỗi xác thực đăng nhập: $e');
    }

    return false;
  }

  /// Lưu trạng thái phiên làm việc vào SharedPreferences
  static Future<void> _saveSession(String email, bool isAdmin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyLoggedInUser, email);
      await prefs.setBool(AppConstants.keyIsAdmin, isAdmin);
    } catch (e) {
      debugPrint('Lỗi lưu session: $e');
    }
  }

  /// Kiểm tra xem người dùng đã đăng nhập hay chưa
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = prefs.getString(AppConstants.keyLoggedInUser);
      return user != null && user.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Lấy email của người dùng đang đăng nhập
  static Future<String?> getCurrentUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.keyLoggedInUser);
    } catch (e) {
      return null;
    }
  }

  /// Đăng xuất khỏi hệ thống
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyLoggedInUser);
      await prefs.remove(AppConstants.keyIsAdmin);
    } catch (e) {
      debugPrint('Lỗi đăng xuất: $e');
    }
  }
}

