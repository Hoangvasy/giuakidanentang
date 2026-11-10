import 'package:flutter/material.dart';

/// Các hằng số cấu hình hệ thống
class AppConstants {
  // Tiêu đề ứng dụng
  static const String appName = 'Admin Quản Lý Người Dùng';
  static const String appVersion = '1.0.0 (Giữa Kỳ - Đa Nền Tảng)';

  // Key lưu trữ SharedPreferences
  static const String keyLoggedInUser = 'logged_in_user_email';
  static const String keyFirebaseUrl = 'firebase_database_url';
  static const String keyLocalUsersBackup = 'local_users_backup_data';
  static const String keyIsAdmin = 'is_admin_logged_in';

  // URL Firebase Realtime Database mặc định (Có thể thay đổi trong giao diện Cài đặt)
  // Quy ước Firebase Realtime Database REST API: [URL]/users.json
  static const String defaultFirebaseUrl =
      'https://danentang-giuaki-default-rtdb.asia-southeast1.firebasedatabase.app';

  // Tài khoản Admin mặc định để chấm bài và test nhanh
  static const String defaultAdminEmail = 'admin@gmail.com';
  static const String defaultAdminPassword = 'admin123';

  // Màu sắc chủ đạo (Material 3)
  static const Color primaryColor = Color(0xFF6750A4);
  static const Color secondaryColor = Color(0xFF625B71);
  static const Color surfaceColor = Color(0xFFFEF7FF);
  static const Color errorColor = Color(0xFFB3261E);
  static const Color successColor = Color(0xFF2E7D32);

  // Danh sách hình ảnh đại diện mẫu (để người dùng chọn nhanh)
  static const List<String> presetAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
  ];
}

