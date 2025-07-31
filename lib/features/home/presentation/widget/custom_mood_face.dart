import 'package:flutter/material.dart';

enum MoodType { amazing, good, okay, down, awful }

class CustomMoodFace extends StatelessWidget {
  final MoodType mood;
  final double size;
  final Color? backgroundColor;
  final Color? faceColor;
  final bool showBorder;
  final double borderWidth;

  const CustomMoodFace({
    super.key,
    required this.mood,
    this.size = 60,
    this.backgroundColor,
    this.faceColor,
    this.showBorder = false,
    this.borderWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? _getMoodColor(mood);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: showBorder
            ? Border.all(
                color: _getMoodColor(mood).withOpacity(0.6),
                width: borderWidth,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: _getMoodColor(mood).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: MoodFacePainter(
          mood: mood,
          faceColor: faceColor ?? _getFaceColor(mood),
        ),
      ),
    );
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.amazing:
return const Color(0xFFFFD700); 
      case MoodType.good:
return const Color(0xFF6EE7B7); 
      case MoodType.okay:
return const Color(0xFF9CA3AF); 
      case MoodType.down:
return const Color(0xFF6366F1); 
      case MoodType.awful:
return const Color(0xFF6B7280); 
    }
  }

  Color _getFaceColor(MoodType mood) {
    switch (mood) {
      case MoodType.amazing:
        return Colors.black87;
      case MoodType.good:
        return Colors.black87;
      case MoodType.okay:
        return Colors.black54;
      case MoodType.down:
        return Colors.white70;
      case MoodType.awful:
        return Colors.white70;
    }
  }
}

class MoodFacePainter extends CustomPainter {
  final MoodType mood;
  final Color faceColor;

  MoodFacePainter({required this.mood, this.faceColor = Colors.black87});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final strokePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          size.width *
0.04 
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    _drawEyes(canvas, center, radius, paint, strokePaint, mood);

