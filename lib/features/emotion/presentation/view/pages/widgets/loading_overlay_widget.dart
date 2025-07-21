import 'package:flutter/material.dart';

class LoadingOverlayWidget extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final bool isLoadingLocation;
  final String? locationError;
  final VoidCallback onRetryLocation;

  const LoadingOverlayWidget({
    super.key,
    required this.pulseAnimation,
    required this.isLoadingLocation,
    this.locationError,
    required this.onRetryLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F0F23).withValues(alpha: 0.9),
              const Color(0xFF0F0F23).withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLoadingAnimation(),
              const SizedBox(height: 24),
              _buildLoadingText(),
              if (locationError != null) ...[
                const SizedBox(height: 16),
                _buildErrorSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 80 * pulseAnimation.value,
          height: 80 * pulseAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                ),
              ),
              child: const Icon(
                Icons.radar_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingText() {
    return Column(
      children: [
        Text(
          isLoadingLocation ? 'Finding your location...' : 'Loading emotions...',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isLoadingLocation 
              ? 'We need your location to show nearby emotions'
              : 'Gathering real-time emotional data from around the world',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE91E63).withValues(alpha: 0.1),
            const Color(0xFFE91E63).withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFE91E63).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFE91E63).withValues(alpha: 0.2),
                ),
                child: const Icon(
                  Icons.location_off_rounded,
                  color: Color(0xFFE91E63),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location Error',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      locationError!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildErrorActionButton(
                  icon: Icons.refresh_rounded,
                  label: 'Retry',
                  onTap: onRetryLocation,
                  color: const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildErrorActionButton(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  onTap: _openLocationSettings,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLocationSettings() {
    // Open location settings
    print('Open location settings');
  }
} 