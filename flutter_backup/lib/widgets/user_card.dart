import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'avatar_image.dart';

/// Thẻ hiển thị thông tin từng người dùng trên Mobile / Grid Web
class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserCard({
    super.key,
    required this.user,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Ảnh đại diện người dùng
              AvatarImage(
                imageSource: user.hinhanh,
                fallbackName: user.hoten,
                radius: 28,
              ),
              const SizedBox(width: 14),

              // Thông tin Họ tên, Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.hoten.isNotEmpty ? user.hoten : '(Chưa có tên)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[700],
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.lock_outline, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '••••••••',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Menu thao tác (Sửa, Xóa, Xem)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'view') onView();
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 20, color: Colors.blue),
                        SizedBox(width: 10),
                        Text('Xem chi tiết'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20, color: Colors.orange),
                        SizedBox(width: 10),
                        Text('Sửa thông tin'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Xóa người dùng', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

