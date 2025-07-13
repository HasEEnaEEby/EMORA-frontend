// lib/features/home/presentation/widget/dialogs/fixed_achievements_dialog.dart
import 'package:emora_mobile_app/core/utils/dialog_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Fixed achievements display dialog with robust data handling
///
/// Features:
/// - Safe handling of Map<String, dynamic> achievement data
/// - Shows all achievements with progress
/// - Category filtering
/// - Achievement detail view
/// - Share achievements
/// - Empty state for new users
/// - Mock data fallback for development
class FixedAchievementsDialog {
  /// Shows all achievements in a bottom sheet with safe data handling
  static void showAll(BuildContext context, List<dynamic> achievements) {
    // Convert unsafe dynamic data to safe structured data
    final safeAchievements = _convertToSafeAchievements(achievements);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHandleBar(),
            _buildHeader(context, safeAchievements),
            _buildCategoryFilters(context, safeAchievements),
            const SizedBox(height: 16),
            Expanded(
              child: safeAchievements.isEmpty
                  ? _buildEmptyState(context)
                  : _buildAchievementsList(context, safeAchievements),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows detailed view of a specific achievement with safe data access
  static void showDetail(BuildContext context, dynamic achievement) {
    final safeAchievement = _convertToSafeAchievement(achievement);
    final Color achievementColor = DialogUtils.getAchievementColor(
      safeAchievement.category,
    );

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: _buildAchievementDetailContent(
          safeAchievement,
          achievementColor,
        ),
        actions: _buildAchievementDetailActions(context, safeAchievement),
      ),
    );
  }

  /// Safely converts dynamic achievement data to structured format
  static List<SafeAchievement> _convertToSafeAchievements(
    List<dynamic> achievements,
  ) {
    if (achievements.isEmpty) {
      // Return mock achievements for development
      return _createMockAchievements();
    }

    return achievements
        .map((achievement) => _convertToSafeAchievement(achievement))
        .where((achievement) => achievement.isValid)
        .toList();
  }

  /// Safely converts a single achievement to structured format
  static SafeAchievement _convertToSafeAchievement(dynamic achievement) {
    if (achievement is Map<String, dynamic>) {
      return SafeAchievement.fromMap(achievement);
    } else if (achievement is SafeAchievement) {
      return achievement;
    } else {
      return SafeAchievement.createDefault();
    }
  }

