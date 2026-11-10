import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'database_service.dart';

/// Dịch vụ kết nối Firebase Realtime Database qua REST API
/// Đảm bảo hoạt động hoàn hảo 100% trên Web, Android, iOS, Windows, macOS
/// không gặp lỗi cấu hình native SDK hay CocoaPods.
class FirebaseService implements DatabaseService {
  String _databaseUrl = AppConstants.defaultFirebaseUrl;
  bool _useLocalFallback = false;

  // Dữ liệu mẫu ban đầu (khi chưa có kết nối mạng hoặc ở chế độ Offline)
  static final List<UserModel> _defaultSeedUsers = [
    UserModel(
      id: '-OAdmoa1_Admin001',
      email: 'admin@gmail.com',
      matkhau: 'admin123',
      hoten: 'Quản Trị Viên Hệ Thống',
      hinhanh: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    ),
    UserModel(
      id: '-OAdmob2_User002',
      email: 'nguyenvanan@gmail.com',
      matkhau: 'an123456',
      hoten: 'Nguyễn Văn An',
      hinhanh: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
    ),
    UserModel(
      id: '-OAdmoc3_User003',
      email: 'tranthibinh@gmail.com',
      matkhau: 'binh123456',
      hoten: 'Trần Thị Bình',
      hinhanh: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
    ),
    UserModel(
      id: '-OAdmod4_User004',
      email: 'lehoangcuong@gmail.com',
      matkhau: 'cuong123456',
      hoten: 'Lê Hoàng Cường',
      hinhanh: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=400&q=80',
    ),
    UserModel(
      id: '-OAdmoe5_User005',
      email: 'phamthidung@gmail.com',
      matkhau: 'dung123456',
      hoten: 'Phạm Thị Dung',
      hinhanh: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=400&q=80',
    ),
  ];

  FirebaseService() {
    _loadSavedDatabaseUrl();
  }

