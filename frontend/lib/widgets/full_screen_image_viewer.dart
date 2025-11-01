import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Full screen image viewer
class FullScreenImageViewer extends StatelessWidget {
  final String? imageUrl;
  final Uint8List? imageBytes;

  const FullScreenImageViewer({
    super.key,
    this.imageUrl,
    this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Full screen image
          Center(
            child: _buildImage(),
          ),
          // Close button
          Positioned(
            top: AppTheme.spacingXL,
            right: AppTheme.spacingXL,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: AppTheme.iconColor,
                size: 32,
              ),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Close',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (imageBytes != null) {
      return Image.memory(
        imageBytes!,
        fit: BoxFit.contain,
      );
    } else if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.error_outline,
            color: AppTheme.iconColor,
            size: 64,
          );
        },
      );
    } else {
      return const Icon(
        Icons.image_not_supported,
        color: AppTheme.iconColor,
        size: 64,
      );
    }
  }
}
