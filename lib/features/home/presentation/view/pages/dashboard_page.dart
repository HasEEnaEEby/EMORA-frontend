import 'package:emora_mobile_app/app/di/injection_container.dart' as di;
import 'package:emora_mobile_app/features/emotion/presentation/view/pages/mood_atlas_view.dart';
import 'package:emora_mobile_app/features/home/presentation/view/pages/enhanced_insights_view.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_bloc.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_event.dart' as home_events;
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_state.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/community_bloc.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/community_event.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/community_feed_widget.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/custom_mood_face.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/dashboard_modals.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/emotion_analytics_card.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/todays_journey_widget.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/emotion_calendar_widget.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/enhanced_emotion_entry_modal.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/dashboard_header.dart' hide MoodUtils;
import 'package:emora_mobile_app/features/home/data/model/emotion_entry_model.dart' show WeeklyInsightsModel, EmotionEntryModel;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../../../core/navigation/app_router.dart';
import '../../../../../core/navigation/navigation_service.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../features/emotion/presentation/view_model/bloc/emotion_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

IO.Socket? socket;

void connectSocket(String userId, BuildContext context) {
  socket = IO.io('http:////localhost:3000', {
    'transports': ['websocket'],
    'autoConnect': false,
  });

  socket!.connect();

  socket!.on('connect', (_) {
    socket!.emit('join', {'room': 'user:$userId'});
  });
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommunityBloc>(
      create: (context) => GetIt.instance<CommunityBloc>()
        ..add(const LoadGlobalFeedEvent())
        ..add(const LoadGlobalStatsEvent()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return _DashboardContent(homeState: state);
        },
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  final HomeState homeState;

  const _DashboardContent({required this.homeState});

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent>
    with TickerProviderStateMixin {
  late HomeBloc? _homeBloc;
  late CommunityBloc? _communityBloc;
  late EmotionBloc? _emotionBloc;

  late AnimationController _breathingController;
  late AnimationController _rippleController;
  late AnimationController _glowController;

  bool _isNewUser = false;
  bool _isLoading = false;
  String _errorMessage = '';
  MoodType currentMood = MoodType.okay;
  String currentMoodLabel = 'Okay';

  List<Map<String, dynamic>> _emotionHistory = [];
  List<Map<String, dynamic>> _todaysJourney = [];
  List<Map<String, dynamic>> _calendarData = [];

  List<Map<String, dynamic>> _communityPosts = [];
  bool _isCommunityLoading = false;

  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _achievements = [];
  bool _isProfileLoading = false;

  Map<String, dynamic> _analyticsData = {};
  bool _isAnalyticsLoading = false;

  String _selectedEmotion = '';
  int _emotionIntensity = 3;
  String _emotionNote = '';
  List<String> _emotionTags = [];
  bool _shareToCommunity = false;
  bool _isAnonymous = false;

  DateTime _selectedDate = DateTime.now();
  bool _isCalendarLoading = false;

  Map<String, dynamic>? _selectedEmotionDetail;
  bool _isEmotionDetailLoading = false;

  Map<String, dynamic>? _editingEmotion;
  bool _isEditing = false;
  bool _isDeleting = false;

  List<Map<String, dynamic>> _notifications = [];
  bool _hasNotifications = false;
  int _notificationCount = 0;
  IO.Socket? _socket;

  bool get _isUserNew {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      
      final homeData = dashboardState.homeData;
      if (homeData != null) {
        final isNew = homeData.isNewUser;
        print('🔍 DEBUG: _isUserNew from HomeDataModel.isNewUser: $isNew');
        print('🔍 DEBUG: HomeDataModel.totalEmotions: ${homeData.totalEmotions}');
        return isNew;
      }
      
      final emotionEntriesCount = dashboardState.emotionEntries.length;
      final isNew = emotionEntriesCount == 0;
      print('🔍 DEBUG: _isUserNew fallback from emotionEntries: $isNew (count: $emotionEntriesCount)');
      return isNew;
    }
    
    print('🔍 DEBUG: _isUserNew default: true (not HomeDashboardState)');
    return true;
  }

  List<EmotionEntryModel> get _emotionEntries {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      final entries = dashboardState.emotionEntries;
      
      print('🔍 DEBUG: Emotion entries from state: ${entries.length}');
      
      if (entries.isEmpty) {
        final homeData = dashboardState.homeData;
        if (homeData != null) {
          final recentEmotions = homeData.recentEmotions;
          print('🔍 DEBUG: Recent emotions from homeData: ${recentEmotions.length}');
          
          final convertedEntries = recentEmotions.map((emotionData) {
            return EmotionEntryModel.fromJson({
              'id': emotionData['id'],
              'emotion': emotionData['emotion'] ?? emotionData['type'],
              'intensity': emotionData['intensity'] ?? 5,
              'note': emotionData['note'] ?? '',
              'timestamp': emotionData['timestamp'] ?? emotionData['date'],
              'tags': emotionData['tags'] ?? [],
              'hasLocation': emotionData['hasLocation'] ?? false,
            });
          }).toList();
          
          print('🔍 DEBUG: Converted ${convertedEntries.length} emotions from homeData');
          return convertedEntries;
        }
      }
      
      return entries;
    }
    return [];
  }

  List<EmotionEntryModel> get _todaysEmotions {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    final todaysEmotions = _emotionEntries.where((emotion) {
      return emotion.createdAt.isAfter(todayStart) && 
             emotion.createdAt.isBefore(todayEnd);
    }).toList();
    
    print('🔍 DEBUG: Today\'s emotions found: ${todaysEmotions.length}');
    for (final emotion in todaysEmotions) {
      print('  - ${emotion.emotion} at ${emotion.createdAt}');
    }
    
    return todaysEmotions;
  }

  get _weeklyInsights {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      return dashboardState.weeklyInsights;
    }
    return null;
  }

  int get _totalLogs {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      return dashboardState.userStats?.totalMoodEntries ?? 0;
    }
    return 0;
  }

  int get _currentStreak {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      return dashboardState.userStats?.streakDays ?? 0;
    }
    return 0;
  }

  double get _averageMood {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      return dashboardState.userStats?.averageMoodScore ?? 0.0;
    }
    return 0.0;
  }

  List<MoodCapsule>? get _moodCapsulesData {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      return null;
    }
    return null;
  }

  List<Map<String, dynamic>>? get _communityPostsData {
    return null;
  }

  List<Map<String, dynamic>>? get _weeklyMoodData {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      
      print('🔍 DEBUG: _weeklyMoodData - emotionEntries.length: ${_emotionEntries.length}');
      
      if (_emotionEntries.isNotEmpty) {
        print('🔍 DEBUG: Generating weekly mood data from ${_emotionEntries.length} emotion entries');
        
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        
        final weeklyData = List.generate(7, (index) {
          final day = weekStart.add(Duration(days: index));
          final dayEmotions = _emotionEntries.where((emotion) {
            final emotionDate = DateTime(
              emotion.createdAt.year,
              emotion.createdAt.month,
              emotion.createdAt.day,
            );
            final checkDate = DateTime(day.year, day.month, day.day);
            return emotionDate.isAtSameMomentAs(checkDate);
          }).toList();
          
          final avgIntensity = dayEmotions.isNotEmpty
              ? dayEmotions.map((e) => e.intensity).reduce((a, b) => a + b) / dayEmotions.length
              : 0.0;
          
          final dayData = {
            'day': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
'intensity': avgIntensity / 5.0, 
            'color': _getMoodColor(avgIntensity),
          };
          
          print('🔍 DEBUG: Day ${dayData['day']}: ${dayEmotions.length} emotions, avg intensity: $avgIntensity');
          return dayData;
        });
        
        print('🔍 DEBUG: Generated weekly mood data: ${weeklyData.length} days');
        return weeklyData;
      } else {
        print('🔍 DEBUG: No emotion entries available for weekly mood data');
      }
    }
    return null;
  }

  Map<String, dynamic>? get _analyticsDataGetter {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      
      print('🔍 DEBUG: _analyticsDataGetter - emotionEntries.length: ${_emotionEntries.length}');
      
      if (_emotionEntries.isNotEmpty) {
        final totalEntries = _emotionEntries.length;
        final avgIntensity = _emotionEntries.map((e) => e.intensity).reduce((a, b) => a + b) / totalEntries;
        
        final recentEmotions = _emotionEntries.take(5).toList();
        final recentAvg = recentEmotions.isNotEmpty
            ? recentEmotions.map((e) => e.intensity).reduce((a, b) => a + b) / recentEmotions.length
            : avgIntensity;
        
        String moodTrend;
        if (recentAvg > avgIntensity + 0.5) {
          moodTrend = 'improving';
        } else if (recentAvg < avgIntensity - 0.5) {
          moodTrend = 'needs_attention';
        } else {
          moodTrend = 'stable';
        }
        
        final analyticsData = {
          'totalEntries': totalEntries,
          'averageIntensity': avgIntensity,
          'moodTrend': moodTrend,
          'musicRecommendation': _getMusicRecommendation(avgIntensity),
          'dominantEmotion': _emotionEntries.isNotEmpty ? _emotionEntries.first.emotion : null,
        };
        
        print('🔍 DEBUG: Generated analytics data: $analyticsData');
        return analyticsData;
      } else {
        print('🔍 DEBUG: No emotion entries available for analytics data');
      }
    }
    return null;
  }

  Color _getMoodColor(double intensity) {
if (intensity >= 4.0) return const Color(0xFF4CAF50); 
if (intensity >= 3.0) return const Color(0xFF8B5CF6); 
if (intensity >= 2.0) return const Color(0xFFFFD700); 
return const Color(0xFFFF6B6B); 
  }

  String _getMusicRecommendation(double avgIntensity) {
    if (avgIntensity >= 4.0) {
      return 'Upbeat pop with positive vibes';
    } else if (avgIntensity >= 3.0) {
      return 'Reflective indie with hopeful undertones';
    } else if (avgIntensity >= 2.0) {
      return 'Calming ambient with gentle melodies';
    } else {
      return 'Soothing instrumental for emotional support';
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSocket();
loadInboxNotifications(); 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMoodFromCurrentState();
      _initializeBackendServices();
      _loadInitialData();
      _loadEnhancedDashboardData();
    });
  }

  void _initializeSocket() {
    try {
      final currentUserId = getCurrentUserId();
      if (currentUserId != null) {
        _socket = IO.io('http:////localhost:3000', {
          'transports': ['websocket'],
          'autoConnect': false,
        });
        _socket!.connect();
        _socket!.on('connect', (_) {
          print('🔌 Socket connected');
          _socket!.emit('join', {'room': 'user:$currentUserId'});
        });
        _socket!.on('new_message', (data) {
          print('📱 New message received: $data');
          _handleNewMessage(data);
        });
        _socket!.on('disconnect', (_) {
          print('🔌 Socket disconnected');
        });
      }
    } catch (e) {
      print('❌ Error initializing socket: $e');
    }
  }

  String? getCurrentUserId() {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      final homeData = dashboardState.homeData;
      final data = homeData.dashboardData['data'];
      if (data != null && data['user'] != null && data['user']['id'] != null) {
        return data['user']['id'] as String;
      }
    }
    return '687ab32176d3e5066eaa6431';
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    setState(() {
      _notifications.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'senderName': data['senderName'] ?? 'Unknown',
        'senderAvatar': data['senderAvatar'],
        'content': data['content'] ?? '',
        'senderId': data['senderId'],
        'sentAt': data['sentAt'] ?? DateTime.now().toIso8601String(),
        'isRead': false,
        'type': 'message',
      });
      _notificationCount = _notifications.length;
      _hasNotifications = _notifications.isNotEmpty;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.message, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('New message from ${data['senderName']}: ${data['content']}'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF8B5CF6),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              _showNotifications();
            },
          ),
        ),
      );
    }
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.notifications, color: Color(0xFF8B5CF6)),
            const SizedBox(width: 12),
            const Text('Notifications', style: TextStyle(color: Colors.white)),
            const Spacer(),
            if (_hasNotifications)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _notificationCount > 9 ? '9+' : '$_notificationCount',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, color: Colors.grey, size: 48),
                      SizedBox(height: 16),
                      Text('No new notifications', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: notification['isRead'] == true
                            ? Colors.grey.withOpacity(0.1)
                            : const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: notification['isRead'] == true
                              ? Colors.grey.withOpacity(0.2)
                              : const Color(0xFF8B5CF6).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (notification['senderAvatar'] != null)
                                CircleAvatar(
                                  backgroundImage: AssetImage('assets/images/avatars/${notification['senderAvatar']}.png'),
                                  radius: 16,
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  notification['senderName'] ?? 'System',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                _formatNotificationTime(notification['sentAt']),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification['content'] ?? '',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          if (_hasNotifications)
            TextButton(
              onPressed: () {
                _clearNotifications();
                Navigator.pop(context);
              },
              child: const Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF8B5CF6))),
          ),
        ],
      ),
    );
  }

  void _clearNotifications() {
    setState(() {
      _notifications.clear();
      _notificationCount = 0;
      _hasNotifications = false;
    });
  }

  void _markNotificationAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
  }

  String _formatNotificationTime(String? timeStr) {
    if (timeStr == null) return '';
    try {
      final time = DateTime.parse(timeStr);
      final now = DateTime.now();
      final diff = now.difference(time);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return '';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureEmotionDataLoaded();
      _ensureHomeDataLoaded();
_updateMoodFromCurrentState(); 
    });
  }

  void _updateMoodFromCurrentState() {
    try {
      if (widget.homeState is HomeDashboardState) {
        final dashboardState = widget.homeState as HomeDashboardState;
        
        if (dashboardState.emotionEntries.isNotEmpty) {
          final latestEmotion = dashboardState.emotionEntries.first;
          setState(() {
            currentMood = _mapEmotionToMoodType(latestEmotion.emotion);
            currentMoodLabel = _getEmotionDisplayName(latestEmotion.emotion);
          });
          print('🔄 Updated mood from emotion entries: $currentMoodLabel');
          return;
        }
        
        final homeData = dashboardState.homeData;
        if (homeData != null) {
          final recentEmotions = homeData.recentEmotions;
          if (recentEmotions.isNotEmpty) {
            final latest = recentEmotions.first;
            final emotionType = latest['emotion'] ?? latest['type'] ?? 'calm';
            setState(() {
              currentMood = _mapEmotionToMoodType(emotionType);
              currentMoodLabel = _getEmotionDisplayName(emotionType);
            });
            print('🔄 Updated mood from homeData recent emotions: $currentMoodLabel');
            return;
          }
        }
        
        print('⚠️ No emotions found to update mood from');
      }
    } catch (e) {
      print('❌ Error updating mood from current state: $e');
    }
  }

  void _ensureHomeDataLoaded() {
    try {
      if (_homeBloc != null && !_homeBloc!.isClosed) {
        print('🔄 Ensuring home data is loaded...');
        
        if (widget.homeState is HomeDashboardState) {
          final dashboardState = widget.homeState as HomeDashboardState;
          final homeData = dashboardState.homeData;
          
          if (homeData == null || !homeData.isValid) {
            print('🔄 Home data is invalid, triggering refresh...');
            _homeBloc!.add(const home_events.LoadHomeDataEvent(forceRefresh: true));
          } else {
            print('✅ Home data is valid: username=${homeData.username}, totalEmotions=${homeData.totalEmotions}');
          }
        } else {
          print('🔄 Not in dashboard state, loading home data...');
          _homeBloc!.add(const home_events.LoadHomeDataEvent(forceRefresh: false));
        }
      }
    } catch (e) {
      print('⚠️ Could not ensure home data is loaded: $e');
    }
  }

  void _safeAddHomeEvent(home_events.HomeEvent event) {
    try {
      if (_homeBloc != null && !_homeBloc!.isClosed) {
        _homeBloc!.add(event);
        Logger.info('✅ Added event to HomeBloc: ${event.runtimeType}');
      } else {
        Logger.warning('⚠️ Cannot add event to HomeBloc - BLoC is null or closed: ${event.runtimeType}');
      }
    } catch (e) {
      Logger.error('❌ Error adding event to HomeBloc: $e');
    }
  }

  void _forceRefreshAllData() {
      print('🔄 Force refreshing all dashboard data...');
      
    _safeAddHomeEvent(const home_events.LoadHomeDataEvent(forceRefresh: true));
      
    _safeAddHomeEvent(const home_events.LoadEmotionHistoryEvent(forceRefresh: true));
      
    _safeAddHomeEvent(const home_events.LoadUserStatsEvent(forceRefresh: true));
      
    _safeAddHomeEvent(const home_events.LoadWeeklyInsightsEvent(forceRefresh: true));
      
      print('✅ All data refresh initiated');
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _updateMoodFromCurrentState();
        }
      });
  }

  void _loadEnhancedDashboardData() {
    try {
      final homeBloc = context.read<HomeBloc>();
      
      Logger.info('🎭 Loading enhanced dashboard data with persistence...');
      
      homeBloc.add(const home_events.LoadEmotionHistoryEvent(forceRefresh: false));
      
      homeBloc.add(const home_events.LoadWeeklyInsightsEvent(forceRefresh: false));
      
      homeBloc.add(const home_events.LoadTodaysJourneyEvent(forceRefresh: false));
      
      homeBloc.add(home_events.LoadEmotionCalendarEvent(
        month: DateTime.now(),
        forceRefresh: false,
      ));
      
      Logger.info('✅ Enhanced dashboard data loading initiated with persistence');
      
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _updateMoodFromCurrentState();
        }
      });
    } catch (e) {
      Logger.error('❌ Failed to load enhanced dashboard data', e);
    }
  }

  Future<void> _loadCachedEmotionDataImmediately() async {
    try {
      Logger.info('📦 Loading cached emotion data immediately for dashboard...');
    } catch (e) {
      Logger.warning('⚠️ Could not load cached emotion data immediately: $e');
    }
  }

  void _ensureEmotionDataLoaded() {
    try {
      if (_emotionEntries.isEmpty && _homeBloc != null && !_homeBloc!.isClosed) {
        Logger.info('🔄 No emotion entries found, triggering emotion history load...');
        _homeBloc!.add(const home_events.LoadEmotionHistoryEvent(forceRefresh: false));
      } else {
        Logger.info('✅ Emotion entries already loaded: ${_emotionEntries.length} entries');
      }
    } catch (e) {
      Logger.warning('⚠️ Could not ensure emotion data is loaded: $e');
    }
  }

  void _testLogEmotion() async {
    try {
      Logger.info('🧪 Testing emotion logging...');
      
      if (_homeBloc != null && !_homeBloc!.isClosed) {
        _homeBloc!.add(home_events.LogEmotionEvent(
          emotion: 'joy',
          intensity: 4,
          note: 'Test emotion from dashboard',
          tags: ['test', 'debug'],
          location: {
            'latitude': 37.785834,
            'longitude': -122.406417,
            'name': 'San Francisco, CA',
          },
          context: {
            'activity': 'testing',
            'environment': 'development',
          },
        ));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🧪 Test emotion logged! Check analytics...'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      Logger.error('❌ Error logging test emotion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _initializeAnimations() {
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _initializeBackendServices() {
    try {
      if (!mounted) return;

      try {
        final dioClient = GetIt.instance<DioClient>();
        Logger.info('✅ DIO client initialized');
      } catch (e) {
        Logger.warning('⚠️ Could not initialize DIO client: $e');
      }

      try {
        _emotionBloc = GetIt.instance<EmotionBloc>();
        Logger.info('✅ EmotionBloc retrieved from GetIt');
      } catch (e) {
        Logger.warning('⚠️ Could not get EmotionBloc: $e');
      }

      try {
        _homeBloc = context.read<HomeBloc>();
        Logger.info('✅ HomeBloc retrieved from context successfully');
      } catch (e) {
        Logger.warning('⚠️ HomeBloc access failed, trying GetIt: $e');
        try {
          _homeBloc = GetIt.instance<HomeBloc>();
          Logger.info('✅ HomeBloc retrieved from GetIt as fallback');
        } catch (e2) {
          Logger.error('❌ Could not get HomeBloc from anywhere: $e2');
        }
      }

      Logger.info('✅ Backend services initialization completed');
      _testBackendConnection();
    } catch (e) {
      Logger.error('❌ Failed to initialize backend services', e);
    }
  }

  Future<void> _testBackendConnection() async {
    try {
      if (_homeBloc != null && !_homeBloc!.isClosed) {
        _homeBloc!.add(const home_events.RefreshHomeDataEvent());
        Logger.info('✅ Backend connection test initiated via HomeBloc');
      }
    } catch (e) {
      Logger.warning('⚠️ Backend connection test failed: $e');
    }
  }

  void _loadInitialData() {
    try {
      Logger.info('🎭 Dashboard initialized - loading enhanced emotion data with persistence');
      
      if (_homeBloc != null && !_homeBloc!.isClosed) {
        _homeBloc!.add(const home_events.InitializeHomeEvent(initialData: {}));
      }
    } catch (e) {
      Logger.error('❌ Failed to load initial data', e);
    }
  }

  void _onNavItemTapped(int index) {
    _preserveCurrentState();
    
    switch (index) {
case 0: 
        _navigateToMoodAtlas();
        break;
case 1: 
        NavigationService.pushNamed(AppRouter.friends);
        break;
case 2: 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EnhancedInsightsView(),
          ),
        ).then((_) {
          _restoreStateAfterNavigation();
        });
        break;
case 3: 
        NavigationService.pushNamed(AppRouter.profile);
        break;
    }
  }

  void _preserveCurrentState() {
    final preservedMood = currentMood;
    final preservedLabel = currentMoodLabel;
    
    print('🔒 Preserving state: mood=$preservedLabel, emotions=${_emotionEntries.length}');
  }

  void _restoreStateAfterNavigation() {
    print('🔄 Restoring state after navigation...');
    
    _forceRefreshAllData();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMoodFromCurrentState();
    });
  }

  void _onMoodTapped() {
    _showCustomMoodSelector();
  }

  void _navigateToMoodAtlas() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          EmotionBloc? emotionBloc;
          try {
            emotionBloc = context.read<EmotionBloc>();
            print('✅ Found EmotionBloc in dashboard context');
          } catch (e) {
            print('⚠️ EmotionBloc not found in dashboard: $e');
          }

          if (emotionBloc != null) {
            return BlocProvider.value(
              value: emotionBloc,
              child: const MoodAtlasView(),
            );
          } else {
            return BlocProvider(
              create: (context) => di.sl<EmotionBloc>(),
              child: const MoodAtlasView(),
            );
          }
        },
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _forceRefreshEmotionData() {
    if (_homeBloc != null && !_homeBloc!.isClosed) {
      _homeBloc!.add(const home_events.LoadEmotionHistoryEvent(forceRefresh: true));
      print('🔍 DEBUG: Forced refresh of emotion data');
    }
  }

  void _handleEnhancedEmotionLog({String? emotionType, int? intensity, String? note}) {
    print('🎭 Enhanced emotion log handler called');
    print('🎭 Emotion: $emotionType, Intensity: $intensity');
    
    if (emotionType != null) {
      setState(() {
        currentMood = _mapEmotionToMoodType(emotionType);
        currentMoodLabel = _getEmotionDisplayName(emotionType);
      });
      
      print('🔍 DEBUG: Immediately updated current mood to: $currentMoodLabel ($emotionType)');
    }
    
    NavigationService.showSuccessSnackBar('🎭 Emotion logged successfully!');
    
    print('🔄 Forcing complete data refresh after emotion log...');
    _forceRefreshAllData();
    
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted && _homeBloc != null && !_homeBloc!.isClosed) {
        print('🔄 Secondary data refresh for backend sync...');
        _homeBloc!.add(const home_events.RefreshHomeDataEvent());
_updateMoodFromCurrentState(); 
      }
    });
  }

  void _updateCurrentMoodFromEmotions() {
    if (_emotionEntries.isNotEmpty) {
      final latestEmotion = _emotionEntries.first;
      final emotionType = latestEmotion.emotion;
      
      setState(() {
        currentMood = _mapEmotionToMoodType(emotionType);
        currentMoodLabel = _getEmotionDisplayName(emotionType);
      });
      
      print('🔍 DEBUG: Updated current mood to: $currentMoodLabel ($emotionType)');
      print('🔍 DEBUG: Mood mapped to: $currentMood');
    } else {
      print('⚠️ No emotion entries to update mood from');
    }
  }

  String _getEmotionDisplayName(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'love':
        return 'Love';
      case 'happiness':
      case 'joy':
        return 'Happy';
      case 'excitement':
        return 'Excited';
      case 'gratitude':
        return 'Grateful';
      case 'contentment':
        return 'Content';
      case 'calm':
        return 'Calm';
      case 'sadness':
        return 'Sad';
      case 'anger':
        return 'Angry';
      case 'fear':
        return 'Fearful';
      case 'anxiety':
        return 'Anxious';
      case 'frustration':
        return 'Frustrated';
      case 'disgust':
        return 'Disgusted';
      default:
        return _capitalize(emotion);
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  MoodType _mapEmotionToMoodType(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happiness':
      case 'excitement':
      case 'gratitude':
      case 'love':
      case 'joy':
        return MoodType.good;
      case 'contentment':
      case 'calm':
        return MoodType.okay;
      case 'sadness':
      case 'fear':
      case 'anxiety':
      case 'disgust':
        return MoodType.down;
      case 'anger':
      case 'frustration':
        return MoodType.awful;
      default:
        return MoodType.okay;
    }
  }

  void _showCustomMoodSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedEmotionEntryModal(
        onEmotionLogged: _handleEnhancedEmotionLog,
      ),
    );
  }

  void _showFirstEmotionSuccess() {
    NavigationService.showSuccessSnackBar(
      '🎉 Congratulations! You logged your first emotion!',
    );
  }

  void _postToCommunity(String emotion, int intensity, String? contextText, List<String> tags, bool isAnonymous) {
    try {
      final emotionEmoji = _getEmotionEmoji(emotion);
      
      final postContent = contextText?.isNotEmpty == true 
          ? contextText! 
          : 'Feeling $emotion today';
      
      final communityBloc = context.read<CommunityBloc>();
      
      communityBloc.add(CreateCommunityPostEvent(
        emoji: emotionEmoji,
        note: postContent,
        tags: tags,
        isAnonymous: isAnonymous,
        emotionType: emotion,
        emotionIntensity: intensity,
      ));
      
      Logger.info('🌍 Posted emotion to community: $emotion');
      
    } catch (e) {
      Logger.error('❌ Failed to post to community', e);
      NavigationService.showErrorSnackBar('Emotion logged but failed to post to community.');
    }
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'love':
        return '💖';
      case 'happiness':
      case 'joy':
        return '😊';
      case 'excitement':
        return '🤩';
      case 'gratitude':
        return '🙏';
      case 'contentment':
        return '😌';
      case 'calm':
        return '😌';
      case 'sadness':
        return '😢';
      case 'anger':
        return '😠';
      case 'fear':
        return '😰';
      case 'anxiety':
        return '😰';
      case 'frustration':
        return '😤';
      case 'disgust':
        return '🤢';
      default:
        return '😊';
    }
  }

  Future<void> _handleRefresh() async {
    try {
      print('🔄 Dashboard refresh initiated...');
      
      await Future.delayed(const Duration(milliseconds: 500));
      await _testBackendConnection();

      if (_homeBloc != null && !_homeBloc!.isClosed) {
        _homeBloc!.add(const home_events.RefreshHomeDataEvent());
        _homeBloc!.add(const home_events.LoadEmotionHistoryEvent(forceRefresh: true));
      }

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _updateMoodFromCurrentState();
        }
      });

      Logger.info('🔄 Dashboard refresh completed');
    } catch (e) {
      Logger.error('❌ Error refreshing data', e);
    }
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _breathingController.dispose();
    _rippleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _preserveCurrentState();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0A0F),
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'Emora',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: _showNotifications,
                  ),
                  if (_hasNotifications)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          _notificationCount > 9 ? '9+' : '$_notificationCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0A0A0F),
        body: SafeArea(
          child: BlocListener<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is HomeDashboardState) {
                final homeData = state.homeData;
                final isNewUser = homeData?.isNewUser ?? true;
                
                if (_isNewUser != isNewUser) {
                  setState(() {
                    _isNewUser = isNewUser;
                  });
                  print('🔍 DEBUG: Updated _isNewUser state to: $isNewUser');
                }
                
                _updateMoodFromCurrentState();
                
                if (_emotionEntries.isNotEmpty) {
                  print('🔍 DEBUG: Emotion entries updated: ${_emotionEntries.length} entries');
                  print('🔍 DEBUG: Latest emotion: ${_emotionEntries.first.emotion}');
                  _updateCurrentMoodFromEmotions();
                }
              }
            },
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    backgroundColor: const Color(0xFF1A1A2E),
                    color: const Color(0xFF8B5CF6),
                    child: _buildContent(widget.homeState),
                  ),
                ),
                EnhancedBottomNavigationCustom(
selectedIndex: 0, 
                  onItemTapped: _onNavItemTapped,
                  onMoodTapped: _onMoodTapped,
                  currentMood: currentMood,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(HomeState state) {
    if (state is HomeLoading) {
      return _buildLoadingState();
    } else if (state is HomeError) {
      return _buildErrorState(state.message);
    } else if (state is HomeDashboardState) {
      return _buildDashboardContent(state);
    }
    return _buildLoadingState();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF8B5CF6)),
          SizedBox(height: 16),
          Text(
            'Loading your dashboard...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return _buildEnhancedErrorState(widget.homeState);
  }

  Widget _buildEnhancedErrorState(HomeState state) {
    String message = 'Something went wrong';
    bool canRetry = true;
    String retryAction = 'load_home_data';
    
    if (state is HomeError) {
      message = state.message;
      canRetry = state.canRetry;
      retryAction = state.retryAction ?? 'load_home_data';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _breathingController.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.orange.withOpacity(0.3),
                          Colors.orange.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.wifi_off,
                      color: Colors.orange,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Unable to Load Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            if (canRetry) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _retryOperation(retryAction);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _tryOfflineMode();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[300],
                    side: BorderSide(color: Colors.grey[600]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.offline_bolt, size: 20),
                  label: const Text(
                    'Use Offline Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showContactSupport();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.support_agent, size: 20),
                  label: const Text('Contact Support'),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            _buildConnectionStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
color: Colors.green, 
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Backend Connected',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _retryOperation(String operation) {
    if (_homeBloc != null && !_homeBloc!.isClosed) {
      switch (operation) {
        case 'load_home_data':
          _homeBloc!.add(const home_events.LoadHomeDataEvent(forceRefresh: true));
          break;
        case 'load_user_stats':
          _homeBloc!.add(const home_events.LoadUserStatsEvent(forceRefresh: true));
          break;
        default:
          _homeBloc!.add(const home_events.LoadHomeDataEvent(forceRefresh: true));
      }
      
      NavigationService.showInfoSnackBar('Retrying...');
    }
  }

  void _tryOfflineMode() {
    if (_homeBloc != null && !_homeBloc!.isClosed) {
      NavigationService.showInfoSnackBar('Loading offline data...');
_loadInitialData(); 
    }
  }

  void _showContactSupport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Contact Support',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'We\'re here to help! Reach out if this issue persists.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      NavigationService.showInfoSnackBar('Opening email...');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                    ),
                    icon: const Icon(Icons.email),
                    label: const Text('Email'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      NavigationService.showInfoSnackBar('Opening help center...');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.help),
                    label: const Text('Help'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(HomeDashboardState state) {
    final homeData = state.homeData;
    final isNewUser = homeData?.isNewUser ?? true;

    print('🔍 DEBUG: Building dashboard content');
    print('🔍 DEBUG: isNewUser: $isNewUser');
    print('🔍 DEBUG: emotionEntries.length: ${_emotionEntries.length}');
    print('🔍 DEBUG: todaysEmotions.length: ${_todaysEmotions.length}');
    print('🔍 DEBUG: currentMood: $currentMood ($currentMoodLabel)');

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          DashboardHeader(
            isNewUser: isNewUser,
            isBackendConnected: true,
            currentMood: currentMood,
            currentMoodLabel: currentMoodLabel,
            emotionEntries: _emotionEntries,
            homeData: state.homeData,
            userStats: state.userStats,
            onMoodTapped: _onMoodTapped,
            breathingController: _breathingController,
            moodUpdateController: null,
            isMoodUpdating: false,
            isOnboardingCompleted: state.homeData != null ? !state.homeData!.isFirstTimeLogin : false,
          ),
          EmotionCalendarWidget(
            emotionEntries: _emotionEntries,
            onDateSelected: _onCalendarDateSelected,
            selectedDate: null,
            isLoading: false,
          ),
          const SizedBox(height: 24),
          if (isNewUser) _buildNewUserContent() else _buildRegularContent(),
        ],
      ),
    );
  }

  Widget _buildNewUserContent() {
    final dashboardState = widget.homeState as HomeDashboardState;
    final weeklyInsights = dashboardState.weeklyInsights;
    return Column(
      children: [
        const SizedBox(height: 32),
        EmotionAnalyticsCard(
          weeklyMoodData: weeklyInsights != null && weeklyInsights.toJson().containsKey('weeklyData')
              ? (weeklyInsights.toJson()['weeklyData'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? []
              : [],
          analyticsData: weeklyInsights?.toJson(),
          isNewUser: _isUserNew,
          dominantMood: weeklyInsights?.mostCommonMood ?? 'calm',
        ),
        const SizedBox(height: 32),
        CommunityFeedWidget(
          onViewAllTapped: () => NavigationService.pushNamed(AppRouter.friends),
          isNewUser: _isUserNew,
        ),
      ],
    );
  }

  Widget _buildRegularContent() {
    final dashboardState = widget.homeState as HomeDashboardState;
    final weeklyInsights = dashboardState.weeklyInsights;
    
    print('🔍 DEBUG: Building regular content with ${_todaysEmotions.length} today\'s emotions');
    
    return Column(
      children: [
        const SizedBox(height: 32),
        TodaysJourneyWidget(
          todaysEmotions: _todaysEmotions,
          onEmotionTap: _onEmotionTap,
        ),
        const SizedBox(height: 32),
        EmotionAnalyticsCard(
          weeklyMoodData: weeklyInsights != null && weeklyInsights.toJson().containsKey('weeklyData')
              ? (weeklyInsights.toJson()['weeklyData'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? []
              : [],
          analyticsData: weeklyInsights?.toJson(),
          isNewUser: _isUserNew,
          dominantMood: weeklyInsights?.mostCommonMood ?? 'calm',
        ),
        const SizedBox(height: 32),
        CommunityFeedWidget(
          onViewAllTapped: () => NavigationService.pushNamed(AppRouter.friends),
          isNewUser: _isUserNew,
        ),
      ],
    );
  }

  void _onCalendarDateSelected(DateTime date) {
    print('Selected date: $date');
    
    final emotionsForDate = _emotionEntries.where((emotion) {
      final emotionDate = DateTime(
        emotion.createdAt.year,
        emotion.createdAt.month,
        emotion.createdAt.day,
      );
      final selectedDate = DateTime(date.year, date.month, date.day);
      return emotionDate.isAtSameMomentAs(selectedDate);
    }).toList();

    if (emotionsForDate.isNotEmpty) {
      _showDateEmotionsModal(date, emotionsForDate);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No emotions logged on ${DateFormat('MMM dd, yyyy').format(date)}'),
          backgroundColor: const Color(0xFF8B5CF6),
        ),
      );
    }
  }

  void _onEmotionTap(EmotionEntryModel emotion) {
    print('Tapped emotion: ${emotion.emotion}');
    _showEmotionDetailModal(emotion);
  }

  void _showDateEmotionsModal(DateTime date, List<EmotionEntryModel> emotions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF8B5CF6)),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('EEEE, MMM dd, yyyy').format(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: emotions.length,
                itemBuilder: (context, index) {
                  final emotion = emotions[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: emotion.moodColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: emotion.moodColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          emotion.emotionEmoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                emotion.emotion,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('HH:mm').format(emotion.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                              if (emotion.note.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  emotion.note,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmotionDetailModal(EmotionEntryModel emotion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    emotion.emotionEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emotion.emotion,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy HH:mm').format(emotion.createdAt),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Intensity', emotion.intensityLabel),
                    if (emotion.note.isNotEmpty)
                      _buildDetailRow('Note', emotion.note),
                    if (emotion.hasLocation && emotion.latitude != null && emotion.longitude != null)
                      _buildDetailRow('Location', '${emotion.latitude!.toStringAsFixed(4)}, ${emotion.longitude!.toStringAsFixed(4)}'),
                    if (emotion.tags.isNotEmpty)
                      _buildDetailRow('Tags', emotion.tags.join(', ')),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF8B5CF6),
                              side: const BorderSide(color: Color(0xFF8B5CF6)),
                            ),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B6B),
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadInboxNotifications() async {
    try {
      final dio = Dio();
      final dioClient = GetIt.instance<DioClient>();
      final token = dioClient.getAuthToken();
      if (token == null) {
        print('No auth token found!');
        return;
      }
      final response = await dio.get(
        'http:////localhost:3000/api/messages/inbox',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print('Inbox response: ${response.data}');
      final messages = response.data['data']['messages'] as List;
      setState(() {
        _notifications = messages.map((msg) => {
          'id': msg['id'],
          'senderName': msg['senderName'],
          'senderAvatar': msg['senderAvatar'],
          'content': msg['content'],
          'senderId': msg['senderId'],
          'sentAt': msg['sentAt'],
          'isRead': false,
          'type': 'message',
        }).toList();
        _notificationCount = _notifications.length;
        _hasNotifications = _notifications.isNotEmpty;
      });
    } catch (e) {
      print('Failed to load inbox notifications: $e');
    }
  }
}

class EnhancedBottomNavigationCustom extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final VoidCallback? onMoodTapped;
  final MoodType currentMood;

  const EnhancedBottomNavigationCustom({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.onMoodTapped,
    this.currentMood = MoodType.good,
  });

  @override
  State<EnhancedBottomNavigationCustom> createState() =>
      _EnhancedBottomNavigationCustomState();
}

class _EnhancedBottomNavigationCustomState
    extends State<EnhancedBottomNavigationCustom>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 75,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildNavItem(
                      index: 0,
                      icon: Icons.public_rounded,
                      activeIcon: Icons.public_rounded,
                      label: 'Atlas',
                      isActive: widget.selectedIndex == 0,
                    ),
                  ),

                  Expanded(
                    child: _buildNavItem(
                      index: 1,
                      icon: Icons.people_outline_rounded,
                      activeIcon: Icons.people_rounded,
                      label: 'Friends',
                      isActive: widget.selectedIndex == 1,
                    ),
                  ),

                  const SizedBox(width: 70),

                  Expanded(
                    child: _buildNavItem(
                      index: 2,
                      icon: Icons.insights_outlined,
                      activeIcon: Icons.insights_rounded,
                      label: 'Insights',
                      isActive: widget.selectedIndex == 2,
                    ),
                  ),

                  Expanded(
                    child: _buildNavItem(
                      index: 3,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      isActive: widget.selectedIndex == 3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 5,
            left: MediaQuery.of(context).size.width / 2 - 35,
            child: _buildFloatingMoodButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => widget.onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isActive
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? const Color(0xFF8B5CF6).withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[400],
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[500],
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingMoodButton() {
    return GestureDetector(
      onTap: widget.onMoodTapped,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    MoodUtils.getMoodColor(widget.currentMood).withValues(alpha: 0.8),
                    MoodUtils.getMoodColor(widget.currentMood).withValues(alpha: 0.6),
                    const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: MoodUtils.getMoodColor(widget.currentMood).withValues(alpha: _glowAnimation.value),
                    blurRadius: 25,
                    spreadRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: CustomMoodFace(
                    mood: widget.currentMood,
                    size: 45,
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    faceColor: Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

final dioClient = GetIt.instance<DioClient>();
final token = dioClient.getAuthToken(); 