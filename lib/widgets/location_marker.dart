import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Top20LocationMarker {
  static Future<Uint8List> createSoftSquareMarker(int position) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final size = 32.0;
    final center = size / 2;

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

    final backgroundPaint = ui.Paint()
      ..color =
          Color(0xFF374151) // Your charcoal color
      ..style = ui.PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center, center),
          width: size - 4, // Changed from size - 2
          height: size - 4, // Changed from size - 2
        ),
        Radius.circular(6),
      ),
      backgroundPaint,
    );

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

    _drawStar(canvas, Offset(7, 7), 3.5, Color(0xFFEAB308));

    final textPainter = TextPainter(
      text: TextSpan(
        text: position.toString(),
        style: TextStyle(
          color: Colors.white,
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
    final image = await picture.toImage(
      size.toInt(),
      size.toInt(),
    ); // Changed from 24
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  static void _drawStar(
    ui.Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final paint = ui.Paint()
      ..color = color
      ..style = ui.PaintingStyle.fill;

    final path = ui.Path();
    final angle = 2 * 3.14159 / 5;

    for (int i = 0; i < 10; i++) {
      final r = (i % 2 == 0) ? radius : radius * 0.4;
      final x = center.dx + r * math.cos(i * angle / 2 - 3.14159 / 2);
      final y = center.dy + r * math.sin(i * angle / 2 - 3.14159 / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}


