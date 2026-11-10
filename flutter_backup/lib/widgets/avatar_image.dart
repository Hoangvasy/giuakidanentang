import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../utils/image_helper.dart';

/// Widget hiển thị ảnh đại diện thông minh cho cả Web và Mobile
/// Tự động xử lý: URL mạng, chuỗi Base64, và Fallback khi ảnh lỗi
class AvatarImage extends StatelessWidget {
  final String imageSource;
  final String fallbackName;
  final double radius;
  final VoidCallback? onTap;

  const AvatarImage({
    super.key,
    required this.imageSource,
    this.fallbackName = '',
    this.radius = 24.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget;
    final cleanSource = imageSource.trim();

    if (cleanSource.isEmpty) {
      avatarWidget = _buildFallback(context);
    } else if (ImageHelper.isBase64Image(cleanSource)) {
      final Uint8List? bytes = ImageHelper.getBytesFromBase64(cleanSource);
      if (bytes != null && bytes.isNotEmpty) {
        avatarWidget = CircleAvatar(
          radius: radius,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage: MemoryImage(bytes),
        );
      } else {
        avatarWidget = _buildFallback(context);
      }
    } else if (cleanSource.startsWith('http://') || cleanSource.startsWith('https://')) {
      avatarWidget = CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: ClipOval(
          child: Image.network(
            cleanSource,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: SizedBox(
                  width: radius,
                  height: radius,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildFallback(context);
            },
          ),
        ),
      );
    } else {
      avatarWidget = _buildFallback(context);
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }

  Widget _buildFallback(BuildContext context) {
    final initials = ImageHelper.getInitials(fallbackName);
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        initials,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.75,
        ),
      ),
    );
  }
}

