import 'package:flutter/material.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';

class DebouncedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Duration debounceTime;
  final String? loadingText;
  final Color? loadingColor;

  const DebouncedButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.debounceTime = const Duration(milliseconds: 500),
    this.loadingText,
    this.loadingColor,
  }) : super(key: key);

  @override
  State<DebouncedButton> createState() => _DebouncedButtonState();
}

class _DebouncedButtonState extends State<DebouncedButton> {
  bool _isDebouncing = false;
  DateTime? _lastTapTime;

  void _handleTap() {
    if (widget.onPressed == null || widget.isLoading || _isDebouncing) {
      Logger.info('🔒 Button tap ignored: ${widget.isLoading ? "loading" : "debouncing"}');
      return;
    }

    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < widget.debounceTime) {
      Logger.info('⏱️ Button tap debounced (${widget.debounceTime.inMilliseconds}ms)');
      return;
    }

    _lastTapTime = now;
    _isDebouncing = true;

    Logger.info('. Button tap processed');
    widget.onPressed!();

    Future.delayed(widget.debounceTime, () {
      if (mounted) {
        setState(() {
          _isDebouncing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || 
                       widget.isLoading || 
                       _isDebouncing;

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: AbsorbPointer(
        absorbing: isDisabled,
        child: widget.child,
      ),
    );
  }
}

class FriendRequestButton extends StatelessWidget {
  final String userId;
  final bool isLoading;
  final VoidCallback? onPressed;
  final String buttonText;
  final IconData? icon;

  const FriendRequestButton({
    Key? key,
    required this.userId,
    required this.isLoading,
    this.onPressed,
    this.buttonText = 'Send Request',
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DebouncedButton(
      isLoading: isLoading,
      onPressed: onPressed,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading 
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            )
          : icon != null ? Icon(icon) : const Icon(Icons.person_add),
        label: Text(isLoading ? 'Sending...' : buttonText),
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading 
            ? Colors.grey 
            : Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
} 