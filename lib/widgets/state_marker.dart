import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class StateMarker {
  static Future<Uint8List> createSoftSquareMarker({
    required String stateName,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final size = 24.0; // Smaller than location markers (was 32)
    final center = size / 2;

    // Shadow
    final shadowPaint = ui.Paint()
      ..color = Color.fromRGBO(0, 0, 0, 0.12)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center + 1, center + 2), // Shadow offset
          width: size - 2,
          height: size - 2,
        ),
        Radius.circular(6),
      ),
      shadowPaint,
    );

    // Background - Light color for visibility over colored polygons
    final backgroundPaint = ui.Paint()
      ..color =
          Color(0xFFF9FAFB) // Background Light from your palette
      ..style = ui.PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center, center),
          width: size - 2,
          height: size - 2,
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
          width: size - 2,
          height: size - 2,
        ),
        Radius.circular(6),
      ),
      borderPaint,
    );

    // Building emoji icon
    _drawBuildingIcon(canvas, Offset(center, center));

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  static void _drawBuildingIcon(ui.Canvas canvas, Offset center) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '🏛️', // Government building emoji
        style: TextStyle(fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }
}
