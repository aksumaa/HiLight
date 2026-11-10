import 'package:flutter/material.dart';

import '../../../core/theme/hilight_colors.dart';

class WaveformBars extends StatelessWidget {
  const WaveformBars({required this.levels, super.key});

  final List<double> levels;

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    return SizedBox(
      height: 88,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final level in levels)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Align(
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    heightFactor: 0.15 + (0.85 * level.clamp(0, 1)),
                    widthFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.voice,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

double waveformLevel(double decibels) {
  const floor = -45.0;
  final clamped = decibels.clamp(floor, 0.0);
  return (clamped - floor) / (0 - floor);
}
