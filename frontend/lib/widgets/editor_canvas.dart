import 'dart:typed_data';

import 'package:before_after/before_after.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Main canvas area for image editing
class EditorCanvas extends StatefulWidget {
  final String? imageUrl;
  final String? beforeImageUrl;
  final Uint8List? selectedImageBytes;
  final VoidCallback? onImagePick;

  const EditorCanvas({
    super.key,
    this.imageUrl,
    this.beforeImageUrl,
    this.selectedImageBytes,
    this.onImagePick,
  });

  @override
  State<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends State<EditorCanvas> {
  double _zoomLevel = 100.0;
  double _value = 0.1;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark,
      padding: const EdgeInsets.all(AppTheme.spacingXXL),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: AppTheme.spacingL),
          Expanded(child: _buildImagePreview()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Greseel.raw', style: AppTheme.headingMedium),
        _buildHeaderMenu(),
      ],
    );
  }

  Widget _buildHeaderMenu() {
    return IconButton(
      icon: const Icon(Icons.more_vert, color: AppTheme.iconColor, size: 20),
      onPressed: () {},
      tooltip: 'More options',
    );
  }

  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        child: Stack(
          children: [
            // Main image or placeholder
            _buildImageOrPlaceholder(),

            // Bottom toolbar
            Positioned(
              bottom: AppTheme.spacingL,
              left: 0,
              right: 0,
              child: _buildBottomToolbar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOrPlaceholder() {
    // Show before/after comparison if both images are available
    if (widget.beforeImageUrl != null && widget.imageUrl != null) {
      return _buildBeforeAfterComparison();
    }

    // Priority: selectedImageBytes > imageUrl > placeholder
    if (widget.selectedImageBytes != null) {
      return Center(
        child: Image.memory(widget.selectedImageBytes!, fit: BoxFit.contain),
      );
    } else if (widget.imageUrl != null) {
      return Center(
        child: Image.network(
          widget.imageUrl!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildBeforeAfterComparison() {
    return Center(
      child: BeforeAfter(
        value: _value,
        before: Image.network(
          widget.beforeImageUrl!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppTheme.surfaceDarker,
              child: const Center(
                child: Icon(
                  Icons.error_outline,
                  color: AppTheme.iconColor,
                  size: 48,
                ),
              ),
            );
          },
        ),
        after: Image.network(
          widget.imageUrl!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppTheme.surfaceDarker,
              child: const Center(
                child: Icon(
                  Icons.error_outline,
                  color: AppTheme.iconColor,
                  size: 48,
                ),
              ),
            );
          },
        ),
        trackWidth: 4,
        trackColor: Colors.white,
        thumbDecoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.dividerColor, width: 2),
          shape: BoxShape.circle,
        ),
        onValueChanged: (value) {
          setState(() {
            _value = value;
          });
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return InkWell(
      onTap: widget.onImagePick,
      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.surfaceDarker,
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                border: Border.all(
                  color: AppTheme.dividerColor,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.add_photo_alternate_outlined,
                size: 48,
                color: AppTheme.iconColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXXL),
            Text(
              'Click to upload an image',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Supported formats: PNG, JPG, WEBP',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingL,
          vertical: AppTheme.spacingM,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDarker.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToolbarButton(Icons.remove, () {
              setState(() => _zoomLevel = (_zoomLevel - 10).clamp(10, 500));
            }),
            const SizedBox(width: AppTheme.spacingS),
            _buildZoomIndicator(),
            const SizedBox(width: AppTheme.spacingS),
            _buildToolbarButton(Icons.add, () {
              setState(() => _zoomLevel = (_zoomLevel + 10).clamp(10, 500));
            }),
            const SizedBox(width: AppTheme.spacingL),
            _buildToolbarDivider(),
            const SizedBox(width: AppTheme.spacingL),
            _buildToolbarButton(Icons.fit_screen, () {}),
            const SizedBox(width: AppTheme.spacingL),
            _buildToolbarDivider(),
            const SizedBox(width: AppTheme.spacingL),
            _buildToolbarButton(Icons.undo, () {}),
            const SizedBox(width: AppTheme.spacingS),
            _buildToolbarButton(Icons.redo, () {}),
            const SizedBox(width: AppTheme.spacingL),
            _buildToolbarDivider(),
            const SizedBox(width: AppTheme.spacingL),
            _buildToolbarButton(Icons.rotate_right, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusS),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXS),
        child: Icon(icon, color: AppTheme.iconColor, size: 20),
      ),
    );
  }

  Widget _buildZoomIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Row(
        children: [
          const Icon(Icons.add, size: 12, color: AppTheme.textSecondary),
          const SizedBox(width: AppTheme.spacingXS),
          Text(
            '${_zoomLevel.toInt()}%',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarDivider() {
    return Container(width: 1, height: 20, color: AppTheme.dividerColor);
  }
}
