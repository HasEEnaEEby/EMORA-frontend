import 'package:emora_mobile_app/app/constants/app_colors.dart';
import 'package:emora_mobile_app/app/constants/app_dimensions.dart';
import 'package:flutter/material.dart';

class EnhancedBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onVentingTapped;

  const EnhancedBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onVentingTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingMedium,
        horizontal: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXLarge),
        ),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_filled, 'Home', AppColors.navHome),
            _buildNavItem(
              1,
              Icons.public,
              'Mood Atlas',
              AppColors.navMoodAtlas,
            ),
            _buildNavItem(2, Icons.insights, 'Insights', AppColors.navInsights),
            _buildNavItem(3, Icons.people, 'Friends', AppColors.navFriends),
            _buildVentingNavItem(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color color) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingSmall,
          horizontal: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? color
                  : AppColors.white.withValues(alpha: 0.5),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: AppDimensions.textSmall,
                color: isSelected
                    ? color
                    : AppColors.white.withValues(alpha: 0.5),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVentingNavItem() {
    return GestureDetector(
      onTap: onVentingTapped,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingSmall,
          horizontal: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.navVenting.withValues(alpha: 0.2),
              const Color(0xFF9C27B0).withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: AppColors.navVenting.withValues(alpha: 0.3),
          ),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.air, color: AppColors.navVenting, size: 22),
            SizedBox(height: 4),
            Text(
              'Vent',
              style: TextStyle(
                fontSize: AppDimensions.textSmall,
                color: AppColors.navVenting,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
