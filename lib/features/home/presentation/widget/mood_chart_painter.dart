import 'package:emora_mobile_app/features/home/data/model/insights_models.dart';
import 'package:flutter/material.dart';

class MoodChartPainter extends CustomPainter {
  final List<MoodData> data;
  final double animationValue;
  final int selectedIndex;

  MoodChartPainter(this.data, this.animationValue, this.selectedIndex);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Create gradient for the line
    final gradient = LinearGradient(
      colors: [
        const Color(0xFF8B5CF6),
        const Color(0xFF6366F1),
        const Color(0xFF10B981),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    paint.shader = gradient;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    final points = <Offset>[];

    // Calculate points with animation
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i].value * size.height * animationValue);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Create smooth curve using quadratic bezier
        final prevPoint = points[i - 1];
        final controlX = (prevPoint.dx + x) / 2;
        final controlY = (prevPoint.dy + y) / 2;
        path.quadraticBezierTo(controlX, prevPoint.dy, x, y);
      }
    }

    // Draw the animated line
    canvas.drawPath(path, paint);

    // Fill area under curve with gradient
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF8B5CF6).withValues(alpha: 0.3 * animationValue),
          const Color(0xFF8B5CF6).withValues(alpha: 0.05 * animationValue),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Draw points and labels
    for (int i = 0; i < data.length; i++) {
      final point = points[i];
      final isSelected = i == selectedIndex;

      // Draw point
      final pointPaint = Paint()
        ..color = isSelected ? const Color(0xFFFFD700) : const Color(0xFF8B5CF6)
        ..style = PaintingStyle.fill;

      final pointRadius = isSelected ? 6.0 : 4.0;
      canvas.drawCircle(point, pointRadius * animationValue, pointPaint);

      // Draw white border for selected point
      if (isSelected) {
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(point, pointRadius * animationValue, borderPaint);
      }

      // Draw day labels
      final textPainter = TextPainter(
        text: TextSpan(
          text: data[i].day,
          style: TextStyle(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[400],
            fontSize: isSelected ? 11 : 10,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Position label below the chart
      final labelY = size.height + 12;
      textPainter.paint(
        canvas,
        Offset(point.dx - textPainter.width / 2, labelY),
      );

      // Draw mood emoji above point if selected
      if (isSelected && animationValue > 0.8) {
        final emojiPainter = TextPainter(
          text: TextSpan(
            text: data[i].emoji,
            style: const TextStyle(fontSize: 20),
          ),
          textDirection: TextDirection.ltr,
        );
        emojiPainter.layout();
        emojiPainter.paint(
          canvas,
          Offset(point.dx - emojiPainter.width / 2, point.dy - 35),
        );
      }
    }

    // Draw mood scale on the left
    _drawMoodScale(canvas, size);
  }

  void _drawMoodScale(Canvas canvas, Size size) {
    final scaleLabels = ['😔', '😐', '😊', '😄', '🤩'];
    final scaleValues = [0.2, 0.4, 0.6, 0.8, 1.0];

    for (int i = 0; i < scaleLabels.length; i++) {
      final y = size.height - (scaleValues[i] * size.height);

      // Draw horizontal grid line
      final gridPaint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.2)
        ..strokeWidth = 1;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      // Draw emoji scale
      final emojiPainter = TextPainter(
        text: TextSpan(
          text: scaleLabels[i],
          style: const TextStyle(fontSize: 16),
        ),
        textDirection: TextDirection.ltr,
      );
      emojiPainter.layout();
      emojiPainter.paint(canvas, Offset(-25, y - emojiPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
