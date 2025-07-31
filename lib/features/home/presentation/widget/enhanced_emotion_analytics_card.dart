import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get_it/get_it.dart';
import 'package:emora_mobile_app/features/recommendations/service/recommendation_service.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';

class EnhancedEmotionAnalyticsCard extends StatefulWidget {
  final List<Map<String, dynamic>>? weeklyMoodData;
  final Map<String, dynamic>? analyticsData;
  final bool isNewUser;
  final String dominantMood;

  const EnhancedEmotionAnalyticsCard({
    super.key,
    this.weeklyMoodData,
    this.analyticsData,
    this.isNewUser = false,
    required this.dominantMood,
  });

  @override
  State<EnhancedEmotionAnalyticsCard> createState() => _EnhancedEmotionAnalyticsCardState();
}

class _EnhancedEmotionAnalyticsCardState extends State<EnhancedEmotionAnalyticsCard>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _chartController;
  late AnimationController _musicController;

  Map<String, dynamic>? _spotifyPlaylist;
  Map<String, dynamic>? _comprehensiveRecs;
  bool _isLoading = false;
  bool _isPlayingPreview = false;
  String? _currentTrackUrl;
  String? _currentTrackName;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupAudioPlayer();
  }

  void _initializeAnimations() {
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _musicController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _chartController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _musicController.forward();
    });
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlayingPreview = state == PlayerState.playing;
        });
      }
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlayingPreview = false;
          _currentTrackUrl = null;
          _currentTrackName = null;
        });
      }
    });
  }


  String _getCurrentTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  @override
  void dispose() {
    _chartController.dispose();
    _musicController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF2A2A3E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF8B5CF6)),
            SizedBox(height: 16),
            Text(
              'Loading your personalized recommendations...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (widget.isNewUser || (widget.weeklyMoodData?.isEmpty ?? true)) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildAnimatedChart(),
        const SizedBox(height: 24),
        _buildWeeklySummary(),
        const SizedBox(height: 20),
        _buildDynamicMusicSection(),
        const SizedBox(height: 16),
        _buildQuickRecommendations(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'This Week\'s Emotional Flow',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '7 days',
            style: TextStyle(
              color: Color(0xFF8B5CF6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedChart() {
    final moodData = widget.weeklyMoodData ?? [];
    
    return AnimatedBuilder(
      animation: _chartController,
      builder: (context, child) {
        return Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: moodData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              final intensity = (data['intensity'] as num?)?.toDouble() ?? 0.0;
              final color = data['color'] as Color? ?? const Color(0xFF8B5CF6);
              final day = data['day'] as String? ?? '';
              
              final animationDelay = index * 0.1;
              final animationValue = Curves.elasticOut.transform(
                ((_chartController.value - animationDelay).clamp(0.0, 1.0))
              );
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: double.infinity,
                        height: (intensity * 70 * animationValue).clamp(4.0, 70.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withValues(alpha: 0.5)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        day,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildWeeklySummary() {
    final moodData = widget.weeklyMoodData ?? [];
    if (moodData.isEmpty) return const SizedBox.shrink();
    
    final avgIntensity = moodData
        .map((d) => (d['intensity'] as num?)?.toDouble() ?? 0.0)
        .reduce((a, b) => a + b) / moodData.length;
    
    final highestDay = moodData.reduce((a, b) => 
        ((a['intensity'] as num?)?.toDouble() ?? 0.0) > 
        ((b['intensity'] as num?)?.toDouble() ?? 0.0) ? a : b);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            const Color(0xFF6366F1).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _buildSummaryItem(
            icon: Icons.trending_up,
            label: 'Average',
            value: '${(avgIntensity * 10).toStringAsFixed(1)}/10',
            color: _getColorForIntensity(avgIntensity),
          ),
          const SizedBox(width: 20),
          _buildSummaryItem(
            icon: Icons.star,
            label: 'Best Day',
            value: highestDay['day'] ?? '',
            color: const Color(0xFFFFD700),
          ),
          const SizedBox(width: 20),
          _buildSummaryItem(
            icon: Icons.psychology,
            label: 'Mood',
            value: widget.dominantMood,
            color: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicMusicSection() {
    return AnimatedBuilder(
      animation: _musicController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _musicController.value),
          child: Opacity(
            opacity: _musicController.value,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1DB954).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: _spotifyPlaylist != null 
                  ? _buildRealSpotifyPlaylist()
                  : _buildFallbackMusicSection(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRealSpotifyPlaylist() {
    final playlist = _spotifyPlaylist!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: playlist['imageUrl'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        playlist['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.queue_music, color: Colors.white, size: 26),
                      ),
                    )
                  : const Icon(Icons.queue_music, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Perfect match',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${((playlist['moodMatch'] ?? 0.8) * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    playlist['name'] ?? 'Unknown Playlist',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${playlist['trackCount'] ?? 0} tracks',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 14),
        
        Text(
          playlist['description'] ?? 'Curated playlist for your ${widget.dominantMood} mood',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        if (_isPlayingPreview && _currentTrackName != null) ...[
          const SizedBox(height: 12),
          _buildCurrentlyPlayingCard(),
        ],
        
        const SizedBox(height: 18),
        
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showPlaylistTracks(playlist),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1DB954),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text(
                  'View Tracks',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openInSpotify(playlist['spotifyUrl']),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text(
                  'Open Spotify',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentlyPlayingCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Now Playing: $_currentTrackName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: _stopPreview,
            icon: const Icon(
              Icons.stop,
              color: Colors.white,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackMusicSection() {
    final musicRec = _getMusicRecommendationForMood(widget.dominantMood);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.queue_music, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your mood playlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    musicRec['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    musicRec['subtitle']!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 14),
        Text(
          musicRec['description']!,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13,
            height: 1.3,
          ),
        ),
        
        const SizedBox(height: 18),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showSpotifySearchSuggestions(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1DB954),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            icon: const Icon(Icons.search, size: 18),
            label: const Text(
              'Find Similar Music',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickRecommendations() {
    if (_comprehensiveRecs == null) return const SizedBox.shrink();
    
    final activities = _comprehensiveRecs!['activities']?['primary'] ?? 
                      _comprehensiveRecs!['activities'] ?? [];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF8B5CF6),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Quick Recommendations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showAllRecommendations(),
                child: const Text(
                  'View All',
                  style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...activities.take(2).map((activity) => _buildActivityTile(activity)).toList(),
        ],
      ),
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getActivityIcon(activity['category']),
              color: const Color(0xFF8B5CF6),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  activity['duration'] ?? '',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[500],
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Your Emotional Analytics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Getting Started',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
              width: 2,
            ),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                const Color(0xFF6366F1).withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    color: Color(0xFF8B5CF6),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Start your emotional journey!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Log emotions to see your patterns and get personalized recommendations',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _navigateToEmotionLogging(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.favorite),
            label: const Text(
              'Log Your First Emotion',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(String? category) {
    switch (category) {
      case 'physical': return Icons.directions_run;
      case 'social': return Icons.people;
      case 'wellness': return Icons.spa;
      case 'outdoor': return Icons.nature;
      case 'reflection': return Icons.book;
      case 'self-care': return Icons.self_improvement;
      case 'entertainment': return Icons.movie;
      case 'creative': return Icons.palette;
      default: return Icons.star;
    }
  }

  Color _getColorForIntensity(double intensity) {
    if (intensity >= 0.8) return const Color(0xFF10B981);
    if (intensity >= 0.6) return const Color(0xFFFFD700);
    if (intensity >= 0.4) return const Color(0xFFFF8C00);
    return const Color(0xFFFF6B6B);
  }

  Map<String, String> _getMusicRecommendationForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'joy':
        return {
          'title': 'Feel Good Hits',
          'subtitle': 'Uplifting songs to match your joy! 🌟',
          'description': 'Perfect blend of upbeat pop, dance hits, and feel-good classics.',
        };
      case 'sad':
        return {
          'title': 'Comfort & Healing',
          'subtitle': 'Gentle melodies for support 💙',
          'description': 'Soothing acoustic tracks and emotional ballads for comfort.',
        };
      case 'calm':
        return {
          'title': 'Peaceful Vibes',
          'subtitle': 'Serene sounds for tranquil moments 😌',
          'description': 'Ambient, classical, and chill-out music for relaxation.',
        };
      case 'grateful':
      case 'gratitude':
        return {
          'title': 'Gratitude & Grace',
          'subtitle': 'Inspirational music for thankful hearts 🙏',
          'description': 'Uplifting spiritual music and inspirational tracks.',
        };
      case 'anxious':
      case 'stressed':
        return {
          'title': 'Calm & Centered',
          'subtitle': 'Soothing sounds for peace of mind 🧘‍♀️',
          'description': 'Meditation music and calming melodies for stress relief.',
        };
      default:
        return {
          'title': 'Your Mood Playlist',
          'subtitle': 'Music to match your current vibe 🎵',
          'description': 'Curated tracks that understand your emotional state.',
        };
    }
  }

  void _showPlaylistTracks(Map<String, dynamic> playlist) {
    _showSnackBar('Playlist tracks view coming soon!');
  }

  void _openInSpotify(String? spotifyUrl) {
    _showSnackBar('Opening Spotify...');
  }

  void _showSpotifySearchSuggestions() {
    _showSnackBar('Spotify search suggestions coming soon!');
  }

  void _showAllRecommendations() {
    _showSnackBar('All recommendations view coming soon!');
  }

  void _stopPreview() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlayingPreview = false;
      _currentTrackUrl = null;
      _currentTrackName = null;
    });
  }

  void _navigateToEmotionLogging() {
    _showSnackBar('Navigate to emotion logging...');
  }
} 