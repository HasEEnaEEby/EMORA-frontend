import 'package:emora_mobile_app/features/home/data/model/emotion_entry_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'custom_mood_face.dart';
import 'package:emora_mobile_app/features/home/data/model/home_data_model.dart';
import 'package:emora_mobile_app/features/home/data/model/user_stats_model.dart';

class DashboardHeader extends StatefulWidget {
  final bool isNewUser;
  final bool isBackendConnected;
  final MoodType currentMood;
  final String currentMoodLabel;
  final List<EmotionEntryModel> emotionEntries;
  final HomeDataModel? homeData;
  final UserStatsModel? userStats;
  final VoidCallback onMoodTapped;
  final AnimationController breathingController;
  final AnimationController? moodUpdateController;
  final bool isMoodUpdating;
  final bool isOnboardingCompleted;

  const DashboardHeader({
    super.key,
    required this.isNewUser,
    required this.isBackendConnected,
    required this.currentMood,
    required this.currentMoodLabel,
    required this.emotionEntries,
    required this.homeData,
    required this.userStats,
    required this.onMoodTapped,
    required this.breathingController,
    this.moodUpdateController,
    this.isMoodUpdating = false,
    this.isOnboardingCompleted = false,
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late AnimationController _levelUpController;
  late AnimationController _streakController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _levelUpController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _streakController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _levelUpController.dispose();
    _streakController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

bool get _isReallyNewUser {
  // ✅ FIX: Use the actual backend data from home-data API
  final homeData = widget.homeData;
  if (homeData == null) return true;
  
  // Get total emotions from the dashboard data (from backend API response)
  final dashboardData = homeData.dashboardData['data']?['dashboard'];
  final totalEmotions = dashboardData?['totalEmotions'] ?? 0;
  
  print('🔍 DEBUG: totalEmotions from backend: $totalEmotions');
  print('🔍 DEBUG: isUserNew: ${totalEmotions == 0}');
  
  return totalEmotions == 0;
}
  String get _userName {
    final homeData = widget.homeData;
    if (homeData == null) return 'there';
    
    // Since parsing is working correctly, just return the username directly
    if (homeData.username.isNotEmpty && homeData.username != 'Unknown') {
      return homeData.username;
    }
    
    return 'there';
  }

  // Helper method to get today's date formatted
  String get _todaysDate {
    return DateFormat('EEEE, MMM dd').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: _isReallyNewUser
            ? _buildWelcomeNewUserHeader()
            : _buildExistingUserHeader(),
      ),
    );
  }

