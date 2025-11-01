import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui';

import 'package:before_after/before_after.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_theme.dart';
import 'full_screen_image_viewer.dart';

/// Main canvas area for image editing
class EditorCanvas extends StatefulWidget {
  final String? imageUrl;
  final String? beforeImageUrl;
  final Uint8List? selectedImageBytes;
  final bool isProcessing;
  final int progress;
  final VoidCallback? onImagePick;

  const EditorCanvas({
    super.key,
    this.imageUrl,
    this.beforeImageUrl,
    this.selectedImageBytes,
    this.isProcessing = false,
    this.progress = 0,
    this.onImagePick,
  });

  @override
  State<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends State<EditorCanvas> {
  double _zoomLevel = 100.0;
  double _value = 0.5;
  bool _showBeforeAfter = false;

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
        const Text('', style: AppTheme.headingMedium),
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

            // Processing overlay (blur + animation)
            // Show when processing and we have an image to show (either new upload or existing job)
            if (widget.isProcessing &&
                (widget.selectedImageBytes != null ||
                    widget.beforeImageUrl != null))
              _buildProcessingOverlay(),

            // Before/After toggle button (only show when both images available)
            if (widget.beforeImageUrl != null && widget.imageUrl != null)
              Positioned(
                top: AppTheme.spacingL,
                right: AppTheme.spacingL,
                child: _buildBeforeAfterToggle(),
              ),

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
    // Show before/after comparison if enabled and both images are available
    if (widget.beforeImageUrl != null &&
        widget.imageUrl != null &&
        _showBeforeAfter) {
      return _buildBeforeAfterComparison();
    }

    // Priority: selectedImageBytes > imageUrl > placeholder
    Widget imageWidget;
    if (widget.selectedImageBytes != null) {
      imageWidget = Image.memory(
        widget.selectedImageBytes!,
        fit: BoxFit.contain,
      );
    } else if (widget.imageUrl != null) {
      imageWidget = Image.network(
        widget.imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
      return _buildPlaceholder();
    }

    // Center image with zoom applied via Transform.scale
    final scale = _zoomLevel / 100.0;
    return Center(
      child: Transform.scale(scale: scale, child: imageWidget),
    );
  }

  Widget _buildBeforeAfterComparison() {
    final scale = _zoomLevel / 100.0;
    return Center(
      child: Transform.scale(
        scale: scale,
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
      ),
    );
  }

  Widget _buildBeforeAfterToggle() {
    return Container(
      decoration: BoxDecoration(
        color: _showBeforeAfter
            ? AppTheme.primaryBlue
            : AppTheme.surfaceDarker.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: _showBeforeAfter
              ? AppTheme.primaryBlue
              : AppTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _showBeforeAfter = !_showBeforeAfter;
              // Reset slider position when toggling
              if (_showBeforeAfter) {
                _value = 0.5;
              }
            });
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingL,
              vertical: AppTheme.spacingM,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.compare,
                  color: _showBeforeAfter
                      ? Colors.white
                      : AppTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  _showBeforeAfter ? 'Hide Compare' : 'Compare',
                  style: AppTheme.bodySmall.copyWith(
                    color: _showBeforeAfter
                        ? Colors.white
                        : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
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
    final bool hasImage =
        widget.imageUrl != null || widget.selectedImageBytes != null;

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
            _buildToolbarButton(
              Icons.remove,
              () => _handleZoomOut(),
              enabled: hasImage,
            ),
            const SizedBox(width: AppTheme.spacingS),
            _buildZoomIndicator(),
            const SizedBox(width: AppTheme.spacingS),
            _buildToolbarButton(
              Icons.add,
              () => _handleZoomIn(),
              enabled: hasImage,
            ),
            const SizedBox(width: AppTheme.spacingL),
            _buildToolbarDivider(),
            const SizedBox(width: AppTheme.spacingL),
            _buildToolbarButton(
              Icons.download,
              _handleDownload,
              enabled: widget.imageUrl != null,
            ),
            const SizedBox(width: AppTheme.spacingL),
            _buildToolbarDivider(),
            const SizedBox(width: AppTheme.spacingL),
            _buildToolbarButton(
              Icons.fullscreen,
              () => _handleFullScreen(),
              enabled: hasImage,
            ),
            const SizedBox(width: AppTheme.spacingL),
            _buildToolbarDivider(),
            const SizedBox(width: AppTheme.spacingL),
            _buildToolbarButton(
              Icons.fit_screen,
              () => _handleFitScreen(),
              enabled: hasImage,
            ),
          ],
        ),
      ),
    );
  }

  void _handleZoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 10).clamp(10, 500);
    });
  }

  void _handleZoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 10).clamp(10, 500);
    });
  }

  void _handleFitScreen() {
    setState(() {
      _zoomLevel = 100.0;
    });
  }

  void _handleFullScreen() {
    // Get current image to show in full screen
    String? imageUrl = widget.imageUrl;
    Uint8List? imageBytes = widget.selectedImageBytes;

    // Navigate to full screen viewer
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            FullScreenImageViewer(imageUrl: imageUrl, imageBytes: imageBytes),
      ),
    );
  }

  Future<void> _handleDownload() async {
    if (widget.imageUrl == null) return;

    try {
      // Download the image
      final response = await http.get(Uri.parse(widget.imageUrl!));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'edited_image.png')
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      // Ignore errors silently or show a snackbar if needed
      debugPrint('Download failed: $e');
    }
  }

  Widget _buildToolbarButton(
    IconData icon,
    VoidCallback? onTap, {
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppTheme.radiusS),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXS),
        child: Icon(
          icon,
          color: enabled
              ? AppTheme.iconColor
              : AppTheme.iconColor.withOpacity(0.3),
          size: 20,
        ),
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

  Widget _buildProcessingOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating circle
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                  // AI Icon
                  const Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: AppTheme.primaryBlue,
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
