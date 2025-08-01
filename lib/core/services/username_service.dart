import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/logger.dart';

class UsernameService {
  static final Dio _dio = Dio();
  static final Random _random = Random();

  static final Map<String, List<String>> _apiCache = {};
  static DateTime? _lastApiFetch;
  static const Duration _cacheTimeout = Duration(hours: 1);

  static List<String> _dynamicAdjectives = [];
  static List<String> _dynamicNouns = [];
  static List<String> _dynamicEmotions = [];
  static DateTime? _lastWordFetch;
  static const Duration _wordCacheTimeout = Duration(hours: 6);

  static const List<String> _fallbackWords = [
    'bright',
    'swift',
    'calm',
    'star',
    'ocean',
    'joy',
    'peace',
  ];

  UsernameService() {
    _configureDio();
  }

  static void _configureDio() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'EmoraApp/1.0',
      },
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (obj) => Logger.info('🌐 API: $obj'),
        ),
      );
    }
  }

  static String? validateUsernameFormat(String username) {
    if (username.isEmpty) {
      return 'Username cannot be empty';
    }

    if (username.length < 3) {
      return 'Username must be at least 3 characters long';
    }

    if (username.length > 20) {
      return 'Username must be less than 20 characters';
    }

    final validPattern = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!validPattern.hasMatch(username)) {
      return 'Username can only contain letters, numbers, underscore, and hyphen';
    }

    if (!RegExp(r'^[a-zA-Z]').hasMatch(username)) {
      return 'Username must start with a letter';
    }

    if (_containsInappropriateContent(username.toLowerCase())) {
      return 'Username contains inappropriate content';
    }

