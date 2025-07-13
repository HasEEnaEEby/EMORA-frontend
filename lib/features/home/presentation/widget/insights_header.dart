// lib/features/insights/presentation/widgets/insights_header.dart
import 'package:flutter/material.dart';

class InsightsHeader extends StatefulWidget {
  final bool showDetailed;
  final VoidCallback onToggleDetailed;
  final VoidCallback onExport;

  const InsightsHeader({
    super.key,
    required this.showDetailed,
    required this.onToggleDetailed,
    required this.onExport,
  });

  @override
  State<InsightsHeader> createState() => _InsightsHeaderState();
}

class _InsightsHeaderState extends State<InsightsHeader>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _detailToggleController;
  late Animation<double> _glowAnimation;
  late Animation<double> _detailToggleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _detailToggleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _detailToggleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _detailToggleController, curve: Curves.easeOut),
    );

    if (widget.showDetailed) {
      _detailToggleController.forward();
    }
  }

  @override
  void didUpdateWidget(InsightsHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showDetailed != oldWidget.showDetailed) {
      if (widget.showDetailed) {
        _detailToggleController.forward();
      } else {
        _detailToggleController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _detailToggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              _buildBackButton(),
              const SizedBox(width: 16),
              _buildTitleSection(),
              const SizedBox(width: 16),
              _buildActionButtons(),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatsBar(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(
                    0xFF8B5CF6,
                  ).withValues(alpha: 0.2 * _glowAnimation.value),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF8B5CF6,
                  ).withValues(alpha: 0.3 * _glowAnimation.value),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF8B5CF6),
              size: 18,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF8B5CF6),
                    Color(0xFFD8A5FF),
                    Color(0xFF6366F1),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: const Text(
                  'Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Powered by emotional intelligence',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(children: [const SizedBox(width: 12), _buildExportButton()]);
  }

  Widget _buildExportButton() {
    return GestureDetector(
      onTap: widget.onExport,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: const Icon(
          Icons.ios_share_rounded,
          color: Color(0xFF8B5CF6),
          size: 16,
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withValues(alpha: 0.8),
            const Color(0xFF16213E).withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildStatItem(
            '42',
            'Entries',
            Icons.event_note_rounded,
            const Color(0xFF10B981),
          ),
          _buildStatDivider(),
          _buildStatItem(
            '7.8',
            'Avg Score',
            Icons.trending_up_rounded,
            const Color(0xFF6366F1),
          ),
          _buildStatDivider(),
          _buildStatItem(
            '12',
            'Patterns',
            Icons.psychology_rounded,
            const Color(0xFFFF6B35),
          ),
          _buildStatDivider(),
          _buildStatItem(
            '5',
            'Streaks',
            Icons.local_fire_department_rounded,
            const Color(0xFFFFD700),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.2),
                ),
                child: Icon(icon, color: color, size: 12),
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
