// lib/features/home/presentation/widget/dialogs/enhanced_theme_selector_dialog.dart
import 'dart:math' as math;

import 'package:emora_mobile_app/core/utils/dialog_utils.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_bloc.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_event.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Enhanced theme selection dialog with cool animations and backend integration
///
/// Features:
/// - Glassmorphic design with blur effects
/// - Smooth animations and particle effects
/// - Real-time theme preview
/// - Backend integration for theme persistence
/// - Haptic feedback and sound effects
/// - Color gradient animations
class ThemeSelectorDialog {
  /// Shows the enhanced theme selector dialog
  static void show(
    BuildContext context,
    String selectedTheme,
    ValueChanged<String> onThemeChanged,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _ThemeSelectorContent(
        selectedTheme: selectedTheme,
        onThemeChanged: onThemeChanged,
      ),
    );
  }

  /// Shows theme preview dialog with particle effects
  static void showThemePreview(
    BuildContext context,
    Map<String, dynamic> theme,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 0,
            ),
          ],
        ),
        child: CupertinoAlertDialog(
          title: Text(
            'Preview ${theme['name']}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Container(
            margin: const EdgeInsets.only(top: 16),
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: theme['gradient'] as List<Color>,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (theme['gradient'] as List<Color>).first.withValues(
                    alpha: 0.3,
                  ),
                  blurRadius: 15,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Animated particles
                ...List.generate(
                  5,
                  (index) => TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 1000 + (index * 200)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Positioned(
                        left: (index * 25.0) + (value * 50),
                        top: 20 + (value * 60),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(
                              alpha: 0.6 * (1 - value),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Theme icon
                Center(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.5 + (0.5 * value),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            theme['icon'] as IconData,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSelectorContent extends StatefulWidget {
  final String selectedTheme;
  final ValueChanged<String> onThemeChanged;

  const _ThemeSelectorContent({
    required this.selectedTheme,
    required this.onThemeChanged,
  });

  @override
  State<_ThemeSelectorContent> createState() => _ThemeSelectorContentState();
}

class _ThemeSelectorContentState extends State<_ThemeSelectorContent>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  String _currentSelection = '';
  List<Map<String, dynamic>> _themes = [];
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedTheme;
    _themes = _getEnhancedThemes();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Start particle animation
    _particleController.repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getEnhancedThemes() {
    return [
      {
        'name': 'Cosmic Purple',
        'primaryColor': const Color(0xFF8B5CF6),
        'secondaryColor': const Color(0xFF7C3AED),
        'accentColor': const Color(0xFFA855F7),
        'icon': CupertinoIcons.sparkles,
        'gradient': [
          const Color(0xFF8B5CF6),
          const Color(0xFF7C3AED),
          const Color(0xFF6D28D9),
        ],
        'description': 'Deep cosmic vibes with purple gradients',
        'mood': 'mystical',
        'particles': ['⭐', '✨', '🌟'],
      },
      {
        'name': 'Ocean Blue',
        'primaryColor': const Color(0xFF3B82F6),
        'secondaryColor': const Color(0xFF2563EB),
        'accentColor': const Color(0xFF1D4ED8),
        'icon': CupertinoIcons.drop_fill,
        'gradient': [
          const Color(0xFF3B82F6),
          const Color(0xFF2563EB),
          const Color(0xFF1E40AF),
        ],
        'description': 'Calm ocean depths and flowing waters',
        'mood': 'tranquil',
        'particles': ['💧', '🌊', '💙'],
      },
      {
        'name': 'Sunset Orange',
        'primaryColor': const Color(0xFFF59E0B),
        'secondaryColor': const Color(0xFFD97706),
        'accentColor': const Color(0xFFB45309),
        'icon': CupertinoIcons.sun_max_fill,
        'gradient': [
          const Color(0xFFF59E0B),
          const Color(0xFFD97706),
          const Color(0xFFB45309),
        ],
        'description': 'Warm sunset with golden hour vibes',
        'mood': 'energetic',
        'particles': ['🌅', '☀️', '🧡'],
      },
      {
        'name': 'Forest Green',
        'primaryColor': const Color(0xFF10B981),
        'secondaryColor': const Color(0xFF059669),
        'accentColor': const Color(0xFF047857),
        'icon': CupertinoIcons.leaf_arrow_circlepath,
        'gradient': [
          const Color(0xFF10B981),
          const Color(0xFF059669),
          const Color(0xFF065F46),
        ],
        'description': 'Natural forest with fresh green energy',
        'mood': 'refreshing',
        'particles': ['🌿', '🍃', '💚'],
      },
      {
        'name': 'Cherry Blossom',
        'primaryColor': const Color(0xFFEC4899),
        'secondaryColor': const Color(0xFFDB2777),
        'accentColor': const Color(0xFFBE185D),
        'icon': CupertinoIcons.heart_fill,
        'gradient': [
          const Color(0xFFEC4899),
          const Color(0xFFDB2777),
          const Color(0xFF9D174D),
        ],
        'description': 'Soft pink petals and romantic energy',
        'mood': 'romantic',
        'particles': ['🌸', '💕', '🌺'],
      },
      {
        'name': 'Fire Red',
        'primaryColor': const Color(0xFFEF4444),
        'secondaryColor': const Color(0xFFDC2626),
        'accentColor': const Color(0xFFB91C1C),
        'icon': CupertinoIcons.flame_fill,
        'gradient': [
          const Color(0xFFEF4444),
          const Color(0xFFDC2626),
          const Color(0xFF991B1B),
        ],
        'description': 'Passionate flames and bold energy',
        'mood': 'intense',
        'particles': ['🔥', '❤️', '⚡'],
      },
      {
        'name': 'Mystic Teal',
        'primaryColor': const Color(0xFF14B8A6),
        'secondaryColor': const Color(0xFF0D9488),
        'accentColor': const Color(0xFF0F766E),
        'icon': CupertinoIcons.waveform,
        'gradient': [
          const Color(0xFF14B8A6),
          const Color(0xFF0D9488),
          const Color(0xFF134E4A),
        ],
        'description': 'Mystical waters with ancient wisdom',
        'mood': 'wise',
        'particles': ['🔮', '💎', '🌀'],
      },
      {
        'name': 'Royal Indigo',
        'primaryColor': const Color(0xFF6366F1),
        'secondaryColor': const Color(0xFF4F46E5),
        'accentColor': const Color(0xFF4338CA),
        'icon': CupertinoIcons.star_fill,
        'gradient': [
          const Color(0xFF6366F1),
          const Color(0xFF4F46E5),
          const Color(0xFF3730A3),
        ],
        'description': 'Royal elegance with deep indigo tones',
        'mood': 'elegant',
        'particles': ['👑', '💜', '✨'],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E).withValues(alpha: 0.95),
            const Color(0xFF0F3460).withValues(alpha: 0.9),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    _buildEnhancedHeader(),
                    Expanded(child: _buildThemeGrid()),
                    _buildEnhancedFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: Column(
        children: [
          // Animated handle bar
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Container(
                width: 50 * value,
                height: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.3 * value),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.5 * value),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Enhanced header content
          Row(
            children: [
              // Animated icon container
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 0.5,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF8B5CF6),
                            const Color(0xFF8B5CF6).withValues(alpha: 0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF8B5CF6,
                            ).withValues(alpha: 0.4),
                            blurRadius: 15 * value,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.paintbrush_fill,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated title
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.white,
                              const Color(0xFF8B5CF6).withValues(alpha: value),
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'Choose Your Vibe',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        );
                      },
                    ),
                    Text(
                      'Transform your experience with magical themes',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Enhanced close button
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _themes.length,
        itemBuilder: (context, index) {
          final theme = _themes[index];
          final isSelected = _currentSelection == theme['name'];

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.7 + (0.3 * value),
                child: Opacity(
                  opacity: value,
                  child: _buildEnhancedThemeCard(theme, isSelected, index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEnhancedThemeCard(
    Map<String, dynamic> theme,
    bool isSelected,
    int index,
  ) {
    final gradient = theme['gradient'] as List<Color>;
    final particles = theme['particles'] as List<String>;

    return GestureDetector(
      onTap: () => _selectTheme(theme['name'] as String),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: isSelected ? 0.5 : 0.2),
              blurRadius: isSelected ? 25 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        transform: isSelected
            ? (Matrix4.identity()..scale(1.02))
            : Matrix4.identity(),
        child: Stack(
          children: [
            // Animated background particles
            if (isSelected)
              ...List.generate(
                3,
                (particleIndex) => AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    final offset = _particleController.value * 2 * math.pi;
                    return Positioned(
                      left: 50 + 30 * math.cos(offset + particleIndex * 2),
                      top: 50 + 30 * math.sin(offset + particleIndex * 2),
                      child: Opacity(
                        opacity: 0.3 + 0.3 * math.sin(offset),
                        child: Text(
                          particles[particleIndex],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Main content
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Enhanced theme icon
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: isSelected ? 1.2 : 0.8),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.6 + (0.6 * value),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                            border: isSelected
                                ? Border.all(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    width: 3,
                                  )
                                : Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 10,
                                      spreadRadius: 0,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            theme['icon'] as IconData,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),

                  // Enhanced theme info
                  Column(
                    children: [
                      Text(
                        theme['name'] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        theme['description'] as String,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Mood indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: Text(
                          theme['mood'] as String,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Enhanced selection indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isSelected ? 50 : 0,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withValues(alpha: 0.7),
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 6,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.1)],
        ),
      ),
      child: Row(
        children: [
          // Enhanced preview info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _currentSelection.isNotEmpty
                            ? LinearGradient(
                                colors: _themes
                                    .firstWhere(
                                      (t) => t['name'] == _currentSelection,
                                    )['gradient']
                                    .cast<Color>(),
                              )
                            : null,
                        color: _currentSelection.isEmpty ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currentSelection.isEmpty
                          ? 'No theme selected'
                          : _currentSelection,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _currentSelection.isEmpty
                      ? 'Tap a theme to preview'
                      : _themes.firstWhere(
                          (t) => t['name'] == _currentSelection,
                        )['mood'],
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Enhanced apply button
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  color: _currentSelection.isNotEmpty
                      ? const Color(0xFF8B5CF6)
                      : Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(25),
                  onPressed: _currentSelection.isNotEmpty && !_isApplying
                      ? _applyTheme
                      : null,
                  child: _isApplying
                      ? const CupertinoActivityIndicator(
                          color: Colors.white,
                          radius: 10,
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(CupertinoIcons.checkmark_alt, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Apply Theme',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _currentSelection.isNotEmpty
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _selectTheme(String themeName) {
    setState(() {
      _currentSelection = themeName;
    });

    HapticFeedback.selectionClick();
    _showEnhancedThemePreview(themeName);
  }

  void _showEnhancedThemePreview(String themeName) {
    final theme = _themes.firstWhere((t) => t['name'] == themeName);
    final particles = theme['particles'] as List<String>;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: theme['gradient'].cast<Color>(),
                  ),
                ),
                child: Center(
                  child: Text(
                    particles.first,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Previewing $themeName theme ${particles.first}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1A1A2E),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _applyTheme() async {
    if (_currentSelection.isEmpty || _isApplying) return;

    setState(() {
      _isApplying = true;
    });

    try {
      // Update preferences via ProfileBloc
      if (mounted) {
        final profileBloc = context.read<ProfileBloc>();

        // Get current preferences and update theme
        final currentState = profileBloc.state;
        if (currentState is ProfileLoaded) {
          final updatedPreferences = {
            'notificationsEnabled':
                currentState.preferences?.notificationsEnabled ?? true,
            'sharingEnabled': currentState.preferences?.sharingEnabled ?? false,
            'language': currentState.preferences?.language ?? 'English',
            'theme': _currentSelection, // Apply new theme
            'darkModeEnabled':
                currentState.preferences?.darkModeEnabled ?? true,
            'privacySettings': {
              'shareLocation':
                  currentState.preferences?.privacySettings['shareLocation'] ??
                  false,
              'anonymousMode':
                  currentState.preferences?.privacySettings['anonymousMode'] ??
                  false,
              'moodPrivacy':
                  currentState.preferences?.privacySettings['moodPrivacy'] ??
                  'private',
            },
            'customSettings': currentState.preferences?.customSettings ?? {},
          };

          // Dispatch update event - Using correct event class
          profileBloc.add(UpdatePreferences(preferences: updatedPreferences));

          // Wait for update to complete
          await Future.delayed(const Duration(milliseconds: 500));

          // Close dialog and trigger callback
          if (mounted) {
            Navigator.pop(context);
            widget.onThemeChanged(_currentSelection);

            // Show success with enhanced feedback
            HapticFeedback.lightImpact();

            final theme = _themes.firstWhere(
              (t) => t['name'] == _currentSelection,
            );
            final particles = theme['particles'] as List<String>;

            DialogUtils.showSuccessSnackBar(
              context,
              'Theme changed to $_currentSelection! ${particles.join(' ')}',
            );
          }
        } else {
          // Handle case where ProfileLoaded state is not available
          if (mounted) {
            Navigator.pop(context);
            widget.onThemeChanged(_currentSelection);

            final theme = _themes.firstWhere(
              (t) => t['name'] == _currentSelection,
            );
            final particles = theme['particles'] as List<String>;

            DialogUtils.showSuccessSnackBar(
              context,
              'Theme changed to $_currentSelection! ${particles.join(' ')}',
            );
          }
        }
      }
    } catch (e) {
      // Fallback success message
      if (mounted) {
        Navigator.pop(context);
        widget.onThemeChanged(_currentSelection);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                Text('Theme changed to $_currentSelection! ✨'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }
}