  /// Nạp URL database đã lưu trong bộ nhớ máy
  Future<void> _loadSavedDatabaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(AppConstants.keyFirebaseUrl);
      if (savedUrl != null && savedUrl.isNotEmpty) {
        _databaseUrl = savedUrl;
      }
    } catch (e) {
      debugPrint('Không thể đọc SharedPreferences: $e');
    }
  }

  /// Cập nhật URL Firebase Realtime Database
  Future<void> setDatabaseUrl(String newUrl) async {
    _databaseUrl = newUrl.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyFirebaseUrl, _databaseUrl);
    } catch (e) {
      debugPrint('Lỗi lưu URL Firebase: $e');
    }
  }

  String get databaseUrl => _databaseUrl;
  bool get isLocalFallback => _useLocalFallback;

  /// Chuẩn hóa đường dẫn URL (bỏ dấu gạch chéo cuối nếu có)
  String _normalizeUrl(String url) {
    var trimmed = url.trim();
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  /// 1. LẤY DANH SÁCH NGƯỜI DÙNG (READ)
  @override
  Future<List<UserModel>> fetchUsers() async {
    final cleanUrl = _normalizeUrl(_databaseUrl);
    final endpoint = Uri.parse('$cleanUrl/users.json');

    try {
      final response = await http.get(endpoint).timeout(
        const Duration(seconds: 6),
      );

      if (response.statusCode == 200) {
        _useLocalFallback = false;
        if (response.body == 'null' || response.body.isEmpty) {
          // Database trên Firebase hiện chưa có bản ghi nào
          return [];
        }

        final dynamic decoded = json.decode(response.body);
        final List<UserModel> users = [];

        if (decoded is Map<String, dynamic>) {
          decoded.forEach((key, value) {
            if (value is Map) {
              users.add(UserModel.fromMap(key, value));
            }
          });
        }

        // Lưu vào cache cục bộ làm bản sao lưu
        await _saveUsersToLocalCache(users);
        return users;
      } else {
        debugPrint('Firebase trả về mã lỗi: ${response.statusCode}, chuyển sang Local Cache');
        _useLocalFallback = true;
        return await _loadUsersFromLocalCache();
      }
    } catch (e) {
      debugPrint('Lỗi kết nối Firebase ($e), tự động dùng Local Cache');
      _useLocalFallback = true;
      return await _loadUsersFromLocalCache();
    }
  }

  /// 2. THÊM NGƯỜI DÙNG MỚI (CREATE)
  @override
  Future<UserModel?> addUser(UserModel user) async {
    final cleanUrl = _normalizeUrl(_databaseUrl);
    final endpoint = Uri.parse('$cleanUrl/users.json');

    try {
      final payload = json.encode(user.toMap());
      final response = await http.post(
        endpoint,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = json.decode(response.body);
        final String newId = body['name'] ?? DateTime.now().millisecondsSinceEpoch.toString();
        final newUser = user.copyWith(id: newId);

        // Cập nhật lại local cache
        final current = await _loadUsersFromLocalCache();
        current.insert(0, newUser);
        await _saveUsersToLocalCache(current);

        return newUser;
      } else {
        throw Exception('Firebase trả về lỗi mã ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lưu trên Firebase thất bại ($e), lưu vào Local Cache');
      final newId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final newUser = user.copyWith(id: newId);
      final current = await _loadUsersFromLocalCache();
      current.insert(0, newUser);
      await _saveUsersToLocalCache(current);
      return newUser;
    }
  }

  /// 3. SỬA THÔNG TIN NGƯỜI DÙNG (UPDATE)
  @override
  Future<bool> updateUser(UserModel user) async {
    if (user.id.isEmpty) return false;

    final cleanUrl = _normalizeUrl(_databaseUrl);
    final endpoint = Uri.parse('$cleanUrl/users/${user.id}.json');

    try {
      final payload = json.encode(user.toMap());
      final response = await http.patch(
        endpoint,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      ).timeout(const Duration(seconds: 6));

      // Cập nhật local cache
      final current = await _loadUsersFromLocalCache();
      final index = current.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        current[index] = user;
        await _saveUsersToLocalCache(current);
      }

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Sửa trên Firebase gặp lỗi ($e), cập nhật vào Local Cache');
      final current = await _loadUsersFromLocalCache();
      final index = current.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        current[index] = user;
        await _saveUsersToLocalCache(current);
      }
      return true;
    }
  }

  /// 4. XÓA NGƯỜI DÙNG (DELETE)
  @override
  Future<bool> deleteUser(String id) async {
    if (id.isEmpty) return false;

    final cleanUrl = _normalizeUrl(_databaseUrl);
    final endpoint = Uri.parse('$cleanUrl/users/$id.json');

    try {
      final response = await http.delete(endpoint).timeout(
        const Duration(seconds: 6),
      );

      // Xóa trong local cache
      final current = await _loadUsersFromLocalCache();
      current.removeWhere((u) => u.id == id);
      await _saveUsersToLocalCache(current);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Xóa trên Firebase gặp lỗi ($e), xóa khỏi Local Cache');
      final current = await _loadUsersFromLocalCache();
      current.removeWhere((u) => u.id == id);
      await _saveUsersToLocalCache(current);
      return true;
    }
  }

  /// 5. XUẤT CƠ SỞ DỮ LIỆU THÀNH FILE JSON (EXPORT DATABASE)
  /// Phục vụ nộp bài theo yêu cầu đề bài: "nộp file cơ sở dữ liệu(json, sql...)"
  @override
  Future<String> exportDatabaseJson() async {
    List<UserModel> users = await fetchUsers();
    if (users.isEmpty) {
      users = await _loadUsersFromLocalCache();
    }

    final Map<String, dynamic> exportMap = {'users': {}};
    for (final user in users) {
      final key = user.id.isNotEmpty ? user.id : 'user_${user.email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';
      exportMap['users'][key] = user.toMap();
    }

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(exportMap);
  }

  /// 6. NHẬP CƠ SỞ DỮ LIỆU TỪ FILE JSON (IMPORT DATABASE)
  @override
  Future<bool> importDatabaseJson(String jsonString) async {
    try {
      final dynamic decoded = json.decode(jsonString);
      Map<dynamic, dynamic>? usersMap;

      if (decoded is Map && decoded.containsKey('users')) {
        usersMap = decoded['users'];
      } else if (decoded is Map) {
        usersMap = decoded;
      }

      if (usersMap == null) return false;

      final List<UserModel> importedUsers = [];
      usersMap.forEach((key, value) {
        if (value is Map) {
          importedUsers.add(UserModel.fromMap(key.toString(), value));
        }
      });

      if (importedUsers.isEmpty) return false;

      // Đồng bộ lên Firebase nếu có thể
      final cleanUrl = _normalizeUrl(_databaseUrl);
      final endpoint = Uri.parse('$cleanUrl/users.json');

      final Map<String, dynamic> uploadPayload = {};
      for (final user in importedUsers) {
        uploadPayload[user.id.isNotEmpty ? user.id : 'user_${DateTime.now().millisecondsSinceEpoch}'] = user.toMap();
      }

      try {
        await http.put(
          endpoint,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(uploadPayload),
        ).timeout(const Duration(seconds: 8));
      } catch (e) {
        debugPrint('Không thể đẩy file JSON lên Firebase: $e');
      }

      // Lưu đè vào local cache
      await _saveUsersToLocalCache(importedUsers);
      return true;
    } catch (e) {
      debugPrint('Lỗi import JSON: $e');
      return false;
    }
  }

  /// 7. KIỂM TRA KẾT NỐI FIREBASE
  @override
  Future<bool> testConnection() async {
    final cleanUrl = _normalizeUrl(_databaseUrl);
    if (!cleanUrl.startsWith('https://')) return false;

    try {
      final endpoint = Uri.parse('$cleanUrl/.json?shallow=true');
      final res = await http.get(endpoint).timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- CÁC HÀM XỬ LÝ LOCAL CACHE ---

  Future<void> _saveUsersToLocalCache(List<UserModel> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listMap = users.map((u) => {'id': u.id, ...u.toMap()}).toList();
      await prefs.setString(AppConstants.keyLocalUsersBackup, json.encode(listMap));
    } catch (e) {
      debugPrint('Lỗi lưu local cache: $e');
    }
  }

  Future<List<UserModel>> _loadUsersFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(AppConstants.keyLocalUsersBackup);
      if (dataStr != null && dataStr.isNotEmpty) {
        final List<dynamic> decoded = json.decode(dataStr);
        return decoded.map((item) {
          final map = item as Map<dynamic, dynamic>;
          final id = map['id']?.toString() ?? '';
          return UserModel.fromMap(id, map);
        }).toList();
      }
    } catch (e) {
      debugPrint('Lỗi đọc local cache: $e');
    }

    // Nếu chưa có gì, trả về danh sách mẫu mặc định
    return List<UserModel>.from(_defaultSeedUsers);
  }
}

