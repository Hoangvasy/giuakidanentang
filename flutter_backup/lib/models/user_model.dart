import 'dart:convert';

/// MODEL DỮ LIỆU NGƯỜI DÙNG (USER MODEL)
///
/// LƯU Ý ĐẶC BIỆT CỦA ĐỀ THI:
/// "Chỉ chấp nhận cơ sở dữ liệu gồm các trường: email, matkhau, hoten, hinhanh
/// (không tự bổ sung thêm trường), bắt buộc phải nộp file cơ sở dữ liệu"
///
/// HƯỚNG DẪN KHI THẦY/CÔ ĐỔI CẤU TRÚC DATABASE (2 ngày trước khi thi):
/// Nếu đề thi thực tế yêu cầu các trường khác (ví dụ: masv, hoten, lop, hinhanh
/// hoặc tensp, gia, mota, hinhanh), bạn chỉ cần:
/// 1. Thay đổi hoặc thêm các biến final bên dưới.
/// 2. Cập nhật constructor, fromMap(), toMap(), toJson(), fromJson().
/// 3. Cập nhật các ô nhập liệu trong file `lib/screens/user_form_dialog.dart`.
class UserModel {
  /// Mã định danh trong cơ sở dữ liệu (Firebase push key / MongoDB _id)
  /// Thuộc tính này chỉ dùng để định tuyến và cập nhật/xóa trên App,
  /// không lưu thành 1 field bên trong payload theo đúng yêu cầu đề bài.
  final String id;

  /// Email người dùng (Bắt buộc theo đề)
  final String email;

  /// Mật khẩu người dùng (Bắt buộc theo đề)
  final String matkhau;

  /// Họ và tên người dùng (Bắt buộc theo đề)
  final String hoten;

  /// Đường dẫn hình ảnh hoặc dữ liệu Base64 (Bắt buộc theo đề)
  final String hinhanh;

  UserModel({
    this.id = '',
    required this.email,
    required this.matkhau,
    required this.hoten,
    required this.hinhanh,
  });

  /// Chuyển đổi từ Map (dữ liệu nhận từ Firebase Realtime Database / MongoDB JSON)
  factory UserModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email']?.toString() ?? '',
      matkhau: map['matkhau']?.toString() ?? '',
      hoten: map['hoten']?.toString() ?? '',
      hinhanh: map['hinhanh']?.toString() ?? '',
    );
  }

  /// Chuyển đối tượng thành Map để lưu vào Cơ sở dữ liệu
  /// ĐẢM BẢO CHỈ CHỨA ĐÚNG 4 TRƯỜNG THEO YÊU CẦU ĐỀ BÀI:
  /// email, matkhau, hoten, hinhanh
  Map<String, dynamic> toMap() {
    return {
      'email': email.trim(),
      'matkhau': matkhau,
      'hoten': hoten.trim(),
      'hinhanh': hinhanh.trim(),
    };
  }

  /// Chuyển đổi thành chuỗi JSON
  String toJson() => json.encode(toMap());

  /// Tạo đối tượng mới với các trường được chỉnh sửa (Immutable helper)
  UserModel copyWith({
    String? id,
    String? email,
    String? matkhau,
    String? hoten,
    String? hinhanh,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      matkhau: matkhau ?? this.matkhau,
      hoten: hoten ?? this.hoten,
      hinhanh: hinhanh ?? this.hinhanh,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, hoten: $hoten, hinhanh: $hinhanh)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.matkhau == matkhau &&
        other.hoten == hoten &&
        other.hinhanh == hinhanh;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        matkhau.hashCode ^
        hoten.hashCode ^
        hinhanh.hashCode;
  }
}

