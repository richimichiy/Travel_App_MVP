import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class RioLocationMarker {
  static Future<Uint8List> createSoftSquareMarker(int position) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final size = 32.0;
    final center = size / 2;

    // Shadow
    final shadowPaint = ui.Paint()
      ..color = Color.fromRGBO(0, 0, 0, 0.12)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center + 1, center + 2), // Shadow offset
          width: size - 4,
          height: size - 4,
        ),
        Radius.circular(6),
      ),
      shadowPaint,
    );

    // Light background instead of charcoal
    final backgroundPaint = ui.Paint()
      ..color =
          Color(0xFFF9FAFB) // Background Light from your palette
      ..style = ui.PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center, center),
          width: size - 4,
          height: size - 4,
        ),
        Radius.circular(6),
      ),
      backgroundPaint,
    );

    // Border
    final borderPaint = ui.Paint()
      ..color = Colors.white
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center, center),
          width: size - 4,
          height: size - 4,
        ),
        Radius.circular(6),
      ),
      borderPaint,
    );

    // Draw heart in top-left
    _drawHeart(canvas, Offset(7, 7), 3.5, Color(0xFFEF4444)); // Alert Red

    // Draw position number in center
    final textPainter = TextPainter(
      text: TextSpan(
        text: position.toString(),
        style: TextStyle(
          color: Color(0xFF374151), // Primary Charcoal for contrast
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center - textPainter.width / 2,
        center - textPainter.height / 2 + 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  static void _drawHeart(
    ui.Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final paint = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.fill;

    final path = ui.Path();

    // Heart shape using bezier curves
    path.moveTo(center.dx, center.dy + radius * 0.3);

    // Left curve
    path.cubicTo(
      center.dx - radius * 0.8,
      center.dy - radius * 0.5,
      center.dx - radius * 1.2,
      center.dy + radius * 0.2,
      center.dx,
      center.dy + radius * 0.8,
    );

    // Right curve
    path.cubicTo(
      center.dx + radius * 1.2,
      center.dy + radius * 0.2,
      center.dx + radius * 0.8,
      center.dy - radius * 0.5,
      center.dx,
      center.dy + radius * 0.3,
    );

    path.close();
    canvas.drawPath(path, paint);
  }
}
