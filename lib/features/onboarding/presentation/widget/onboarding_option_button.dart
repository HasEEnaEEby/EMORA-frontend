import 'package:flutter/material.dart';

class OnboardingOptionButton extends StatefulWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap; // Changed from onPressed to onTap and made required
  final IconData? icon;
  final Widget? trailing;
  final double? width;
  final double height;

  const OnboardingOptionButton({
    super.key,
    required this.text,
    required this.onTap, // Made required
    this.isSelected = false,
    this.icon,
    this.trailing,
    this.width,
    this.height = 56,
  });

  @override
  State<OnboardingOptionButton> createState() => _OnboardingOptionButtonState();
}

class _OnboardingOptionButtonState extends State<OnboardingOptionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Color?> _borderAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation =
        ColorTween(
          begin: const Color(0xFF2A2A3E),
          end: const Color(0xFF8B5FBF).withOpacity(0.2),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _borderAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: const Color(0xFF8B5FBF),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(OnboardingOptionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? 0.95 : _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap, // Changed from onPressed to onTap
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: widget.width ?? double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? const Color(0xFF8B5FBF).withOpacity(0.15)
                    : const Color(0xFF2A2A3E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.isSelected
                      ? const Color(0xFF8B5FBF)
                      : Colors.transparent,
                  width: widget.isSelected ? 1.5 : 0,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF8B5FBF).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: widget.isSelected
                            ? const Color(0xFF8B5FBF)
                            : Colors.grey[400],
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          color: widget.isSelected
                              ? Colors.white
                              : Colors.grey[300],
                          fontSize: 16,
                          fontWeight: widget.isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.trailing != null) ...[
                      const SizedBox(width: 12),
                      widget.trailing!,
                    ] else if (widget.isSelected) ...[
                      const SizedBox(width: 12),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B5FBF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class OnboardingMultiOptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap; // Changed from onPressed to onTap
  final IconData? icon;
  final Color? selectedColor;

  const OnboardingMultiOptionButton({
    super.key,
    required this.text,
    required this.onTap, // Made required
    this.isSelected = false,
    this.icon,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingOptionButton(
      text: text,
      isSelected: isSelected,
      onTap: onTap, // Changed from onPressed to onTap
      icon: icon,
      trailing: isSelected
          ? Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: selectedColor ?? const Color(0xFF8B5FBF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            )
          : Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[500]!, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
    );
  }
}

class OnboardingChipButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap; // Changed from onPressed to onTap
  final IconData? icon;

  const OnboardingChipButton({
    super.key,
    required this.text,
    required this.onTap, // Made required
    this.isSelected = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Changed from onPressed to onTap
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5FBF) : const Color(0xFF2A2A3E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5FBF) : Colors.grey[600]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[400],
                size: 16,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[300],
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResponsiveOnboardingOptionButton extends StatefulWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? trailing;
  final double? width;
  final double height;

  const ResponsiveOnboardingOptionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isSelected = false,
    this.icon,
    this.trailing,
    this.width,
    this.height = 56,
  });

  @override
  State<ResponsiveOnboardingOptionButton> createState() => _ResponsiveOnboardingOptionButtonState();
}

class _ResponsiveOnboardingOptionButtonState extends State<ResponsiveOnboardingOptionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ResponsiveOnboardingOptionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ✅ Dynamic font size based on button height
  double get _fontSize {
    if (widget.height <= 40) return 13;
    if (widget.height <= 48) return 14;
    if (widget.height <= 52) return 15;
    return 16; // Default for height > 52
  }

  // ✅ Dynamic icon size based on button height
  double get _iconSize {
    if (widget.height <= 40) return 18;
    if (widget.height <= 48) return 20;
    return 22; // Default for height > 48
  }

  // ✅ Dynamic padding based on button height
  double get _horizontalPadding {
    if (widget.height <= 40) return 14;
    if (widget.height <= 48) return 16;
    return 20; // Default for height > 48
  }

  // ✅ Dynamic spacing based on button height
  double get _spacing {
    if (widget.height <= 40) return 8;
    if (widget.height <= 48) return 10;
    return 12; // Default for height > 48
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0xFF8B5FBF).withOpacity(0.15)
                : const Color(0xFF2A2A3E),
            borderRadius: BorderRadius.circular(widget.height <= 40 ? 10 : 14),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFF8B5FBF)
                  : Colors.transparent,
              width: widget.isSelected ? 1.5 : 0,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF8B5FBF).withOpacity(0.2),
                      blurRadius: widget.height <= 40 ? 4 : 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: widget.isSelected
                        ? const Color(0xFF8B5FBF)
                        : Colors.grey[400],
                    size: _iconSize,
                  ),
                  SizedBox(width: _spacing),
                ],
                Expanded(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.isSelected
                          ? Colors.white
                          : Colors.grey[300],
                      fontSize: _fontSize,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.trailing != null) ...[
                  SizedBox(width: _spacing),
                  widget.trailing!,
                ] else if (widget.isSelected) ...[
                  SizedBox(width: _spacing),
                  Container(
                    width: _iconSize - 2,
                    height: _iconSize - 2,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B5FBF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: _iconSize - 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}