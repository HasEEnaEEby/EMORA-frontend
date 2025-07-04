import 'package:flutter/material.dart';

class EnhancedBottomNavigation extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final VoidCallback? onMoodTapped;
  final String currentMoodEmoji;

  const EnhancedBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.onMoodTapped,
    this.currentMoodEmoji = '😊',
  });

  @override
  State<EnhancedBottomNavigation> createState() =>
      _EnhancedBottomNavigationState();
}

class _EnhancedBottomNavigationState extends State<EnhancedBottomNavigation>
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
      height: 95, // Increased from 90 to 95
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 75, // Increased from 70 to 75
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ), // Reduced from 20 to 16
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Atlas (Map)
                  Expanded(
                    child: _buildNavItem(
                      index: 0,
                      icon: Icons.public_rounded,
                      activeIcon: Icons.public_rounded,
                      label: 'Atlas',
                      isActive: widget.selectedIndex == 0,
                    ),
                  ),

                  // Friends
                  Expanded(
                    child: _buildNavItem(
                      index: 1,
                      icon: Icons.people_outline_rounded,
                      activeIcon: Icons.people_rounded,
                      label: 'Friends',
                      isActive: widget.selectedIndex == 1,
                    ),
                  ),

                  // Space for floating mood button
                  const SizedBox(width: 70),

                  // Insights
                  Expanded(
                    child: _buildNavItem(
                      index: 2,
                      icon: Icons.insights_outlined,
                      activeIcon: Icons.insights_rounded,
                      label: 'Insights',
                      isActive: widget.selectedIndex == 2,
                    ),
                  ),

                  // Profile
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

          // Floating Mood Button
          Positioned(
            top: 5, // Increased from 0 to 5
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
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ), // Reduced padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // Reduced from 20 to 16
          color: isActive
              ? const Color(0xFF8B5CF6).withOpacity(0.15)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(6), // Reduced from 8 to 6
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? const Color(0xFF8B5CF6).withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[400],
                size: 22, // Reduced from 24 to 22
              ),
            ),
            const SizedBox(height: 2), // Reduced from 4 to 2
            Flexible(
              // Wrapped in Flexible to prevent overflow
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[500],
                  fontSize: 10, // Reduced from 12 to 10
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  height: 1.2, // Added line height
                ),
                maxLines: 1, // Added max lines
                overflow: TextOverflow.ellipsis, // Added overflow handling
                textAlign: TextAlign.center, // Center align text
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
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF6EE7B7),
                    Color(0xFF10B981),
                    Color(0xFF059669),
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF10B981,
                    ).withOpacity(_glowAnimation.value),
                    blurRadius: 25,
                    spreadRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6EE7B7).withOpacity(0.9),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.currentMoodEmoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
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

// Enhanced Mood Selector Modal
class MoodSelectorModal extends StatefulWidget {
  final String currentMood;
  final Function(String) onMoodSelected;

  const MoodSelectorModal({
    super.key,
    required this.currentMood,
    required this.onMoodSelected,
  });

  @override
  State<MoodSelectorModal> createState() => _MoodSelectorModalState();
}

class _MoodSelectorModalState extends State<MoodSelectorModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _moodOptions = [
    {'emoji': '😄', 'label': 'Amazing', 'color': Color(0xFFFFD700)},
    {'emoji': '😊', 'label': 'Good', 'color': Color(0xFF6EE7B7)},
    {'emoji': '😐', 'label': 'Okay', 'color': Color(0xFF9CA3AF)},
    {'emoji': '😔', 'label': 'Down', 'color': Color(0xFF6366F1)},
    {'emoji': '😭', 'label': 'Awful', 'color': Color(0xFF6B7280)},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _slideController.forward();
    _fadeController.forward();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF111827)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'How was your day?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 32),

                // Mood Options
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _moodOptions.map((mood) {
                      final isSelected = mood['emoji'] == widget.currentMood;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildMoodOption(
                          emoji: mood['emoji'],
                          label: mood['label'],
                          color: mood['color'],
                          isSelected: isSelected,
                          onTap: () => _selectMood(mood['emoji']),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodOption({
    required String emoji,
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
            ),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
        ),
      ),
    );
  }

  void _selectMood(String emoji) {
    widget.onMoodSelected(emoji);
    Navigator.of(context).pop();
  }
}

// Usage Helper Extension
extension BottomNavHelper on BuildContext {
  void showMoodSelector({
    required String currentMood,
    required Function(String) onMoodSelected,
  }) {
    showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MoodSelectorModal(
        currentMood: currentMood,
        onMoodSelected: onMoodSelected,
      ),
    );
  }
}
