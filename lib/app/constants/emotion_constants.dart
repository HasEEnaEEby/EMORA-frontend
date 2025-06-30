import 'package:flutter/material.dart';

class EmotionConstants {
  static const Map<String, Map<String, dynamic>> emotions = {
    'joy': {
      'name': 'Joy',
      'emoji': '😊',
      'character': '😊',
      'color': Color(0xFFFFD700),
      'bgGradient': [Color(0xFFFFD700), Color(0xFFFF8C00)],
      'description': 'Happy and content',
      'intensity': 'positive',
    },
    'happy': {
      'name': 'Happy',
      'emoji': '😊',
      'character': '😊',
      'color': Color(0xFFFFD700),
      'bgGradient': [Color(0xFFFFD700), Color(0xFFFF8C00)],
      'description': 'Feeling good and cheerful',
      'intensity': 'positive',
    },
    'calm': {
      'name': 'Calm',
      'emoji': '😌',
      'character': '😌',
      'color': Color(0xFF4CAF50),
      'bgGradient': [Color(0xFF4CAF50), Color(0xFF8BC34A)],
      'description': 'Peaceful and relaxed',
      'intensity': 'neutral',
    },
    'sad': {
      'name': 'Sad',
      'emoji': '😢',
      'character': '😢',
      'color': Color(0xFF2196F3),
      'bgGradient': [Color(0xFF2196F3), Color(0xFF03A9F4)],
      'description': 'Feeling down or melancholic',
      'intensity': 'negative',
    },
    'sadness': {
      'name': 'Sadness',
      'emoji': '😢',
      'character': '😢',
      'color': Color(0xFF2196F3),
      'bgGradient': [Color(0xFF2196F3), Color(0xFF03A9F4)],
      'description': 'Deep feeling of sorrow',
      'intensity': 'negative',
    },
    'anger': {
      'name': 'Anger',
      'emoji': '😠',
      'character': '😠',
      'color': Color(0xFFF44336),
      'bgGradient': [Color(0xFFF44336), Color(0xFFE91E63)],
      'description': 'Feeling frustrated or mad',
      'intensity': 'negative',
    },
    'angry': {
      'name': 'Angry',
      'emoji': '😠',
      'character': '😠',
      'color': Color(0xFFF44336),
      'bgGradient': [Color(0xFFF44336), Color(0xFFE91E63)],
      'description': 'Feeling irritated or furious',
      'intensity': 'negative',
    },
    'fear': {
      'name': 'Fear',
      'emoji': '😰',
      'character': '😰',
      'color': Color(0xFF9C27B0),
      'bgGradient': [Color(0xFF9C27B0), Color(0xFF673AB7)],
      'description': 'Feeling scared or anxious',
      'intensity': 'negative',
    },
    'anxious': {
      'name': 'Anxious',
      'emoji': '😰',
      'character': '😰',
      'color': Color(0xFF9C27B0),
      'bgGradient': [Color(0xFF9C27B0), Color(0xFF673AB7)],
      'description': 'Feeling worried or nervous',
      'intensity': 'negative',
    },
    'disgust': {
      'name': 'Disgust',
      'emoji': '🤢',
      'character': '🤢',
      'color': Color(0xFF795548),
      'bgGradient': [Color(0xFF795548), Color(0xFF8D6E63)],
      'description': 'Feeling repulsed or nauseated',
      'intensity': 'negative',
    },
    'surprise': {
      'name': 'Surprise',
      'emoji': '😲',
      'character': '😲',
      'color': Color(0xFFFF9800),
      'bgGradient': [Color(0xFFFF9800), Color(0xFFFFC107)],
      'description': 'Feeling amazed or shocked',
      'intensity': 'neutral',
    },
    'love': {
      'name': 'Love',
      'emoji': '😍',
      'character': '😍',
      'color': Color(0xFFE91E63),
      'bgGradient': [Color(0xFFE91E63), Color(0xFF9C27B0)],
      'description': 'Feeling loving and affectionate',
      'intensity': 'positive',
    },
    'excited': {
      'name': 'Excited',
      'emoji': '🤩',
      'character': '🤩',
      'color': Color(0xFFFF5722),
      'bgGradient': [Color(0xFFFF5722), Color(0xFFFF9800)],
      'description': 'Feeling thrilled and energetic',
      'intensity': 'positive',
    },
    'overwhelmed': {
      'name': 'Overwhelmed',
      'emoji': '🤯',
      'character': '🤯',
      'color': Color(0xFF607D8B),
      'bgGradient': [Color(0xFF607D8B), Color(0xFF9E9E9E)],
      'description': 'Feeling swamped or stressed',
      'intensity': 'negative',
    },
    'confused': {
      'name': 'Confused',
      'emoji': '😕',
      'character': '😕',
      'color': Color(0xFF9E9E9E),
      'bgGradient': [Color(0xFF9E9E9E), Color(0xFF607D8B)],
      'description': 'Feeling uncertain or puzzled',
      'intensity': 'neutral',
    },
    'grateful': {
      'name': 'Grateful',
      'emoji': '🙏',
      'character': '🙏',
      'color': Color(0xFF8BC34A),
      'bgGradient': [Color(0xFF8BC34A), Color(0xFF4CAF50)],
      'description': 'Feeling thankful and appreciative',
      'intensity': 'positive',
    },
    'lonely': {
      'name': 'Lonely',
      'emoji': '😔',
      'character': '😔',
      'color': Color(0xFF3F51B5),
      'bgGradient': [Color(0xFF3F51B5), Color(0xFF2196F3)],
      'description': 'Feeling isolated or alone',
      'intensity': 'negative',
    },
    'hopeful': {
      'name': 'Hopeful',
      'emoji': '🌅',
      'character': '🌅',
      'color': Color(0xFFFFC107),
      'bgGradient': [Color(0xFFFFC107), Color(0xFFFFEB3B)],
      'description': 'Feeling optimistic about the future',
      'intensity': 'positive',
    },
    'frustrated': {
      'name': 'Frustrated',
      'emoji': '😤',
      'character': '😤',
      'color': Color(0xFFFF5722),
      'bgGradient': [Color(0xFFFF5722), Color(0xFFF44336)],
      'description': 'Feeling blocked or annoyed',
      'intensity': 'negative',
    },
    'peaceful': {
      'name': 'Peaceful',
      'emoji': '☮️',
      'character': '☮️',
      'color': Color(0xFF00BCD4),
      'bgGradient': [Color(0xFF00BCD4), Color(0xFF4CAF50)],
      'description': 'Feeling serene and at peace',
      'intensity': 'positive',
    },
  };

