import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../widgets/avatar_image.dart';

/// Hộp thoại Xem chi tiết người dùng
class UserDetailDialog extends StatefulWidget {
  final UserModel user;
  final VoidCallback onEdit;

  const UserDetailDialog({
    super.key,
    required this.user,
    required this.onEdit,
  });

  @override
  State<UserDetailDialog> createState() => _UserDetailDialogState();
}

class _UserDetailDialogState extends State<UserDetailDialog> {
  bool _showPassword = false;

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label vào bộ nhớ tạm'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 500 : double.infinity,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Thông Tin Người Dùng',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Ảnh đại diện
              AvatarImage(
                imageSource: user.hinhanh,
                fallbackName: user.hoten,
                radius: 54,
              ),
              const SizedBox(height: 16),

              Text(
                user.hoten,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Danh sách thông tin chi tiết
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Email
                    _buildInfoRow(
                      context,
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: user.email,
                      onCopy: () => _copyToClipboard(user.email, 'Email'),
                    ),
                    const Divider(height: 20),

                    // Mật khẩu
                    _buildInfoRow(
                      context,
                      icon: Icons.lock_outline,
                      label: 'Mật khẩu',
                      value: _showPassword ? user.matkhau : '••••••••',
                      trailing: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                      onCopy: () => _copyToClipboard(user.matkhau, 'Mật khẩu'),
                    ),
                    const Divider(height: 20),

                    // Database Key ID
                    _buildInfoRow(
                      context,
                      icon: Icons.key_outlined,
                      label: 'ID CSDL',
                      value: user.id.isNotEmpty ? user.id : '(Chưa có ID)',
                      onCopy: user.id.isNotEmpty
                          ? () => _copyToClipboard(user.id, 'ID')
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nút chỉnh sửa
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Đóng'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Sửa thông tin'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onEdit();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
    VoidCallback? onCopy,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        if (trailing != null) trailing,
        if (onCopy != null)
          IconButton(
            icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
            tooltip: 'Sao chép',
            onPressed: onCopy,
          ),
      ],
    );
  }
}

