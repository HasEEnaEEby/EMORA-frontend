import 'package:flutter/material.dart';

class EmotionMarker extends StatefulWidget {
  final String emotion;
  final double intensity;
  final Color color;

  const EmotionMarker({
    super.key,
    required this.emotion,
    required this.intensity,
    required this.color,
  });

  @override
  State<EmotionMarker> createState() => _EmotionMarkerState();
}

class _EmotionMarkerState extends State<EmotionMarker>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: Duration(
        milliseconds: (1500 + (widget.intensity * 1500)).round(),
      ),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showEmotionDetails();
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.6),
                    blurRadius: 20 * widget.intensity,
                    spreadRadius: 5 * widget.intensity,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getEmotionIcon(widget.emotion),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happiness':
        return '😊';
      case 'love':
        return '❤️';
      case 'excitement':
        return '🎉';
      case 'calm':
      case 'peace':
      case 'serenity':
        return '🧘';
      case 'hope':
        return '🌟';
      case 'celebration':
        return '🎊';
      case 'passion':
        return '🔥';
      case 'gratitude':
        return '🙏';
      case 'wonder':
        return '✨';
      default:
        return '💙';
    }
  }

  void _showEmotionDetails() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withValues(alpha: 0.9),
            border: Border.all(color: widget.color.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getEmotionIcon(widget.emotion),
                style: const TextStyle(fontSize: 50),
              ),
              const SizedBox(height: 15),
              Text(
                widget.emotion.toUpperCase(),
                style: TextStyle(
                  color: widget.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Intensity: ${(widget.intensity * 100).round()}%',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 15),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: widget.intensity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: widget.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
