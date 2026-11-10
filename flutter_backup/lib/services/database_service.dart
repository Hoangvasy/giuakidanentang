import '../models/user_model.dart';

/// Giao diện chuẩn cho dịch vụ Cơ sở dữ liệu (Abstract Database Service)
/// Cho phép linh hoạt chuyển đổi giữa Firebase Realtime Database, MongoDB,
/// hoặc Local Cache để chạy thử nghiệm.
abstract class DatabaseService {
  /// Lấy danh sách tất cả người dùng
  Future<List<UserModel>> fetchUsers();

  /// Thêm người dùng mới vào cơ sở dữ liệu
  /// Trả về đối tượng UserModel kèm ID vừa được cấp phát
  Future<UserModel?> addUser(UserModel user);

  /// Cập nhật thông tin người dùng theo ID
  Future<bool> updateUser(UserModel user);

  /// Xóa người dùng khỏi cơ sở dữ liệu theo ID
  Future<bool> deleteUser(String id);

  /// Xuất toàn bộ cơ sở dữ liệu thành chuỗi JSON (Dùng để nộp file JSON theo yêu cầu đề)
  Future<String> exportDatabaseJson();

  /// Nhập cơ sở dữ liệu từ chuỗi JSON
  Future<bool> importDatabaseJson(String jsonString);

  /// Kiểm tra trạng thái kết nối tới cơ sở dữ liệu
  Future<bool> testConnection();
}

