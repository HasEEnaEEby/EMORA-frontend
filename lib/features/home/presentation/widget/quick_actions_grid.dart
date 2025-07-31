import 'package:flutter/material.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onVentTapped;
  final VoidCallback onJournalTapped;
  final VoidCallback onInsightsTapped;
  final VoidCallback onAtlasTapped;
final VoidCallback? onDashboardTapped; 

  const QuickActionsGrid({
    super.key,
    required this.onVentTapped,
    required this.onJournalTapped,
    required this.onInsightsTapped,
    required this.onAtlasTapped,
this.onDashboardTapped, 
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
childAspectRatio: 1.8, 
            children: [
              _buildQuickActionCard(
                icon: Icons.air_rounded,
                title: 'Vent It Out',
                subtitle: 'Express freely',
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFD8A5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: onVentTapped,
              ),
              _buildQuickActionCard(
                icon: Icons.book_rounded,
                title: 'Recovery Journal',
                subtitle: 'Reflect & heal',
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: onJournalTapped,
              ),
              _buildQuickActionCard(
                icon: Icons.insights_rounded,
                title: 'Mood Insights',
                subtitle: 'Track patterns',
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: onInsightsTapped,
              ),
              if (onDashboardTapped != null)
                _buildQuickActionCard(
                  icon: Icons.dashboard_rounded,
                  title: 'Full Dashboard',
                  subtitle: 'Complete view',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFFB74D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: onDashboardTapped!,
                ),
              _buildQuickActionCard(
                icon: Icons.public_rounded,
                title: 'Mood Atlas',
                subtitle: 'Explore globally',
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: onAtlasTapped,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
padding: const EdgeInsets.all(12), 
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient.colors
                .map((color) => color.withOpacity(0.1))
                .toList(),
            begin: gradient.begin,
            end: gradient.end,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: gradient.colors.first.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
mainAxisSize: MainAxisSize.min, 
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
size: 20, 
              ),
            ),
const SizedBox(height: 8), 
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
fontSize: 14, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
height: 1.2, 
                ),
maxLines: 2, 
overflow: TextOverflow.ellipsis, 
              ),
            ),
const SizedBox(height: 2), 
            Flexible(
              child: Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[400],
fontSize: 11, 
                  letterSpacing: 0.2,
height: 1.3, 
                ),
maxLines: 1, 
overflow: TextOverflow.ellipsis, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
