import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Tiện ích hỗ trợ chọn và xử lý hình ảnh cho Web & Mobile
class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Chọn hình ảnh từ Thư viện ảnh (Gallery)
  /// Trả về chuỗi URL hoặc Data URI Base64 ("data:image/jpeg;base64,...")
  static Future<String?> pickImageFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
      );
      if (file == null) return null;

      final Uint8List bytes = await file.readAsBytes();
      final String base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint('Lỗi khi chọn ảnh từ thư viện: $e');
      return null;
    }
  }

  /// Chụp ảnh từ Camera (Dành riêng cho thiết bị Di động)
  /// Yêu cầu số 3 của đề bài: "Nhập được hình ảnh và hiển thị thông tin người dùng (trên nền tảng di động)"
  static Future<String?> pickImageFromCamera() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
      );
      if (file == null) return null;

      final Uint8List bytes = await file.readAsBytes();
      final String base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint('Lỗi khi chụp ảnh từ camera: $e');
      return null;
    }
  }

  /// Kiểm tra xem chuỗi có phải là chuỗi hình ảnh Base64 hay không
  static bool isBase64Image(String input) {
    return input.startsWith('data:image') ||
        (input.length > 100 && !input.startsWith('http'));
  }

  /// Lấy bytes từ chuỗi Base64
  static Uint8List? getBytesFromBase64(String input) {
    try {
      String cleanBase64 = input;
      if (input.contains(',')) {
        cleanBase64 = input.split(',').last;
      }
      return base64Decode(cleanBase64);
    } catch (e) {
      debugPrint('Lỗi giải mã Base64: $e');
      return null;
    }
  }

  /// Lấy chữ cái đại diện từ Họ tên người dùng (Avatar Fallback)
  static String getInitials(String fullName) {
    if (fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