return null; 
  }

  static bool _containsInappropriateContent(String username) {
    const inappropriateWords = [
      'admin',
      'root',
      'user',
      'test',
      'null',
      'undefined',
      'system',
      'api',
      'bot',
      'spam',
      'fake',
      'official',
      'support',
      'help',
      'moderator',
      'emora',
      'app',
      'service',
      'server',
      'database',
    ];

    return inappropriateWords.any((word) => username.contains(word));
  }

  Future<List<String>> generateCreativeUsernames({
    String? baseName,
    int count = 8,
    bool includeNumbers = true,
  }) async {
    Logger.info('💡 Generating automated creative usernames...');

    await _ensureFreshWordData();

    final suggestions = <String>[];
    final usedSuggestions = <String>{};

    try {
      while (suggestions.length < count) {
        final suggestion = await _generateDynamicUsername(
          baseName: baseName,
          includeNumbers: includeNumbers,
          usedSuggestions: usedSuggestions,
        );

        if (suggestion != null &&
            !usedSuggestions.contains(suggestion) &&
            validateUsernameFormat(suggestion) == null) {
          suggestions.add(suggestion);
          usedSuggestions.add(suggestion);
        }
      }

      Logger.info('. Generated ${suggestions.length} automated suggestions');
    } catch (e) {
      Logger.warning('. Error in generation, using fallback: $e');

      final fallbackSuggestions = _generateFallbackSuggestions(
        baseName: baseName,
        count: count - suggestions.length,
        includeNumbers: includeNumbers,
        usedSuggestions: usedSuggestions,
      );
      suggestions.addAll(fallbackSuggestions);
    }

    suggestions.shuffle(_random);
    return suggestions.take(count).toList();
  }

  Future<void> _ensureFreshWordData() async {
    final now = DateTime.now();

    if (_lastWordFetch != null &&
        now.difference(_lastWordFetch!).compareTo(_wordCacheTimeout) < 0 &&
        _dynamicAdjectives.isNotEmpty &&
        _dynamicNouns.isNotEmpty &&
        _dynamicEmotions.isNotEmpty) {
      Logger.info('📦 Using cached word data');
      return;
    }

    Logger.info('🔄 Refreshing word data from APIs...');

    try {
      await Future.wait([
        _fetchAdjectivesFromAPI(),
        _fetchNounsFromAPI(),
        _fetchEmotionWordsFromAPI(),
      ]);

      _lastWordFetch = now;
      Logger.info('. Word data refreshed successfully');
      Logger.info(
        '. Words: ${_dynamicAdjectives.length} adjectives, ${_dynamicNouns.length} nouns, ${_dynamicEmotions.length} emotions',
      );
    } catch (e) {
      Logger.warning('. Failed to refresh word data: $e');

      if (_dynamicAdjectives.isEmpty ||
          _dynamicNouns.isEmpty ||
          _dynamicEmotions.isEmpty) {
        _useFallbackWords();
      }
    }
  }

  Future<void> _fetchAdjectivesFromAPI() async {
    try {
      final response = await _dio.get(
        'https://api.wordnik.com/v4/words.json/randomWords',
        queryParameters: {
          'hasDictionaryDef': 'true',
          'includePartOfSpeech': 'adjective',
          'minCorpusCount': 1000,
          'minLength': 4,
          'maxLength': 10,
          'limit': 50,
          'api_key': 'a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5',
        },
      );

      if (response.statusCode == 200) {
        final words = response.data as List;
        _dynamicAdjectives = words
            .map((w) => w['word'] as String?)
            .where((w) => w != null && w.length >= 4 && w.length <= 10)
            .map((w) => w!.toLowerCase())
            .where((w) => !_containsInappropriateContent(w))
            .take(40)
            .toList();
      }
    } catch (e) {
      Logger.warning('. Failed to fetch adjectives: $e');
    }
  }

  Future<void> _fetchNounsFromAPI() async {
    try {
      final response = await _dio.get(
        'https://api.wordnik.com/v4/words.json/randomWords',
        queryParameters: {
          'hasDictionaryDef': 'true',
          'includePartOfSpeech': 'noun',
          'minCorpusCount': 1000,
          'minLength': 4,
          'maxLength': 10,
          'limit': 50,
          'api_key': 'a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5',
        },
      );

      if (response.statusCode == 200) {
        final words = response.data as List;
        _dynamicNouns = words
            .map((w) => w['word'] as String?)
            .where((w) => w != null && w.length >= 4 && w.length <= 10)
            .map((w) => w!.toLowerCase())
            .where((w) => !_containsInappropriateContent(w))
            .take(40)
            .toList();
      }

      await _fetchNatureWords();
    } catch (e) {
      Logger.warning('. Failed to fetch nouns: $e');
    }
  }

  Future<void> _fetchNatureWords() async {
    try {
      final categories = ['animal', 'nature', 'weather', 'space', 'ocean'];

      for (final category in categories) {
        try {
          final response = await _dio.get(
            'https://api.wordnik.com/v4/words.json/search/$category',
            queryParameters: {
              'minCorpusCount': 500,
              'minLength': 4,
              'maxLength': 10,
              'limit': 10,
              'api_key': 'a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5',
            },
          );

          if (response.statusCode == 200) {
            final searchResults = response.data;
            if (searchResults['searchResults'] != null) {
              final words = searchResults['searchResults'] as List;
              final categoryWords = words
                  .map((w) => w['word'] as String?)
                  .where((w) => w != null && w.length >= 4 && w.length <= 10)
                  .map((w) => w!.toLowerCase())
                  .where((w) => !_containsInappropriateContent(w))
                  .toList();

              _dynamicNouns.addAll(categoryWords);
            }
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      Logger.warning('. Failed to fetch nature words: $e');
    }
  }

  Future<void> _fetchEmotionWordsFromAPI() async {
    try {
      final emotionKeywords = ['emotion', 'feeling', 'mood', 'spirit'];

      for (final keyword in emotionKeywords) {
        try {
          final response = await _dio.get(
            'https://api.wordnik.com/v4/words.json/search/$keyword',
            queryParameters: {
              'minCorpusCount': 500,
              'minLength': 3,
              'maxLength': 8,
              'limit': 10,
              'api_key': 'a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5',
            },
          );

          if (response.statusCode == 200) {
            final searchResults = response.data;
            if (searchResults['searchResults'] != null) {
              final words = searchResults['searchResults'] as List;
              final emotionWords = words
                  .map((w) => w['word'] as String?)
                  .where((w) => w != null && w.length >= 3 && w.length <= 8)
                  .map((w) => w!.toLowerCase())
                  .where((w) => !_containsInappropriateContent(w))
                  .toList();

              _dynamicEmotions.addAll(emotionWords);
            }
          }
        } catch (e) {
          continue;
        }
      }

      if (_dynamicEmotions.length < 10) {
        _dynamicEmotions.addAll([
          'joy',
          'peace',
          'calm',
          'zen',
          'glow',
          'spark',
          'flow',
          'vibe',
          'aura',
          'bliss',
          'grace',
          'charm',
          'smile',
          'dream',
          'hope',
        ]);
      }
    } catch (e) {
      Logger.warning('. Failed to fetch emotion words: $e');
    }
  }

  Future<String?> _generateDynamicUsername({
    String? baseName,
    bool includeNumbers = true,
    Set<String>? usedSuggestions,
  }) async {
    final used = usedSuggestions ?? <String>{};

    if (baseName != null && baseName.isNotEmpty) {
      final cleanBase = baseName.toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]'),
        '',
      );
      if (cleanBase.length >= 2) {
        final patterns = [
          '$cleanBase${_getRandomWord(_dynamicEmotions)}',
          '${_getRandomWord(_dynamicAdjectives)}$cleanBase',
          '$cleanBase${_random.nextInt(999)}',
        ];

        for (final pattern in patterns) {
          if (!used.contains(pattern) &&
              validateUsernameFormat(pattern) == null) {
            return pattern;
          }
        }
      }
    }

    final generationStrategies = [
      () =>
          '${_getRandomWord(_dynamicAdjectives)}_${_getRandomWord(_dynamicNouns)}',
      () =>
          '${_getRandomWord(_dynamicAdjectives)}${_getRandomWord(_dynamicNouns)}',
      () =>
          '${_getRandomWord(_dynamicEmotions)}_${_getRandomWord(_dynamicNouns)}',
      () => '${_getRandomWord(_dynamicNouns)}${_random.nextInt(999)}',
      () => '${_getRandomWord(_dynamicAdjectives)}${_random.nextInt(99)}',
      () =>
          '${_getRandomWord(_dynamicEmotions)}${_getRandomWord(_dynamicAdjectives)}',
    ];

    for (final strategy in generationStrategies) {
      try {
        final suggestion = strategy();
        if (!used.contains(suggestion) &&
            validateUsernameFormat(suggestion) == null) {
          return suggestion;
        }
      } catch (e) {
        continue;
      }
    }

    return null;
  }

  static String _getRandomWord(List<String> words) {
    if (words.isEmpty) {
      return _fallbackWords[_random.nextInt(_fallbackWords.length)];
    }
    return words[_random.nextInt(words.length)];
  }

  static void _useFallbackWords() {
    Logger.info('📦 Using fallback word lists');

    _dynamicAdjectives = ['bright', 'swift', 'calm'];
    _dynamicNouns = ['star', 'ocean', 'dream'];
    _dynamicEmotions = ['joy', 'peace', 'zen'];
  }

  List<String> _generateFallbackSuggestions({
    String? baseName,
    int count = 8,
    bool includeNumbers = true,
    Set<String>? usedSuggestions,
  }) {
    final suggestions = <String>[];
    final used = usedSuggestions ?? <String>{};

    while (suggestions.length < count) {
      String suggestion;

      if (baseName != null && baseName.isNotEmpty) {
        final cleanBase = baseName.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9]'),
          '',
        );
        suggestion = '$cleanBase${_random.nextInt(9999)}';
      } else {
        final word1 = _fallbackWords[_random.nextInt(_fallbackWords.length)];
        final word2 = _fallbackWords[_random.nextInt(_fallbackWords.length)];
        suggestion = '$word1$word2${_random.nextInt(99)}';
      }

      if (!used.contains(suggestion) &&
          validateUsernameFormat(suggestion) == null) {
        suggestions.add(suggestion);
        used.add(suggestion);
      }
    }

    return suggestions;
  }

  static String getAvailabilityMessage(bool isAvailable, String username) {
    if (isAvailable) {
      return '. Great choice! "$username" is available';
    } else {
      return '. "$username" is already taken. Try something unique!';
    }
  }

  static List<String> getUsernameTips() {
    return [
      '💡 Our suggestions are automatically generated from fresh word databases',
      '🎭 Words are fetched from linguistic APIs for creativity and uniqueness',
      '🔒 Keep it private - don\'t include personal information',
      '✨ We combine adjectives, nouns, and emotions dynamically',
      '🌟 Shorter usernames are often easier to remember',
      '🎯 Each generation pulls new words from online dictionaries',
      '🌐 Our system learns from multiple vocabulary sources',
      '🔄 Refresh for completely new automated suggestions',
    ];
  }

  static String getRandomTip() {
    final tips = getUsernameTips();
    return tips[_random.nextInt(tips.length)];
  }

  static bool appearsToBeRealName(String username) {
    final lowerUsername = username.toLowerCase();

    final namePatterns = [
      RegExp(r'^[a-z]+[0-9]{1,4}$'),
      RegExp(r'^[a-z]+_[a-z]+$'),
      RegExp(r'^[a-z]+\.[a-z]+$'),
    ];

    return namePatterns.any((pattern) => pattern.hasMatch(lowerUsername));
  }

  static String getRealNameWarning() {
    return '. Consider using a more creative username instead of your real name for better privacy and safety.';
  }

  static void clearCache() {
    _apiCache.clear();
    _lastApiFetch = null;
    _dynamicAdjectives.clear();
    _dynamicNouns.clear();
    _dynamicEmotions.clear();
    _lastWordFetch = null;
    Logger.info('🧹 Username service cache cleared');
  }

  static Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    final isApiCacheValid = _lastApiFetch != null
        ? now.difference(_lastApiFetch!).compareTo(_cacheTimeout) < 0
        : false;
    final isWordCacheValid = _lastWordFetch != null
        ? now.difference(_lastWordFetch!).compareTo(_wordCacheTimeout) < 0
        : false;

    return {
      'cached_sources': _apiCache.keys.length,
      'total_suggestions': _apiCache.values.fold<int>(
        0,
        (sum, list) => sum + list.length,
      ),
      'api_cache_valid': isApiCacheValid,
      'word_cache_valid': isWordCacheValid,
      'dynamic_adjectives': _dynamicAdjectives.length,
      'dynamic_nouns': _dynamicNouns.length,
      'dynamic_emotions': _dynamicEmotions.length,
      'automation_status': _dynamicAdjectives.isNotEmpty
          ? 'active'
          : 'fallback',
    };
  }

  static Future<void> forceRefreshWords() async {
    _lastWordFetch = null;
    _dynamicAdjectives.clear();
    _dynamicNouns.clear();
    _dynamicEmotions.clear();

    final service = UsernameService();
    await service._ensureFreshWordData();

    Logger.info('🔄 Forced word data refresh completed');
  }

  static Map<String, dynamic> getWordStats() {
    return {
      'adjectives_count': _dynamicAdjectives.length,
      'nouns_count': _dynamicNouns.length,
      'emotions_count': _dynamicEmotions.length,
      'last_refresh': _lastWordFetch?.toIso8601String(),
      'cache_expires': _lastWordFetch?.add(_wordCacheTimeout).toIso8601String(),
      'sample_adjectives': _dynamicAdjectives.take(5).toList(),
      'sample_nouns': _dynamicNouns.take(5).toList(),
      'sample_emotions': _dynamicEmotions.take(5).toList(),
    };
  }
}
