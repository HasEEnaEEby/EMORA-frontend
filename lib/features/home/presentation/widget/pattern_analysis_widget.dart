import 'package:emora_mobile_app/features/home/data/model/insights_models.dart';
import 'package:flutter/material.dart';

class PatternAnalysisWidget extends StatelessWidget {
  final List<PatternInsight> patterns;

  const PatternAnalysisWidget({super.key, required this.patterns});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              const Color(0xFF6366F1).withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pattern Analysis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAllPatterns(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                    ),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(patterns
                .take(4)
                .map((pattern) => _buildPatternItem(pattern, context))),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternItem(PatternInsight pattern, BuildContext context) {
    return GestureDetector(
      onTap: () => _showPatternDetail(pattern, context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.3),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              ),
              child: Text(pattern.emoji, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pattern.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: _getStrengthColor(
                            pattern.strength,
                          ).withValues(alpha: 0.2),
                        ),
                        child: Text(
                          '${(pattern.strength * 100).toInt()}%',
                          style: TextStyle(
                            color: _getStrengthColor(pattern.strength),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pattern.description,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Color _getStrengthColor(double strength) {
    if (strength >= 0.8) return const Color(0xFF10B981);
    if (strength >= 0.6) return const Color(0xFF6366F1);
    return const Color(0xFFFF6B35);
  }

  void _showAllPatterns(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _AllPatternsView(patterns: patterns),
      ),
    );
  }

  void _showPatternDetail(PatternInsight pattern, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        margin: const EdgeInsets.only(top: 50),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(pattern.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pattern.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        pattern.description,
                        style: TextStyle(color: Colors.grey[300], fontSize: 14),
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
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _getStrengthColor(
                  pattern.strength,
                ).withValues(alpha: 0.1),
                border: Border.all(
                  color: _getStrengthColor(
                    pattern.strength,
                  ).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: _getStrengthColor(pattern.strength),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pattern Strength: ${(pattern.strength * 100).toInt()}%',
                    style: TextStyle(
                      color: _getStrengthColor(pattern.strength),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pattern.details,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recommendations',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getPatternRecommendations(pattern),
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPatternRecommendations(PatternInsight pattern) {
    switch (pattern.category) {
      case 'time':
        return 'Schedule important activities during your peak hours. Consider adjusting your routine to maximize these high-energy periods and plan rest during low-energy times.';
      case 'habit':
        return 'This habit appears to positively impact your mood. Consider maintaining this routine and potentially exploring similar habits that might have comparable benefits.';
      case 'activity':
        return 'Regular exercise is clearly benefiting your emotional wellbeing. Try to maintain consistency and consider tracking which types of exercise give you the biggest mood boost.';
      case 'health':
        return 'Sleep quality significantly impacts your mood. Focus on maintaining good sleep hygiene: consistent bedtime, cool dark room, and avoiding screens before bed.';
      case 'environment':
        return 'Weather affects your mood more than average. Consider light therapy during dark periods, plan outdoor activities on sunny days, and have indoor mood-boosting activities ready.';
      case 'social':
        return 'Social connections are a key mood booster for you. Prioritize regular social activities and maintain your relationships, especially during stressful periods.';
      default:
        return 'Use this pattern to make informed decisions about your daily routine and activities.';
    }
  }
}

class _AllPatternsView extends StatelessWidget {
  final List<PatternInsight> patterns;

  const _AllPatternsView({required this.patterns});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: const Text(
          'All Patterns',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF8B5CF6)),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: patterns.length,
        itemBuilder: (context, index) {
          final pattern = patterns[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(pattern.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pattern.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _getStrengthColor(
                          pattern.strength,
                        ).withValues(alpha: 0.2),
                      ),
                      child: Text(
                        '${(pattern.strength * 100).toInt()}%',
                        style: TextStyle(
                          color: _getStrengthColor(pattern.strength),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  pattern.description,
                  style: TextStyle(color: Colors.grey[300], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  pattern.details,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStrengthColor(double strength) {
    if (strength >= 0.8) return const Color(0xFF10B981);
    if (strength >= 0.6) return const Color(0xFF6366F1);
    return const Color(0xFFFF6B35);
  }
}
