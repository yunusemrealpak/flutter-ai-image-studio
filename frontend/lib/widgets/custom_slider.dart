import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Custom slider widget for adjustment controls
class CustomSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final int? divisions;

  const CustomSlider({
    Key? key,
    required this.label,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    required this.onChanged,
    this.divisions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabelRow(),
          const SizedBox(height: AppTheme.spacingS),
          _buildSlider(),
        ],
      ),
    );
  }

  Widget _buildLabelRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value.toStringAsFixed(2),
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSlider() {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 2,
        activeTrackColor: AppTheme.accentOrange,
        inactiveTrackColor: AppTheme.dividerColor,
        thumbColor: Colors.white,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayColor: AppTheme.accentOrange.withOpacity(0.2),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}

/// Dropdown slider widget (combines dropdown + slider)
class DropdownSlider extends StatelessWidget {
  final String label;
  final String dropdownValue;
  final List<String> dropdownOptions;
  final double sliderValue;
  final double min;
  final double max;
  final ValueChanged<String> onDropdownChanged;
  final ValueChanged<double> onSliderChanged;

  const DropdownSlider({
    Key? key,
    required this.label,
    required this.dropdownValue,
    required this.dropdownOptions,
    required this.sliderValue,
    this.min = 0.0,
    this.max = 100.0,
    required this.onDropdownChanged,
    required this.onSliderChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabelRow(),
          const SizedBox(height: AppTheme.spacingS),
          CustomSlider(
            label: '',
            value: sliderValue,
            min: min,
            max: max,
            onChanged: onSliderChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLabelRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        _buildDropdown(),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDarker,
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      child: DropdownButton<String>(
        value: dropdownValue,
        onChanged: (value) {
          if (value != null) onDropdownChanged(value);
        },
        items: dropdownOptions
            .map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(
                    option,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ))
            .toList(),
        underline: const SizedBox.shrink(),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        isDense: true,
        dropdownColor: AppTheme.surfaceDarker,
      ),
    );
  }
}
