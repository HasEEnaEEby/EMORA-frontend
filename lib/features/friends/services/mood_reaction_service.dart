// lib/features/friends/services/mood_reaction_service.dart

import 'package:flutter/material.dart';
import 'package:emora_mobile_app/core/network/dio_client.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';

class MoodReactionService {
  final DioClient _dioClient;

  MoodReactionService(this._dioClient);

  /// Send a reaction to a friend's mood
  Future<bool> sendReaction({
    required String moodId,
    required String reactionType,
    String? message,
    bool isAnonymous = false,
  }) async {
    try {
      Logger.info('💝 Sending $reactionType reaction to mood: $moodId');

      final response = await _dioClient.post(
        '/api/friends/moods/$moodId/reactions',
        data: {
          'reactionType': reactionType,
          if (message != null) 'message': message,
          'isAnonymous': isAnonymous,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          Logger.info('✅ Reaction sent successfully');
          return true;
        } else {
          Logger.warning('⚠️ Server returned success=false: ${responseData['message']}');
          return false;
        }
      } else {
        Logger.error('❌ Failed to send reaction: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      Logger.error('❌ Error sending reaction: $e');
      return false;
    }
  }

  /// Get friend's recent moods
  Future<List<Map<String, dynamic>>> getFriendMoods({
    required String friendId,
    int limit = 5,
  }) async {
    try {
      Logger.info('😊 Fetching moods for friend: $friendId');

      final response = await _dioClient.get(
        '/api/friends/$friendId/moods',
        queryParameters: {
          'limit': limit,
          'includeReactions': true,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          final moods = responseData['data']['moods'] as List? ?? [];
          Logger.info('✅ Friend moods fetched successfully: ${moods.length} moods');
          return moods.cast<Map<String, dynamic>>();
        } else {
          Logger.warning('⚠️ Server returned success=false: ${responseData['message']}');
          return [];
        }
      } else {
        Logger.error('❌ Failed to fetch friend moods: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      Logger.error('❌ Error fetching friend moods: $e');
      return [];
    }
  }

  /// Get friend's latest mood
  Future<Map<String, dynamic>?> getFriendLatestMood({
    required String friendId,
  }) async {
    try {
      final moods = await getFriendMoods(friendId: friendId, limit: 1);
      if (moods.isNotEmpty) {
        return moods.first;
      }
      return null;
    } catch (e) {
      Logger.error('❌ Error fetching friend latest mood: $e');
      return null;
    }
  }
} 