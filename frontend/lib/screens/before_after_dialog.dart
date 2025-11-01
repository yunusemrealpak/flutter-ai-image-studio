import 'package:flutter/material.dart';

/// Before/After comparison dialog with slider
class BeforeAfterDialog extends StatefulWidget {
  final String originalImageUrl;
  final String editedImageUrl;

  const BeforeAfterDialog({
    Key? key,
    required this.originalImageUrl,
    required this.editedImageUrl,
  }) : super(key: key);

  @override
  State<BeforeAfterDialog> createState() => _BeforeAfterDialogState();
}

class _BeforeAfterDialogState extends State<BeforeAfterDialog> {
  double _sliderValue = 0.5; // 0 = before, 1 = after

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey.shade900,
              child: Row(
                children: [
                  const Text(
                    'Before / After Comparison',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Image comparison
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth * 0.9,
                      height: constraints.maxHeight * 0.9,
                      child: ClipRect(
                        child: Stack(
                          children: [
                            // After image (full)
                            Positioned.fill(
                              child: Image.network(
                                widget.editedImageUrl,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Before image (clipped)
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: ClipRect(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: 1 - _sliderValue,
                                    child: Image.network(
                                      widget.originalImageUrl,
                                      fit: BoxFit.contain,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Divider line
                            Positioned(
                              left: constraints.maxWidth * 0.9 * (1 - _sliderValue) - 2,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 4,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Controls
            Container(
              color: Colors.grey.shade900,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BEFORE',
                        style: TextStyle(
                          color: _sliderValue < 0.5
                              ? Colors.white
                              : Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'AFTER',
                        style: TextStyle(
                          color: _sliderValue >= 0.5
                              ? Colors.white
                              : Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Slider
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 24,
                      ),
                      activeTrackColor: Colors.blue,
                      inactiveTrackColor: Colors.grey.shade700,
                      thumbColor: Colors.white,
                      overlayColor: Colors.blue.withOpacity(0.3),
                    ),
                    child: Slider(
                      value: _sliderValue,
                      onChanged: (value) {
                        setState(() {
                          _sliderValue = value;
                        });
                      },
                      min: 0,
                      max: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