  Widget _buildWelcomeNewUserHeader() {
    return AnimatedBuilder(
      animation: widget.breathingController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (widget.breathingController.value * 0.02),
          child: Container(
            key: const ValueKey('welcome_header'),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  const Color(0xFF6366F1).withValues(alpha: 0.1),
                  const Color(0xFF4F46E5).withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section with Avatar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated Welcome Avatar
                    AnimatedBuilder(
                      animation: _sparkleController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF8B5CF6),
                                const Color(0xFF6366F1),
                                const Color(0xFF4F46E5),
                              ],
                              stops: [0.0, 0.5, 1.0],
                              transform: GradientRotation(_sparkleController.value * 2 * 3.14159),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.waving_hand,
                            color: Colors.white,
                            size: 32,
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Personal Welcome Message - FIXED LAYOUT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome text without truncation
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1), Color(0xFFEC4899)],
                            ).createShader(bounds),
                            child: Text(
                              'Welcome $_userName!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _todaysDate,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // New User Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Text(
                        'New',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExistingUserHeader() {
    final streak = widget.userStats?.streakDays ?? 0;
    final totalLogs = widget.userStats?.moodCheckins ?? 0;
    final level = _calculateUserLevel(totalLogs);
    final progressToNextLevel = _calculateLevelProgress(totalLogs);

    return AnimatedBuilder(
      animation: widget.breathingController,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: widget.moodUpdateController ?? const AlwaysStoppedAnimation(0.0),
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (widget.breathingController.value * 0.02) + 
                     ((widget.moodUpdateController?.value ?? 0.0) * 0.05),
              child: Container(
                key: const ValueKey('existing_header'),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MoodUtils.getMoodColor(widget.currentMood).withValues(alpha: 0.1),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                      const Color(0xFF4F46E5).withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.isBackendConnected 
                        ? const Color(0xFF10B981).withValues(alpha: 0.4)
                        : const Color(0xFFFF9800).withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: MoodUtils.getMoodColor(widget.currentMood).withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Row: User Stats & Connection
                    Row(
                      children: [
                        // Level Badge
                        _buildLevelBadge(level),
                        
                        const SizedBox(width: 12),
                        
                        // Streak Fire
                        if (streak > 0) _buildStreakIndicator(streak),
                        
                        const Spacer(),
                        
                        // Connection Status
                        _buildConnectionIndicator(),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Main Mood Section
                    Row(
                      children: [
                        // Animated Mood Face
                        _buildAnimatedMoodFace(),
                        
                        const SizedBox(width: 20),
                        
                        // Mood Info
                        Expanded(child: _buildMoodInfo()),
                        
                        // Update Button
                        _buildMoodUpdateButton(),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Progress Bar
                    _buildLevelProgressBar(progressToNextLevel, level),
                    
                    const SizedBox(height: 16),
                    
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLevelBadge(int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD700),
            Color(0xFFFFA500),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            'Lv.$level',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakIndicator(int streak) {
    return AnimatedBuilder(
      animation: _streakController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_streakController.value * 0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF6B6B),
                  Color(0xFFFF8E53),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$streak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectionIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isBackendConnected 
            ? const Color(0xFF10B981).withValues(alpha: 0.2)
            : const Color(0xFFFF9800).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isBackendConnected 
              ? const Color(0xFF10B981).withValues(alpha: 0.4)
              : const Color(0xFFFF9800).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isBackendConnected 
                  ? const Color(0xFF10B981)
                  : const Color(0xFFFF9800),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            widget.isBackendConnected ? 'Live' : 'Offline',
            style: TextStyle(
              color: widget.isBackendConnected 
                  ? const Color(0xFF10B981)
                  : const Color(0xFFFF9800),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMoodFace() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: MoodUtils.getMoodColor(widget.currentMood).withValues(alpha: 0.4),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: MoodUtils.getMoodColor(widget.currentMood).withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        child: CustomMoodFace(
          mood: widget.currentMood,
          size: 80,
          backgroundColor: widget.isBackendConnected 
              ? MoodUtils.getMoodColor(widget.currentMood) 
              : Colors.grey[600]!,
        ),
      ),
    );
  }

  Widget _buildMoodInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                'Current Mood',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('MMM dd').format(DateTime.now()),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            widget.currentMoodLabel,
            key: ValueKey(widget.currentMoodLabel),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.isBackendConnected 
              ? 'Tap to update your feelings' 
              : 'Offline - data saved locally',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodUpdateButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onMoodTapped();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: widget.isMoodUpdating
              ? const LinearGradient(
                  colors: [
                    Color(0xFF10B981),
                    Color(0xFF059669),
                  ],
                )
              : const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: widget.isMoodUpdating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 24,
                ),
        ),
      ),
    );
  }

  Widget _buildLevelProgressBar(double progress, int level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Level $level Progress',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Color(0xFF8B5CF6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  int _calculateUserLevel(int totalLogs) {
    if (totalLogs < 10) return 1;
    if (totalLogs < 25) return 2;
    if (totalLogs < 50) return 3;
    if (totalLogs < 100) return 4;
    if (totalLogs < 200) return 5;
    return 6 + (totalLogs - 200) ~/ 100;
  }

  double _calculateLevelProgress(int totalLogs) {
    final level = _calculateUserLevel(totalLogs);
    int logsForCurrentLevel;
    int logsForNextLevel;

    if (level == 1) {
      logsForCurrentLevel = 0;
      logsForNextLevel = 10;
    } else if (level == 2) {
      logsForCurrentLevel = 10;
      logsForNextLevel = 25;
    } else if (level == 3) {
      logsForCurrentLevel = 25;
      logsForNextLevel = 50;
    } else if (level == 4) {
      logsForCurrentLevel = 50;
      logsForNextLevel = 100;
    } else if (level == 5) {
      logsForCurrentLevel = 100;
      logsForNextLevel = 200;
    } else {
      logsForCurrentLevel = 200 + ((level - 6) * 100);
      logsForNextLevel = logsForCurrentLevel + 100;
    }

    if (totalLogs >= logsForNextLevel) return 1.0;
    
    return (totalLogs - logsForCurrentLevel) / (logsForNextLevel - logsForCurrentLevel);
  }
}

// Utility class for mood operations
class MoodUtils {
  static List<MoodType> getAllMoods() {
    return [MoodType.awful, MoodType.down, MoodType.okay, MoodType.good, MoodType.amazing];
  }

  static String getMoodLabel(MoodType mood) {
    switch (mood) {
      case MoodType.awful:
        return 'Awful';
      case MoodType.down:
        return 'Down';
      case MoodType.okay:
        return 'Okay';
      case MoodType.good:
        return 'Good';
      case MoodType.amazing:
        return 'Amazing';
    }
  }

  static Color getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.awful:
        return const Color(0xFFFF4444);
      case MoodType.down:
        return const Color(0xFFFF9500);
      case MoodType.okay:
        return const Color(0xFFFFD700);
      case MoodType.good:
        return const Color(0xFF4CAF50);
      case MoodType.amazing:
        return const Color(0xFF00E676);
    }
  }
}