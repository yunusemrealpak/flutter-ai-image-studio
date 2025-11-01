import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'custom_slider.dart';

/// Right side settings panel for image adjustments
class EditorSettingsPanel extends StatefulWidget {
  const EditorSettingsPanel({Key? key}) : super(key: key);

  @override
  State<EditorSettingsPanel> createState() => _EditorSettingsPanelState();
}

class _EditorSettingsPanelState extends State<EditorSettingsPanel> {
  bool _isBasicExpanded = true;

  // Adjustment values
  String _whiteBalance = 'Custom';
  double _temperature = 0.00;
  double _tint = 0.00;
  String _tone = 'Auto';
  double _exposure = 0.00;
  double _contrast = 0.00;
  double _highlight = 0.00;
  double _shadows = 0.00;
  double _saturation = 0.00;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTheme.settingsPanelWidth,
      color: AppTheme.settingsPanelBackground,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildAdjustments(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () => setState(() => _isBasicExpanded = !_isBasicExpanded),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.dividerColor, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isBasicExpanded
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_right,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: AppTheme.spacingS),
            const Text(
              'Basic',
              style: AppTheme.headingSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustments() {
    if (!_isBasicExpanded) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownSlider(
            label: 'White Balance',
            dropdownValue: _whiteBalance,
            dropdownOptions: const ['Auto', 'Custom', 'Daylight', 'Cloudy'],
            sliderValue: _temperature,
            min: -100,
            max: 100,
            onDropdownChanged: (value) {
              setState(() => _whiteBalance = value);
            },
            onSliderChanged: (value) {
              setState(() => _temperature = value);
            },
          ),
          CustomSlider(
            label: 'Temperature',
            value: _temperature,
            min: -100,
            max: 100,
            onChanged: (value) => setState(() => _temperature = value),
          ),
          CustomSlider(
            label: 'Tint',
            value: _tint,
            min: -100,
            max: 100,
            onChanged: (value) => setState(() => _tint = value),
          ),
          DropdownSlider(
            label: 'Tone',
            dropdownValue: _tone,
            dropdownOptions: const ['Auto', 'Manual', 'Preset 1', 'Preset 2'],
            sliderValue: _exposure,
            min: -100,
            max: 100,
            onDropdownChanged: (value) {
              setState(() => _tone = value);
            },
            onSliderChanged: (value) {
              setState(() => _exposure = value);
            },
          ),
          CustomSlider(
            label: 'Exposure',
            value: _exposure,
            min: -100,
            max: 100,
            onChanged: (value) => setState(() => _exposure = value),
          ),
          CustomSlider(
            label: 'Contrast',
            value: _contrast,
            min: -100,
            max: 100,
            onChanged: (value) => setState(() => _contrast = value),
          ),
          CustomSlider(
            label: 'Highlight',
            value: _highlight,
            min: -100,
            max: 100,
            onChanged: (value) => setState(() => _highlight = value),
          ),
          CustomSlider(
            label: 'Shadows',
            value: _shadows,
            min: -100,
            max: 100,
            onChanged: (value) => setState(() => _shadows = value),
          ),
          CustomSlider(
            label: 'Saturation',
            value: _saturation,
            min: -100,
            max: 100,
            onChanged: (value) => setState(() => _saturation = value),
          ),
          const SizedBox(height: AppTheme.spacingL),
          _buildToneCurve(),
        ],
      ),
    );
  }

  Widget _buildToneCurve() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tone Curve',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        _ToneCurveGraph(),
      ],
    );
  }
}

/// Tone curve visualization widget
class _ToneCurveGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDarker,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: CustomPaint(
        painter: _ToneCurvePainter(),
        child: Container(),
      ),
    );
  }
}

/// Custom painter for tone curve
class _ToneCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    final gridPaint = Paint()
      ..color = AppTheme.dividerColor.withOpacity(0.3)
      ..strokeWidth = 0.5;

    // Vertical grid lines
    for (int i = 0; i <= 4; i++) {
      final x = (size.width / 4) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw diagonal curve (default linear)
    final curvePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, curvePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
