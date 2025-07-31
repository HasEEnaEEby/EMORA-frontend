import 'package:flutter/material.dart';

class ProfileFloatingButton extends StatelessWidget {
  final Animation<double> floatingAnimation;
  final VoidCallback onPressed;

  const ProfileFloatingButton({
    super.key,
    required this.floatingAnimation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, floatingAnimation.value * 0.5),
          child: FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: const Color(0xFF8B5CF6),
            elevation: 8,
            child: const Icon(Icons.qr_code, color: Colors.white, size: 28),
          ),
        );
      },
    );
  }
}