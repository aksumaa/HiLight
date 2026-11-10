import 'package:flutter/material.dart';

import '../../../core/theme/hilight_colors.dart';

class CaptureFrameOverlay extends StatelessWidget {
  const CaptureFrameOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    return CustomPaint(
      painter: _FramePainter(scrim: colors.scrim, frame: colors.quote),
      child: const SizedBox.expand(),
    );
  }
}

class _FramePainter extends CustomPainter {
  const _FramePainter({required this.scrim, required this.frame});

  final Color scrim;
  final Color frame;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.width - 48;
    final hole = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: side,
      height: side * 1.2,
    );
    final window = RRect.fromRectAndRadius(
      hole,
      const Radius.circular(HilightColors.radius),
    );
    final shade = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(window);
    canvas.drawPath(shade, Paint()..color = scrim);
    canvas.drawRRect(
      window,
      Paint()
        ..color = frame
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _FramePainter oldDelegate) {
    return oldDelegate.scrim != scrim || oldDelegate.frame != frame;
  }
}
