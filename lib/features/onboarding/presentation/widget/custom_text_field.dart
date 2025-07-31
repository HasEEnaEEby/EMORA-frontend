import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLength;
  final int? maxLines;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final String? errorText;
  final bool showCharacterCount;

  const CustomTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.maxLength,
    this.maxLines = 1,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.errorText,
    this.showCharacterCount = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _scaleAnimation;

  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _borderColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: widget.focusedBorderColor ?? const Color(0xFF8B5FBF),
    ).animate(_animationController);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    widget.focusNode?.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.errorText != oldWidget.errorText) {
      setState(() {
        _hasError = widget.errorText != null;
      });
    }
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });

    if (_isFocused) {
      _animationController.forward();
      HapticFeedback.lightImpact();
    } else {
      _animationController.reverse();
    }
  }

  void _onTextChange() {
    if (widget.onChanged != null) {
      widget.onChanged!(widget.controller.text);
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _animationController.dispose();
    super.dispose();
  }

  Color _getBorderColor() {
    if (_hasError) {
      return widget.errorBorderColor ?? Colors.red.withOpacity(0.5);
    }
    if (_isFocused) {
      return widget.focusedBorderColor ??
          const Color(0xFF8B5FBF).withOpacity(0.5);
    }
    return widget.borderColor ?? Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _getBorderColor(), width: 1.5),
              boxShadow: _isFocused && !_hasError
                  ? [
                      BoxShadow(
                        color:
                            (widget.focusedBorderColor ??
                                    const Color(0xFF8B5FBF))
                                .withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? (widget.focusedBorderColor ??
                                const Color(0xFF8B5FBF))
                          : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    obscureText: widget.obscureText,
                    enabled: widget.enabled,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    maxLength: widget.maxLength,
                    maxLines: widget.maxLines,
                    style: TextStyle(
                      color: widget.enabled ? Colors.white : Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: widget.prefixIcon == null ? 16 : 0,
                      ),
counterText: '', 
                    ),
                    onSubmitted: widget.onSubmitted,
                  ),
                ),
                if (widget.suffixIcon != null)
                  GestureDetector(
                    onTap: () {
                      if (widget.onSuffixIconTap != null) {
                        HapticFeedback.lightImpact();
                        widget.onSuffixIconTap!();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        widget.suffixIcon,
                        color: _isFocused
                            ? (widget.focusedBorderColor ??
                                  const Color(0xFF8B5FBF))
                            : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        if (widget.errorText != null ||
            (widget.showCharacterCount && widget.maxLength != null))
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
            child: Row(
              children: [
                if (widget.errorText != null)
                  Expanded(
                    child: Text(
                      widget.errorText!,
                      style: TextStyle(
                        color: widget.errorBorderColor ?? Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                if (widget.showCharacterCount && widget.maxLength != null)
                  Text(
                    '${widget.controller.text.length}/${widget.maxLength}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