  /// Creates mock achievements for development/testing
  static List<SafeAchievement> _createMockAchievements() {
    return [
      SafeAchievement(
        id: 'first_emotion',
        name: 'First Steps',
        description: 'Log your first emotion on EMORA',
        category: 'milestone',
        iconName: 'star',
        points: 10,
        isEarned: true,
        progress: 1,
        target: 1,
        earnedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      SafeAchievement(
        id: 'week_streak',
        name: 'Weekly Warrior',
        description: 'Log emotions for 7 consecutive days',
        category: 'streak',
        iconName: 'flame',
        points: 50,
        isEarned: false,
        progress: 3,
        target: 7,
        earnedDate: null,
      ),
      SafeAchievement(
        id: 'social_butterfly',
        name: 'Social Butterfly',
        description: 'Connect with 5 friends on EMORA',
        category: 'social',
        iconName: 'heart',
        points: 25,
        isEarned: false,
        progress: 0,
        target: 5,
        earnedDate: null,
      ),
      SafeAchievement(
        id: 'mood_master',
        name: 'Mood Master',
        description: 'Log 50 different emotions',
        category: 'discovery',
        iconName: 'target',
        points: 100,
        isEarned: false,
        progress: 15,
        target: 50,
        earnedDate: null,
      ),
      SafeAchievement(
        id: 'mindful_month',
        name: 'Mindful Month',
        description: 'Complete 30 days of emotion tracking',
        category: 'wellness',
        iconName: 'calendar',
        points: 200,
        isEarned: false,
        progress: 8,
        target: 30,
        earnedDate: null,
      ),
      SafeAchievement(
        id: 'insight_seeker',
        name: 'Insight Seeker',
        description: 'View your emotion insights 10 times',
        category: 'insights',
        iconName: 'brain',
        points: 30,
        isEarned: true,
        progress: 10,
        target: 10,
        earnedDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  /// Builds the handle bar
  static Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Builds the header with title and stats
  static Widget _buildHeader(
    BuildContext context,
    List<SafeAchievement> achievements,
  ) {
    final earnedCount = achievements.where((a) => a.isEarned).length;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(CupertinoIcons.rosette, color: Color(0xFF8B5CF6), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Achievements',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$earnedCount of ${achievements.length} unlocked',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: const Icon(CupertinoIcons.xmark, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Builds category filter chips
  static Widget _buildCategoryFilters(
    BuildContext context,
    List<SafeAchievement> achievements,
  ) {
    final categories = achievements.map((a) => a.category).toSet().toList();

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories.map((category) {
          final count = achievements
              .where((a) => a.category == category)
              .length;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
              onPressed: () {
                HapticFeedback.selectionClick();
                _filterAchievementsByCategory(context, category, achievements);
              },
              child: Text(
                '${DialogUtils.capitalizeFirst(category)} ($count)',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Filters achievements by category
  static void _filterAchievementsByCategory(
    BuildContext context,
    String category,
    List<SafeAchievement> achievements,
  ) {
    final filteredAchievements = achievements
        .where((a) => a.category == category)
        .toList();

    DialogUtils.showInfoSnackBar(
      context,
      'Showing ${filteredAchievements.length} achievements in $category category',
    );
  }

  /// Builds empty state for no achievements
  static Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.rosette, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'No Achievements Yet',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging emotions to unlock achievements!',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton(
            color: const Color(0xFF8B5CF6),
            child: const Text('View Sample Achievements'),
            onPressed: () {
              Navigator.pop(context);
              showAll(context, []); // This will show mock achievements
            },
          ),
        ],
      ),
    );
  }

  /// Builds the achievements list
  static Widget _buildAchievementsList(
    BuildContext context,
    List<SafeAchievement> achievements,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementListItem(context, achievement);
      },
    );
  }

  /// Builds individual achievement list item
  static Widget _buildAchievementListItem(
    BuildContext context,
    SafeAchievement achievement,
  ) {
    final Color achievementColor = DialogUtils.getAchievementColor(
      achievement.category,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => showDetail(context, achievement),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: achievement.isEarned
                ? const Color(0xFF0A0A0F).withValues(alpha: 0.5)
                : Colors.grey[900]!.withValues(alpha: 0.3),
            border: Border.all(
              color: achievement.isEarned
                  ? achievementColor.withValues(alpha: 0.3)
                  : Colors.grey[600]!.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              _buildAchievementIcon(achievement, achievementColor),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAchievementInfo(achievement, achievementColor),
              ),
              _buildAchievementStatus(achievement, achievementColor),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds achievement icon
  static Widget _buildAchievementIcon(
    SafeAchievement achievement,
    Color achievementColor,
  ) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: achievement.isEarned
            ? LinearGradient(
                colors: [
                  achievementColor,
                  achievementColor.withValues(alpha: 0.7),
                ],
              )
            : null,
        color: achievement.isEarned ? null : Colors.grey[800],
        boxShadow: achievement.isEarned
            ? [
                BoxShadow(
                  color: achievementColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Icon(
        DialogUtils.getAchievementIcon(achievement.iconName),
        color: achievement.isEarned ? Colors.white : Colors.grey[600],
        size: 24,
      ),
    );
  }

  /// Builds achievement information section
  static Widget _buildAchievementInfo(
    SafeAchievement achievement,
    Color achievementColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          achievement.name,
          style: TextStyle(
            color: achievement.isEarned ? Colors.white : Colors.grey[500],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          achievement.description,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (achievement.target > 1) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: achievement.completionPercentage,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(achievementColor),
            minHeight: 4,
          ),
          const SizedBox(height: 4),
          Text(
            '${achievement.progress}/${achievement.target}',
            style: TextStyle(color: Colors.grey[500], fontSize: 10),
          ),
        ],
        if (achievement.isEarned && achievement.earnedDate != null) ...[
          const SizedBox(height: 4),
          Text(
            'Earned ${DialogUtils.formatDate(achievement.earnedDate!)}',
            style: TextStyle(
              color: achievementColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  /// Builds achievement status section
  static Widget _buildAchievementStatus(
    SafeAchievement achievement,
    Color achievementColor,
  ) {
    return Column(
      children: [
        if (achievement.isEarned)
          Icon(
            CupertinoIcons.check_mark_circled_solid,
            color: achievementColor,
            size: 20,
          )
        else
          Icon(CupertinoIcons.lock, color: Colors.grey[600], size: 20),
        if (achievement.points > 0) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: achievementColor.withValues(alpha: 0.2),
            ),
            child: Text(
              '${achievement.points}pts',
              style: TextStyle(
                color: achievementColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Builds achievement detail content
  static Widget _buildAchievementDetailContent(
    SafeAchievement achievement,
    Color achievementColor,
  ) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: achievement.isEarned
                  ? LinearGradient(
                      colors: [
                        achievementColor,
                        achievementColor.withValues(alpha: 0.7),
                      ],
                    )
                  : null,
              color: achievement.isEarned ? null : Colors.grey[800],
              boxShadow: achievement.isEarned
                  ? [
                      BoxShadow(
                        color: achievementColor.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              DialogUtils.getAchievementIcon(achievement.iconName),
              color: achievement.isEarned ? Colors.white : Colors.grey[600],
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            achievement.name,
            style: TextStyle(
              color: achievement.isEarned
                  ? CupertinoColors.label
                  : CupertinoColors.secondaryLabel,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: achievementColor.withValues(alpha: 0.2),
            ),
            child: Text(
              DialogUtils.capitalizeFirst(achievement.category),
              style: TextStyle(
                color: achievementColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            achievement.description,
            style: const TextStyle(
              color: CupertinoColors.secondaryLabel,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (achievement.target > 1) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: CupertinoColors.systemGrey6,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          color: CupertinoColors.secondaryLabel,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${achievement.progress}/${achievement.target}',
                        style: TextStyle(
                          color: achievementColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: achievement.completionPercentage,
                    backgroundColor: CupertinoColors.systemGrey4,
                    valueColor: AlwaysStoppedAnimation<Color>(achievementColor),
                    minHeight: 6,
                  ),
                ],
              ),
            ),
          ],
          if (achievement.points > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: achievementColor.withValues(alpha: 0.2),
              ),
              child: Text(
                '${achievement.points} Points',
                style: TextStyle(
                  color: achievementColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (achievement.isEarned && achievement.earnedDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: achievementColor.withValues(alpha: 0.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.calendar,
                    size: 14,
                    color: achievementColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Earned ${DialogUtils.formatDate(achievement.earnedDate!)}',
                    style: TextStyle(
                      color: achievementColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds achievement detail action buttons
  static List<Widget> _buildAchievementDetailActions(
    BuildContext context,
    SafeAchievement achievement,
  ) {
    final actions = <Widget>[
      CupertinoDialogAction(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ];

    if (achievement.isEarned) {
      actions.insert(
        0,
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context);
            _shareAchievement(context, achievement);
          },
          child: const Text('Share'),
        ),
      );
    }

    return actions;
  }

  /// Shares achievement via native share sheet
  static void _shareAchievement(
    BuildContext context,
    SafeAchievement achievement,
  ) {
    final text =
        'Just unlocked "${achievement.name}" on EMORA! 🏆\n\n${achievement.description}';
    Share.share(text);
    HapticFeedback.lightImpact();
  }
}

/// Safe achievement model with guaranteed property access
class SafeAchievement {
  final String id;
  final String name;
  final String description;
  final String category;
  final String iconName;
  final int points;
  final bool isEarned;
  final int progress;
  final int target;
  final DateTime? earnedDate;

  const SafeAchievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconName,
    required this.points,
    required this.isEarned,
    required this.progress,
    required this.target,
    this.earnedDate,
  });

  /// Creates from Map with safe fallbacks
  factory SafeAchievement.fromMap(Map<String, dynamic> map) {
    try {
      return SafeAchievement(
        id:
            map['id']?.toString() ??
            'unknown_${DateTime.now().millisecondsSinceEpoch}',
        name: map['name']?.toString() ?? 'Unknown Achievement',
        description:
            map['description']?.toString() ?? 'No description available',
        category: map['category']?.toString() ?? 'general',
        iconName:
            map['iconName']?.toString() ?? map['icon']?.toString() ?? 'star',
        points: _safeParseInt(map['points']) ?? 0,
        isEarned:
            _safeParseBool(map['isEarned']) ??
            _safeParseBool(map['earned']) ??
            false,
        progress: _safeParseInt(map['progress']) ?? 0,
        target: _safeParseInt(map['target']) ?? 1,
        earnedDate: _safeParseDate(map['earnedDate'] ?? map['dateEarned']),
      );
    } catch (e) {
      return SafeAchievement.createDefault();
    }
  }

  /// Creates a default/fallback achievement
  factory SafeAchievement.createDefault() {
    return SafeAchievement(
      id: 'default_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Mystery Achievement',
      description: 'Achievement data unavailable',
      category: 'general',
      iconName: 'star',
      points: 0,
      isEarned: false,
      progress: 0,
      target: 1,
      earnedDate: null,
    );
  }

  /// Checks if the achievement has valid data
  bool get isValid => name.isNotEmpty && id.isNotEmpty;

  /// Gets completion percentage
  double get completionPercentage {
    if (target <= 0) return 0.0;
    return (progress / target).clamp(0.0, 1.0);
  }

  // Safe parsing helper methods
  static int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _safeParseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    if (value is int) return value != 0;
    return null;
  }

  static DateTime? _safeParseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}
