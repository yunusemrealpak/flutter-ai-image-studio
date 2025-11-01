import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Main canvas area for image editing
class EditorCanvas extends StatefulWidget {
  final String? imageUrl;
  final String? beforeImageUrl;

  const EditorCanvas({
    Key? key,
    this.imageUrl,
    this.beforeImageUrl,
  }) : super(key: key);

  @override
  State<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends State<EditorCanvas> {
  double _zoomLevel = 100.0;
  double _compareSliderPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark,
      padding: const EdgeInsets.all(AppTheme.spacingXXL),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: AppTheme.spacingL),
          Expanded(
            child: _buildImagePreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Greseel.raw',
          style: AppTheme.headingMedium,
        ),
        _buildHeaderMenu(),
      ],
    );
  }

  Widget _buildHeaderMenu() {
    return IconButton(
      icon: const Icon(
        Icons.more_vert,
        color: AppTheme.iconColor,
        size: 20,
      ),
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

            // Before/After comparison slider
            if (widget.beforeImageUrl != null && widget.imageUrl != null)
              _buildComparisonSlider(),

            // Bottom toolbar
            Positioned(
              bottom: AppTheme.spacingL,
              left: 0,
              right: 0,
              child: _buildBottomToolbar(),
            ),

            // Center compare button
            if (widget.beforeImageUrl != null && widget.imageUrl != null)
              _buildCenterCompareButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOrPlaceholder() {
    if (widget.imageUrl != null) {
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

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 80,
            color: AppTheme.iconColor.withOpacity(0.3),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'No image loaded',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSlider() {
    return Positioned.fill(
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _compareSliderPosition = (details.localPosition.dx /
                MediaQuery.of(context).size.width)
                .clamp(0.0, 1.0);
          });
        },
        child: Stack(
          children: [
            // Before image (clipped)
            Positioned.fill(
              child: ClipRect(
                clipper: _SliderClipper(_compareSliderPosition),
                child: Image.network(
                  widget.beforeImageUrl!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Slider line
            Positioned(
              left: MediaQuery.of(context).size.width * _compareSliderPosition,
              top: 0,
              bottom: 0,
              child: Container(
                width: 2,
                color: Colors.white,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.compare_arrows,
                      color: AppTheme.backgroundDark,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterCompareButton() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingL,
          vertical: AppTheme.spacingM,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        child: const Icon(
          Icons.compare,
          color: Colors.white,
          size: 24,
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
        child: Icon(
          icon,
          color: AppTheme.iconColor,
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
          const Icon(
            Icons.add,
            size: 12,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: AppTheme.spacingXS),
          Text(
            '${_zoomLevel.toInt()}%',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarDivider() {
    return Container(
      width: 1,
      height: 20,
      color: AppTheme.dividerColor,
    );
  }
}

/// Custom clipper for before/after comparison slider
class _SliderClipper extends CustomClipper<Rect> {
  final double position;

  _SliderClipper(this.position);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * position, size.height);
  }

  @override
  bool shouldReclip(_SliderClipper oldClipper) {
    return oldClipper.position != position;
  }
}
