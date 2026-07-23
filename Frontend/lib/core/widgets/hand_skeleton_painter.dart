// lib/core/widgets/hand_skeleton_painter.dart

import 'package:flutter/material.dart';
import '../utils/gesture_engine.dart';

class HandSkeletonPainter extends CustomPainter {
  final List<List<Landmark>>? multiHandLandmarks;

  HandSkeletonPainter(this.multiHandLandmarks);

  @override
  void paint(Canvas canvas, Size size) {
    if (multiHandLandmarks == null || multiHandLandmarks!.isEmpty) return;

    final dotPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.tealAccent.withOpacity(0.85)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Standard MediaPipe 21 Hand Landmarks joint connections
    final connections = [
      // Wrist to base of fingers
      [0, 1], [0, 5], [0, 17],
      // Finger base connections
      [5, 9], [9, 13], [13, 17],
      // Thumb
      [1, 2], [2, 3], [3, 4],
      // Index
      [5, 6], [6, 7], [7, 8],
      // Middle
      [9, 10], [10, 11], [11, 12],
      // Ring
      [13, 14], [14, 15], [15, 16],
      // Pinky
      [17, 18], [18, 19], [19, 20],
    ];

    for (final hand in multiHandLandmarks!) {
      if (hand.length < 21) continue;

      // Draw joint connection paths
      for (final conn in connections) {
        final p1 = hand[conn[0]];
        final p2 = hand[conn[1]];

        // Use standard X coordinate mapping to match the mirrored selfie camera preview stream
        final startPoint = Offset(p1.x * size.width, p1.y * size.height);
        final endPoint = Offset(p2.x * size.width, p2.y * size.height);

        canvas.drawLine(startPoint, endPoint, linePaint);
      }

      // Draw joint dots
      for (final lm in hand) {
        final point = Offset(lm.x * size.width, lm.y * size.height);
        canvas.drawCircle(point, 5.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HandSkeletonPainter oldDelegate) {
    return oldDelegate.multiHandLandmarks != multiHandLandmarks;
  }
}
