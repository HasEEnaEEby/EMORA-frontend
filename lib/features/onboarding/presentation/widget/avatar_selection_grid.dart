import 'package:flutter/material.dart';

class AvatarSelectionGrid extends StatefulWidget {
final List<dynamic> avatars; 
  final String? selectedAvatar;
  final Function(String) onAvatarSelected;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const AvatarSelectionGrid({
    super.key,
    required this.avatars,
    required this.onAvatarSelected,
    this.selectedAvatar,
    this.crossAxisCount = 3,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
  });

  @override
  State<AvatarSelectionGrid> createState() => _AvatarSelectionGridState();
}

class _AvatarSelectionGridState extends State<AvatarSelectionGrid>
    with TickerProviderStateMixin {
  late AnimationController _gridAnimationController;
  late List<AnimationController> _itemAnimationControllers;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();

    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _itemAnimationControllers = List.generate(
      widget.avatars.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 200 + (index * 50)),
        vsync: this,
      ),
    );

    _itemAnimations = _itemAnimationControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    }).toList();

    _startStaggeredAnimations();
  }

  void _startStaggeredAnimations() {
    for (int i = 0; i < _itemAnimationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _itemAnimationControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    for (var controller in _itemAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _extractAvatarValue(dynamic avatar) {
    if (avatar is String) {
      return avatar;
    } else if (avatar is Map<String, dynamic>) {
      return avatar['value']?.toString() ??
          avatar['name']?.toString() ??
          avatar['id']?.toString() ??
          avatar['avatar']?.toString() ??
          avatar.toString();
    } else {
      return avatar.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: 1.0,
      ),
      itemCount: widget.avatars.length,
      itemBuilder: (context, index) {
        final avatar = _extractAvatarValue(
          widget.avatars[index],
); 
        final isSelected = widget.selectedAvatar == avatar;

        return AnimatedBuilder(
          animation: _itemAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _itemAnimations[index].value,
              child: AvatarItem(
                avatar: avatar,
                isSelected: isSelected,
                onTap: () => widget.onAvatarSelected(avatar),
              ),
            );
          },
        );
      },
    );
  }
}

class AvatarItem extends StatefulWidget {
  final String avatar;
  final bool isSelected;
  final VoidCallback onTap;

  const AvatarItem({
    super.key,
    required this.avatar,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<AvatarItem> createState() => _AvatarItemState();
}

class _AvatarItemState extends State<AvatarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _selectionController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _selectionController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _selectionController, curve: Curves.easeInOut),
    );

    if (widget.isSelected) {
      _selectionController.forward();
    }
  }

  @override
  void didUpdateWidget(AvatarItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  String _getAvatarEmoji(String avatar) {
    const avatarEmojis = {
      'panda': '🐼',
      'elephant': '🐘',
      'horse': '🐴',
      'rabbit': '🐰',
      'fox': '🦊',
      'zebra': '🦓',
      'bear': '🐻',
      'pig': '🐷',
      'raccoon': '🦝',
      'cat': '🐱',
      'dog': '🐶',
      'lion': '🦁',
      'tiger': '🐯',
      'monkey': '🐵',
      'koala': '🐨',
      'hamster': '🐹',
      'frog': '🐸',
      'penguin': '🐧',
      'owl': '🦉',
      'deer': '🦌',
    };

    return avatarEmojis[avatar.toLowerCase()] ?? '🐾';
  }

  Color _getAvatarBackgroundColor(String avatar) {
    const avatarColors = {
      'panda': Color(0xFF2D2D2D),
      'elephant': Color(0xFF4A4A4A),
      'horse': Color(0xFF8B4513),
      'rabbit': Color(0xFFE6E6FA),
      'fox': Color(0xFFFF6B35),
      'zebra': Color(0xFF2F2F2F),
      'bear': Color(0xFF8B4513),
      'pig': Color(0xFFFFB6C1),
      'raccoon': Color(0xFF36454F),
      'cat': Color(0xFF708090),
      'dog': Color(0xFFDEB887),
      'lion': Color(0xFFDAA520),
      'tiger': Color(0xFFFF8C00),
      'monkey': Color(0xFFCD853F),
      'koala': Color(0xFF808080),
      'hamster': Color(0xFFF4A460),
      'frog': Color(0xFF228B22),
      'penguin': Color(0xFF2F4F4F),
      'owl': Color(0xFF8B4513),
      'deer': Color(0xFFD2B48C),
    };

    return avatarColors[avatar.toLowerCase()] ?? const Color(0xFF8B5FBF);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _selectionController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? 0.9 : (_scaleAnimation.value),
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? _getAvatarBackgroundColor(
                          widget.avatar,
                        ).withValues(alpha: 0.3)
                      : const Color(0xFF2A2A3E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isSelected
                        ? const Color(0xFF8B5FBF)
                        : Colors.transparent,
                    width: widget.isSelected ? 3 : 0,
                  ),
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF8B5FBF,
                            ).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _getAvatarBackgroundColor(
                                widget.avatar,
                              ).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _getAvatarEmoji(widget.avatar),
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.avatar.toUpperCase(),
                            style: TextStyle(
                              color: widget.isSelected
                                  ? Colors.white
                                  : Colors.grey[400],
                              fontSize: 12,
                              fontWeight: widget.isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B5FBF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
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