  /// Get emotion data by key
  static Map<String, dynamic> getEmotion(String emotionKey) {
    return emotions[emotionKey.toLowerCase()] ?? emotions['joy']!;
  }

  /// Get emoji for emotion
  static String getEmotionEmoji(String emotionKey) {
    return getEmotion(emotionKey)['emoji'] ?? '😊';
  }

  /// Get character for emotion
  static String getEmotionCharacter(String emotionKey) {
    return getEmotion(emotionKey)['character'] ?? '😊';
  }

  /// Get color for emotion
  static Color getEmotionColor(String emotionKey) {
    return getEmotion(emotionKey)['color'] ?? const Color(0xFFFFD700);
  }

  /// Get background gradient for emotion
  static List<Color> getEmotionGradient(String emotionKey) {
    return List<Color>.from(
      getEmotion(emotionKey)['bgGradient'] ??
          [const Color(0xFFFFD700), const Color(0xFFFF8C00)],
    );
  }

  /// Get emotion name
  static String getEmotionName(String emotionKey) {
    return getEmotion(emotionKey)['name'] ?? 'Joy';
  }

  /// Get emotion description
  static String getEmotionDescription(String emotionKey) {
    return getEmotion(emotionKey)['description'] ?? 'Feeling happy';
  }

  /// Get global percentage (mock data for now)
  static int getGlobalPercentage(String emotionKey) {
    final percentages = {
      'joy': 42,
      'happy': 42,
      'calm': 38,
      'sad': 15,
      'sadness': 15,
      'anger': 12,
      'angry': 12,
      'fear': 20,
      'anxious': 25,
      'excited': 35,
      'overwhelmed': 18,
      'grateful': 30,
      'peaceful': 40,
    };
    return percentages[emotionKey.toLowerCase()] ?? 25;
  }

  /// Get emotions by intensity
  static List<String> getEmotionsByIntensity(String intensity) {
    return emotions.entries
        .where((entry) => entry.value['intensity'] == intensity)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get positive emotions
  static List<String> getPositiveEmotions() {
    return getEmotionsByIntensity('positive');
  }

  /// Get negative emotions
  static List<String> getNegativeEmotions() {
    return getEmotionsByIntensity('negative');
  }

  /// Get neutral emotions
  static List<String> getNeutralEmotions() {
    return getEmotionsByIntensity('neutral');
  }

  /// Check if emotion exists
  static bool hasEmotion(String emotionKey) {
    return emotions.containsKey(emotionKey.toLowerCase());
  }

  /// Get all emotion keys
  static List<String> getAllEmotionKeys() {
    return emotions.keys.toList();
  }

  /// Get random emotion
  static String getRandomEmotion() {
    final keys = getAllEmotionKeys();
    keys.shuffle();
    return keys.first;
  }

  /// Get emotions for mood suggestions
  static List<Map<String, dynamic>> getMoodSuggestions() {
    return [
      emotions['joy']!,
      emotions['calm']!,
      emotions['sad']!,
      emotions['angry']!,
      emotions['anxious']!,
      emotions['excited']!,
    ];
  }

  /// Get complementary emotions (opposite feelings)
  static String getComplementaryEmotion(String emotionKey) {
    final complementary = {
      'joy': 'sad',
      'happy': 'sad',
      'calm': 'anxious',
      'sad': 'joy',
      'sadness': 'joy',
      'anger': 'calm',
      'angry': 'calm',
      'fear': 'calm',
      'anxious': 'calm',
      'excited': 'calm',
      'overwhelmed': 'peaceful',
      'frustrated': 'calm',
      'lonely': 'love',
      'hopeful': 'fear',
      'peaceful': 'anxious',
    };
    return complementary[emotionKey.toLowerCase()] ?? 'calm';
  }
}
