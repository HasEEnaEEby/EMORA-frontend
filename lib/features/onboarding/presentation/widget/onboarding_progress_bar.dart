import 'package:flutter/material.dart';

class OnboardingProgressBar extends StatefulWidget {
  final double progress;
  final int totalSteps;
  final int currentStep;
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;

  const OnboardingProgressBar({
    super.key,
    required this.progress,
    required this.totalSteps,
    required this.currentStep,
    this.backgroundColor,
    this.progressColor,
    this.height = 6.0,
  });

  @override
  State<OnboardingProgressBar> createState() => _OnboardingProgressBarState();
}

class _OnboardingProgressBarState extends State<OnboardingProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(OnboardingProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation =
          Tween<double>(
            begin: oldWidget.progress,
            end: widget.progress,
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: _buildProgressBar(),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(widget.height / 2),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final progressWidth =
                  constraints.maxWidth * _progressAnimation.value;

              return Stack(
                children: [
                  Container(
                    width: progressWidth,
                    height: widget.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.progressColor ?? const Color(0xFF8B5FBF),
                          (widget.progressColor ?? const Color(0xFF8B5FBF))
                              .withValues(alpha: 0.9),
                          widget.progressColor ?? const Color(0xFF8B5FBF),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(widget.height / 2),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