    _drawMouth(canvas, center, radius, strokePaint, mood);
  }

  void _drawEyes(
    Canvas canvas,
    Offset center,
    double radius,
    Paint fillPaint,
    Paint strokePaint,
    MoodType mood,
  ) {
    final eyeRadius = radius * 0.1;
    final eyeY = center.dy - radius * 0.2;
    final eyeSpacing = radius * 0.4;

    switch (mood) {
      case MoodType.amazing:
        final eyePaint = Paint()
          ..color = fillPaint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokePaint.strokeWidth
          ..strokeCap = StrokeCap.round;

        final leftEyePath = Path();
        leftEyePath.moveTo(center.dx - eyeSpacing - eyeRadius, eyeY);
        leftEyePath.quadraticBezierTo(
          center.dx - eyeSpacing,
          eyeY - eyeRadius * 0.6,
          center.dx - eyeSpacing + eyeRadius,
          eyeY,
        );
        canvas.drawPath(leftEyePath, eyePaint);

        final rightEyePath = Path();
        rightEyePath.moveTo(center.dx + eyeSpacing - eyeRadius, eyeY);
        rightEyePath.quadraticBezierTo(
          center.dx + eyeSpacing,
          eyeY - eyeRadius * 0.6,
          center.dx + eyeSpacing + eyeRadius,
          eyeY,
        );
        canvas.drawPath(rightEyePath, eyePaint);
        break;

      case MoodType.good:
        canvas.drawCircle(
          Offset(center.dx - eyeSpacing, eyeY),
          eyeRadius,
          fillPaint,
        );
        canvas.drawCircle(
          Offset(center.dx + eyeSpacing, eyeY),
          eyeRadius,
          fillPaint,
        );
        break;

      case MoodType.okay:
        final neutralEyeRadius = eyeRadius * 0.7;
        canvas.drawCircle(
          Offset(center.dx - eyeSpacing, eyeY),
          neutralEyeRadius,
          fillPaint,
        );
        canvas.drawCircle(
          Offset(center.dx + eyeSpacing, eyeY),
          neutralEyeRadius,
          fillPaint,
        );
        break;

      case MoodType.down:
        final eyePaint = Paint()
          ..color = fillPaint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokePaint.strokeWidth
          ..strokeCap = StrokeCap.round;

        final leftEyePath = Path();
        leftEyePath.moveTo(center.dx - eyeSpacing - eyeRadius, eyeY);
        leftEyePath.quadraticBezierTo(
          center.dx - eyeSpacing,
          eyeY + eyeRadius * 0.4,
          center.dx - eyeSpacing + eyeRadius,
          eyeY,
        );
        canvas.drawPath(leftEyePath, eyePaint);

        final rightEyePath = Path();
        rightEyePath.moveTo(center.dx + eyeSpacing - eyeRadius, eyeY);
        rightEyePath.quadraticBezierTo(
          center.dx + eyeSpacing,
          eyeY + eyeRadius * 0.4,
          center.dx + eyeSpacing + eyeRadius,
          eyeY,
        );
        canvas.drawPath(rightEyePath, eyePaint);
        break;

      case MoodType.awful:
        final xPaint = Paint()
          ..color = fillPaint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokePaint.strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(
            center.dx - eyeSpacing - eyeRadius * 0.8,
            eyeY - eyeRadius * 0.8,
          ),
          Offset(
            center.dx - eyeSpacing + eyeRadius * 0.8,
            eyeY + eyeRadius * 0.8,
          ),
          xPaint,
        );
        canvas.drawLine(
          Offset(
            center.dx - eyeSpacing + eyeRadius * 0.8,
            eyeY - eyeRadius * 0.8,
          ),
          Offset(
            center.dx - eyeSpacing - eyeRadius * 0.8,
            eyeY + eyeRadius * 0.8,
          ),
          xPaint,
        );

        canvas.drawLine(
          Offset(
            center.dx + eyeSpacing - eyeRadius * 0.8,
            eyeY - eyeRadius * 0.8,
          ),
          Offset(
            center.dx + eyeSpacing + eyeRadius * 0.8,
            eyeY + eyeRadius * 0.8,
          ),
          xPaint,
        );
        canvas.drawLine(
          Offset(
            center.dx + eyeSpacing + eyeRadius * 0.8,
            eyeY - eyeRadius * 0.8,
          ),
          Offset(
            center.dx + eyeSpacing - eyeRadius * 0.8,
            eyeY + eyeRadius * 0.8,
          ),
          xPaint,
        );
        break;
    }
  }

  void _drawMouth(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    MoodType mood,
  ) {
    final mouthY = center.dy + radius * 0.25;
    final mouthWidth = radius * 0.6;

    switch (mood) {
      case MoodType.amazing:
        final path = Path();
        path.moveTo(center.dx - mouthWidth, mouthY);
        path.quadraticBezierTo(
          center.dx,
          mouthY + radius * 0.35,
          center.dx + mouthWidth,
          mouthY,
        );
        canvas.drawPath(path, paint);
        break;

      case MoodType.good:
        final path = Path();
        path.moveTo(center.dx - mouthWidth * 0.7, mouthY);
        path.quadraticBezierTo(
          center.dx,
          mouthY + radius * 0.2,
          center.dx + mouthWidth * 0.7,
          mouthY,
        );
        canvas.drawPath(path, paint);
        break;

      case MoodType.okay:
        canvas.drawLine(
          Offset(center.dx - mouthWidth * 0.5, mouthY),
          Offset(center.dx + mouthWidth * 0.5, mouthY),
          paint,
        );
        break;

      case MoodType.down:
        final path = Path();
        path.moveTo(center.dx - mouthWidth * 0.7, mouthY);
        path.quadraticBezierTo(
          center.dx,
          mouthY - radius * 0.15,
          center.dx + mouthWidth * 0.7,
          mouthY,
        );
        canvas.drawPath(path, paint);
        break;

      case MoodType.awful:
        final path = Path();
        path.moveTo(center.dx - mouthWidth, mouthY);
        path.quadraticBezierTo(
          center.dx,
          mouthY - radius * 0.25,
          center.dx + mouthWidth,
          mouthY,
        );
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MoodUtils {
  static MoodType stringToMoodType(String moodString) {
    switch (moodString.toLowerCase()) {
      case 'amazing':
      case 'excellent':
      case 'fantastic':
      case 'great':
        return MoodType.amazing;
      case 'good':
      case 'happy':
      case 'joy':
      case 'positive':
        return MoodType.good;
      case 'okay':
      case 'neutral':
      case 'fine':
      case 'alright':
        return MoodType.okay;
      case 'down':
      case 'sad':
      case 'low':
      case 'blue':
        return MoodType.down;
      case 'awful':
      case 'terrible':
      case 'depressed':
      case 'horrible':
        return MoodType.awful;
      default:
        return MoodType.okay;
    }
  }

  static String moodTypeToString(MoodType mood) {
    switch (mood) {
      case MoodType.amazing:
        return 'amazing';
      case MoodType.good:
        return 'good';
      case MoodType.okay:
        return 'okay';
      case MoodType.down:
        return 'down';
      case MoodType.awful:
        return 'awful';
    }
  }

  static String moodTypeToEmoji(MoodType mood) {
    switch (mood) {
      case MoodType.amazing:
        return '😄';
      case MoodType.good:
        return '😊';
      case MoodType.okay:
        return '😐';
      case MoodType.down:
        return '😔';
      case MoodType.awful:
        return '😭';
    }
  }

  static Color getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.amazing:
        return const Color(0xFFFFD700);
      case MoodType.good:
        return const Color(0xFF6EE7B7);
      case MoodType.okay:
        return const Color(0xFF9CA3AF);
      case MoodType.down:
        return const Color(0xFF6366F1);
      case MoodType.awful:
        return const Color(0xFF6B7280);
    }
  }

  static int getMoodIntensity(MoodType mood) {
    switch (mood) {
      case MoodType.amazing:
        return 5;
      case MoodType.good:
        return 4;
      case MoodType.okay:
        return 3;
      case MoodType.down:
        return 2;
      case MoodType.awful:
        return 1;
    }
  }

  static double getMoodIntensityDouble(MoodType mood) {
    switch (mood) {
      case MoodType.amazing:
        return 0.9;
      case MoodType.good:
        return 0.7;
      case MoodType.okay:
        return 0.5;
      case MoodType.down:
        return 0.3;
      case MoodType.awful:
        return 0.1;
    }
  }

  static String getMoodLabel(MoodType mood) {
    switch (mood) {
      case MoodType.amazing:
        return 'Amazing';
      case MoodType.good:
        return 'Good';
      case MoodType.okay:
        return 'Okay';
      case MoodType.down:
        return 'Down';
      case MoodType.awful:
        return 'Awful';
    }
  }

  static List<MoodType> getAllMoods() {
    return [
      MoodType.amazing,
      MoodType.good,
      MoodType.okay,
      MoodType.down,
      MoodType.awful,
    ];
  }
}

class MoodFaceExample extends StatefulWidget {
  const MoodFaceExample({super.key});

  @override
  State<MoodFaceExample> createState() => _MoodFaceExampleState();
}

class _MoodFaceExampleState extends State<MoodFaceExample> {
  MoodType selectedMood = MoodType.good;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomMoodFace(mood: selectedMood, size: 120, showBorder: true),

            const SizedBox(height: 20),

            Text(
              MoodUtils.getMoodLabel(selectedMood),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 40),

            Wrap(
              spacing: 16,
              children: MoodUtils.getAllMoods().map((mood) {
                final isSelected = mood == selectedMood;
                return GestureDetector(
                  onTap: () => setState(() => selectedMood = mood),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: CustomMoodFace(mood: mood, size: 60),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
