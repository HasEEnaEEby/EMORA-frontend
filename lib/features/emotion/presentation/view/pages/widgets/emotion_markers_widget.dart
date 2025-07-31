import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';


class EmotionPointMarkerWidget extends StatelessWidget {
  final dynamic point;
  final Animation<double> animation;
  final VoidCallback onTap;

  const EmotionPointMarkerWidget({
    super.key,
    required this.point,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 60 * animation.value,
                height: 60 * animation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getEmotionColor(point.emotion).withValues(alpha: 0.1 * (2 - animation.value)),
                      _getEmotionColor(point.emotion).withValues(alpha: 0.05 * (2 - animation.value)),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(
                    color: _getEmotionColor(point.emotion).withValues(alpha: 0.3 * (2 - animation.value)),
                    width: 2,
                  ),
                ),
              ),

              Container(
                width: 35 * animation.value,
                height: 35 * animation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getEmotionColor(point.emotion).withValues(alpha: 0.2 * (2 - animation.value)),
                      _getEmotionColor(point.emotion).withValues(alpha: 0.1 * (2 - animation.value)),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getEmotionColor(point.emotion).withValues(alpha: 0.9),
                      _getEmotionColor(point.emotion),
                    ],
                  ),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: _getEmotionColor(point.emotion).withValues(alpha: 0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getEmotionIcon(point.emotion),
                  color: Colors.white,
                  size: 18,
                ),
              ),

              Positioned(
                top: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.9),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                    border: Border.all(
                      color: _getEmotionColor(point.emotion).withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '${point.intensity}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: -24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                    border: Border.all(
                      color: _getEmotionColor(point.emotion).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    point.emotion.toUpperCase(),
                    style: TextStyle(
                      color: _getEmotionColor(point.emotion),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happiness':
      case 'excitement':
        return const Color(0xFFFFD700);
      case 'calm':
      case 'contentment':
      case 'peace':
        return const Color(0xFF4CAF50);
      case 'sadness':
      case 'melancholy':
        return const Color(0xFF2196F3);
      case 'anger':
      case 'frustration':
        return const Color(0xFFE91E63);
      case 'anxiety':
      case 'stress':
        return const Color(0xFFFF9800);
      case 'love':
      case 'affection':
        return const Color(0xFFE91E63);
      case 'focus':
      case 'concentration':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happiness':
      case 'excitement':
        return Icons.sentiment_very_satisfied;
      case 'calm':
      case 'contentment':
      case 'peace':
        return Icons.sentiment_satisfied;
      case 'sadness':
      case 'melancholy':
        return Icons.sentiment_dissatisfied;
      case 'anger':
      case 'frustration':
        return Icons.sentiment_very_dissatisfied;
      case 'anxiety':
      case 'stress':
        return Icons.sentiment_neutral;
      case 'love':
      case 'affection':
        return Icons.favorite;
      case 'focus':
      case 'concentration':
        return Icons.psychology;
      default:
        return Icons.psychology;
    }
  }
}


class EmotionClusterMarkerWidget extends StatelessWidget {
  final dynamic cluster;
  final Animation<double> animation;
  final VoidCallback onTap;

  const EmotionClusterMarkerWidget({
    super.key,
    required this.cluster,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: cluster.radius * 2 * animation.value,
                height: cluster.radius * 2 * animation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getEmotionColor(cluster.dominantEmotion).withValues(alpha: 0.1 * (2 - animation.value)),
                      _getEmotionColor(cluster.dominantEmotion).withValues(alpha: 0.05 * (2 - animation.value)),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(
                    color: _getEmotionColor(cluster.dominantEmotion).withValues(alpha: 0.3 * (2 - animation.value)),
                    width: 3,
                  ),
                ),
              ),

              Container(
                width: cluster.radius * 1.2,
                height: cluster.radius * 1.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getEmotionColor(cluster.dominantEmotion).withValues(alpha: 0.2),
                      _getEmotionColor(cluster.dominantEmotion).withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              Container(
                width: cluster.radius * 0.8,
                height: cluster.radius * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getEmotionColor(cluster.dominantEmotion),
                      _getEmotionColor(cluster.dominantEmotion).withValues(alpha: 0.8),
                    ],
                  ),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: _getEmotionColor(cluster.dominantEmotion).withValues(alpha: 0.6),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getEmotionIcon(cluster.dominantEmotion),
                      color: Colors.white,
                      size: cluster.radius > 60 ? 24 : 18,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCount(cluster.emotionCount),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: cluster.radius > 60 ? 12 : 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: -cluster.radius * 0.6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.9),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                    border: Border.all(
                      color: _getEmotionColor(cluster.dominantEmotion).withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    cluster.dominantEmotion.toUpperCase(),
                    style: TextStyle(
                      color: _getEmotionColor(cluster.dominantEmotion),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: -cluster.radius * 0.3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        _getEmotionColor(cluster.dominantEmotion).withValues(alpha: 0.9),
                        _getEmotionColor(cluster.dominantEmotion).withValues(alpha: 0.7),
                      ],
                    ),
                    border: Border.all(color: Colors.white, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: _getEmotionColor(cluster.dominantEmotion).withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '${(cluster.averageIntensity * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happiness':
      case 'excitement':
        return const Color(0xFFFFD700);
      case 'calm':
      case 'contentment':
      case 'peace':
        return const Color(0xFF4CAF50);
      case 'sadness':
      case 'melancholy':
        return const Color(0xFF2196F3);
      case 'anger':
      case 'frustration':
        return const Color(0xFFE91E63);
      case 'anxiety':
      case 'stress':
        return const Color(0xFFFF9800);
      case 'love':
      case 'affection':
        return const Color(0xFFE91E63);
      case 'focus':
      case 'concentration':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happiness':
      case 'excitement':
        return Icons.sentiment_very_satisfied;
      case 'calm':
      case 'contentment':
      case 'peace':
        return Icons.sentiment_satisfied;
      case 'sadness':
      case 'melancholy':
        return Icons.sentiment_dissatisfied;
      case 'anger':
      case 'frustration':
        return Icons.sentiment_very_dissatisfied;
      case 'anxiety':
      case 'stress':
        return Icons.sentiment_neutral;
      case 'love':
      case 'affection':
        return Icons.favorite;
      case 'focus':
      case 'concentration':
        return Icons.psychology;
      default:
        return Icons.psychology;
    }
  }
}


class UserLocationMarkerWidget extends StatelessWidget {
  final Animation<double> animation;

  const UserLocationMarkerWidget({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 60 * animation.value,
              height: 60 * animation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2196F3).withValues(alpha: 0.2 * (2 - animation.value)),
                    const Color(0xFF2196F3).withValues(alpha: 0.1 * (2 - animation.value)),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.4 * (2 - animation.value)),
                  width: 2,
                ),
              ),
            ),

            Container(
              width: 40 * animation.value,
              height: 40 * animation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2196F3).withValues(alpha: 0.3 * (2 - animation.value)),
                    const Color(0xFF2196F3).withValues(alpha: 0.15 * (2 - animation.value)),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.6),
                    blurRadius: 15 * animation.value,
                    spreadRadius: 5 * animation.value,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),

            Positioned(
              bottom: -20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'YOU',
                  style: TextStyle(
                    color: Color(0xFF2196F3),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 