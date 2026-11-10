import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';
import '../widgets/avatar_image.dart';

/// Hộp thoại Thêm / Chỉnh sửa Người dùng (Create / Update User Dialog)
/// Hỗ trợ cả giao diện Web (Hộp thoại Dialog lớn) và Mobile (Bottom Sheet / Dialog)
class UserFormDialog extends StatefulWidget {
  final UserModel? userToEdit;
  final Function(UserModel user) onSave;

  const UserFormDialog({
    super.key,
    this.userToEdit,
    required this.onSave,
  });

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _hotenController;
  late TextEditingController _emailController;
  late TextEditingController _matkhauController;
  late TextEditingController _hinhanhController;

  bool _obscurePassword = true;
  bool _isLoading = false;

  bool get isEditing => widget.userToEdit != null;

  @override
  void initState() {
    super.initState();
    final u = widget.userToEdit;
    _hotenController = TextEditingController(text: u?.hoten ?? '');
    _emailController = TextEditingController(text: u?.email ?? '');
    _matkhauController = TextEditingController(text: u?.matkhau ?? '');
    _hinhanhController = TextEditingController(
      text: u?.hinhanh ?? AppConstants.presetAvatars.first,
    );

    _hinhanhController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _hotenController.dispose();
    _emailController.dispose();
    _matkhauController.dispose();
    _hinhanhController.dispose();
    super.dispose();
  }

  /// Chọn ảnh từ Thư viện
  Future<void> _pickImageFromGallery() async {
    setState(() => _isLoading = true);
    final imageUri = await ImageHelper.pickImageFromGallery();
    if (imageUri != null) {
      _hinhanhController.text = imageUri;
    }
    setState(() => _isLoading = false);
  }

  /// Chụp ảnh từ Camera (Yêu cầu di động của đề bài)
  Future<void> _pickImageFromCamera() async {
    setState(() => _isLoading = true);
    final imageUri = await ImageHelper.pickImageFromCamera();
    if (imageUri != null) {
      _hinhanhController.text = imageUri;
    }
    setState(() => _isLoading = false);
  }

  /// Hiển thị bộ sưu tập ảnh avatar mẫu
  void _showPresetAvatars() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn ảnh đại diện mẫu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: AppConstants.presetAvatars.map((url) {
                  return InkWell(
                    onTap: () {
                      _hinhanhController.text = url;
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: AvatarImage(
                      imageSource: url,
                      radius: 28,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final user = UserModel(
      id: widget.userToEdit?.id ?? '',
      email: _emailController.text.trim(),
      matkhau: _matkhauController.text.trim(),
      hoten: _hotenController.text.trim(),
      hinhanh: _hinhanhController.text.trim(),
    );

    widget.onSave(user);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 550 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tiêu đề
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isEditing ? Icons.edit : Icons.person_add,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditing ? 'Sửa Thông Tin Người Dùng' : 'Thêm Người Dùng Mới',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Xem trước Avatar
                  Center(
                    child: Column(
                      children: [
                        AvatarImage(
                          imageSource: _hinhanhController.text,
                          fallbackName: _hotenController.text,
                          radius: 46,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.photo_library, size: 18),
                              label: const Text('Thư viện ảnh'),
                              onPressed: _isLoading ? null : _pickImageFromGallery,
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.camera_alt, size: 18),
                              label: const Text('Chụp ảnh'),
                              onPressed: _isLoading ? null : _pickImageFromCamera,
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.face, size: 18),
                              label: const Text('Avatar mẫu'),
                              onPressed: _showPresetAvatars,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. Trường Họ tên (hoten)
                  TextFormField(
                    controller: _hotenController,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên *',
                      hintText: 'Nhập họ và tên đầy đủ',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // 2. Trường Email (email)
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      hintText: 'example@gmail.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập địa chỉ email';
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Email không đúng định dạng';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Trường Mật khẩu (matkhau)
                  TextFormField(
                    controller: _matkhauController,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu *',
                      hintText: 'Nhập mật khẩu (tối thiểu 6 ký tự)',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.trim().length < 6) {
                        return 'Mật khẩu phải từ 6 ký tự trở lên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 4. Trường Hình ảnh (hinhanh - URL hoặc Base64)
                  TextFormField(
                    controller: _hinhanhController,
                    decoration: InputDecoration(
                      labelText: 'Đường dẫn ảnh (URL hoặc Base64) *',
                      hintText: 'https://...',
                      prefixIcon: const Icon(Icons.image_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: _hinhanhController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _hinhanhController.clear(),
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng cung cấp link hình ảnh hoặc chọn từ thư viện';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Nút thao tác
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Hủy'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: Icon(isEditing ? Icons.save : Icons.add),
                        label: Text(isEditing ? 'Cập nhật' : 'Thêm mới'),
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

