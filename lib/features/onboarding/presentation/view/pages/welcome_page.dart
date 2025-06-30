import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entity/onboarding_entity.dart';
import '../../view_model/bloc/onboarding_bloc.dart';
import '../../view_model/bloc/onboarding_event.dart';

class WelcomePage extends StatefulWidget {
  final OnboardingStepEntity step;
  final UserOnboardingEntity userData;
  final bool canContinue;
  final VoidCallback? onContinue;

  const WelcomePage({
    super.key,
    required this.step,
    required this.userData,
    this.canContinue = false,
    this.onContinue,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Controllers
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  // Focus nodes
  late FocusNode _usernameFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _confirmPasswordFocusNode;

  // Animation controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _suggestionAnimationController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _suggestionAnimation;

  // State variables
  bool _isUsernameValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isCheckingUsername = false;
  bool _showPasswordRequirements = false;
  bool _showUsernameSuggestions = false;

  String? _usernameError;
  String? _passwordError;
  String? _confirmPasswordError;
  List<String> _usernameSuggestions = [];

  Timer? _debounceTimer;
  Timer? _typingTimer;

  // Discord-style username suffixes and prefixes
  final List<String> _coolSuffixes = [
    'gaming', 'pro', 'official', 'real', 'main', 'alt', 'new', 'fresh',
    'v2', 'v3', '2024', '2025', 'og', 'prime', 'elite', 'legend',
    'master', 'ninja', 'warrior', 'hero', 'ace', 'star', 'king', 'queen'
  ];

  final List<String> _coolPrefixes = [
    'the', 'real', 'official', 'true', 'new', 'fresh', 'pro', 'epic',
    'super', 'mega', 'ultra', 'alpha', 'beta', 'omega', 'prime'
  ];

  final List<String> _reservedUsernames = [
    'admin', 'administrator', 'root', 'moderator', 'support', 'help',
    'api', 'www', 'mail', 'email', 'system', 'service', 'emora',
    'official', 'staff', 'team', 'bot', 'null', 'undefined', 'user',
    'test', 'demo', 'guest', 'anonymous', 'public', 'private'
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _setupListeners();
    _startInitialAnimations();
  }

  void _initializeControllers() {
    _usernameController = TextEditingController(
      text: widget.userData.username ?? '',
    );
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _usernameFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _suggestionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _suggestionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _suggestionAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _setupListeners() {
    _usernameController.addListener(_onUsernameChanged);
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onConfirmPasswordChanged);

    _passwordFocusNode.addListener(() {
      setState(() {
        _showPasswordRequirements = _passwordFocusNode.hasFocus;
      });
    });

    _usernameFocusNode.addListener(() {
      if (!_usernameFocusNode.hasFocus) {
        setState(() {
          _showUsernameSuggestions = false;
        });
        _suggestionAnimationController.reverse();
      }
    });

    _pulseAnimationController.repeat(reverse: true);
  }

  void _startInitialAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _slideAnimationController.forward();
    });

    // Auto focus with animation delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && _usernameController.text.isEmpty) {
        _usernameFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _typingTimer?.cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _pulseAnimationController.dispose();
    _suggestionAnimationController.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    _validateUsername();
    _validateAllInputs();
    _showTypingIndicator();

    final username = _usernameController.text.trim();
    if (username.isNotEmpty && _isUsernameFormatValid(username)) {
      _debounceUsernameCheck(username);
    } else {
      setState(() {
        _showUsernameSuggestions = false;
        _usernameSuggestions.clear();
      });
      _suggestionAnimationController.reverse();
    }
  }

  void _onPasswordChanged() {
    _validatePassword();
    _validateConfirmPassword();
    _validateAllInputs();
  }

  void _onConfirmPasswordChanged() {
    _validateConfirmPassword();
    _validateAllInputs();
  }

  void _showTypingIndicator() {
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        HapticFeedback.lightImpact();
      }
    });
  }

  void _debounceUsernameCheck(String username) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        _checkUsernameAvailability(username);
      }
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
      _showUsernameSuggestions = false;
    });
    _suggestionAnimationController.reverse();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if username is reserved or taken
      final isReserved = _reservedUsernames.contains(username.toLowerCase());
      final takenUsernames = ['john', 'jane', 'mike', 'sarah', 'alex', 'chris'];
      final isTaken = takenUsernames.contains(username.toLowerCase());
      final isAvailable = !isReserved && !isTaken;

      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
          if (isAvailable) {
            _usernameError = null;
            _isUsernameValid = _isUsernameFormatValid(username);
            _showUsernameSuggestions = false;
            _usernameSuggestions.clear();
            HapticFeedback.lightImpact();
          } else {
            if (isReserved) {
              _usernameError = 'This username is reserved by Emora';
            } else {
              _usernameError = 'Username is already taken';
            }
            _isUsernameValid = false;
            _generateUsernameSuggestions(username);
            HapticFeedback.mediumImpact();
          }
        });
        _validateAllInputs();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _usernameError = 'Failed to check username availability';
          _isCheckingUsername = false;
          _isUsernameValid = false;
          _showUsernameSuggestions = false;
        });
      }
    }
  }

  void _generateUsernameSuggestions(String originalUsername) {
    final suggestions = <String>[];
    final random = Random();

    // Method 1: Add numbers
    for (int i = 1; i <= 3; i++) {
      final number = random.nextInt(9999) + 1;
      suggestions.add('$originalUsername$number');
    }

    // Method 2: Add suffixes
    for (int i = 0; i < 2; i++) {
      final suffix = _coolSuffixes[random.nextInt(_coolSuffixes.length)];
      suggestions.add('${originalUsername}_$suffix');
    }

    // Method 3: Add prefixes
    for (int i = 0; i < 2; i++) {
      final prefix = _coolPrefixes[random.nextInt(_coolPrefixes.length)];
      suggestions.add('${prefix}_$originalUsername');
    }

    // Method 4: Variations with underscores and numbers
    suggestions.add('${originalUsername}_${DateTime.now().year}');
    suggestions.add('${originalUsername}_official');
    suggestions.add('${originalUsername}_real');

    // Remove duplicates and limit to 6 suggestions
    final uniqueSuggestions = suggestions.toSet().toList();
    uniqueSuggestions.shuffle();

    setState(() {
      _usernameSuggestions = uniqueSuggestions.take(6).toList();
      _showUsernameSuggestions = true;
    });

    _suggestionAnimationController.forward();
  }

  void _selectSuggestion(String suggestion) {
    _usernameController.text = suggestion;
    setState(() {
      _showUsernameSuggestions = false;
    });
    _suggestionAnimationController.reverse();
    HapticFeedback.lightImpact();
    
    // Auto-check the suggested username
    _debounceUsernameCheck(suggestion);
  }

  bool _isUsernameFormatValid(String username) {
    return username.isNotEmpty &&
        username.length >= 3 &&
        username.length <= 20 &&
        RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username) &&
        !username.startsWith('_') &&
        !username.endsWith('_') &&
        !RegExp(r'^\d+$').hasMatch(username);
  }

  void _validateUsername() {
    final username = _usernameController.text.trim();
    String? error;
    bool isValid = false;

    if (username.isEmpty) {
      error = null;
    } else if (username.length < 3) {
      error = 'Username must be at least 3 characters';
    } else if (username.length > 20) {
      error = 'Username must be less than 20 characters';
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      error = 'Username can only contain letters, numbers, and underscores';
    } else if (username.startsWith('_') || username.endsWith('_')) {
      error = 'Username cannot start or end with underscore';
    } else if (RegExp(r'^\d+$').hasMatch(username)) {
      error = 'Username cannot be only numbers';
    } else {
      isValid = true;
    }

    setState(() {
      _usernameError = error;
      _isUsernameValid = isValid && !_isCheckingUsername;
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    String? error;
    bool isValid = false;

    if (password.isEmpty) {
      error = null;
    } else if (password.length < 8) {
      error = 'Password must be at least 8 characters';
    } else if (!_hasUppercase(password) ||
        !_hasLowercase(password) ||
        !_hasNumber(password) ||
        !_hasSpecialChar(password)) {
      error = 'Password must meet all requirements';
    } else {
      isValid = true;
    }

    setState(() {
      _passwordError = error;
      _isPasswordValid = isValid;
    });
  }

  void _validateConfirmPassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    String? error;
    bool isValid = false;

    if (confirmPassword.isEmpty) {
      error = null;
    } else if (confirmPassword != password) {
      error = 'Passwords do not match';
    } else {
      isValid = true;
    }

    setState(() {
      _confirmPasswordError = error;
      _isConfirmPasswordValid = isValid;
    });
  }

  void _validateAllInputs() {
    final isValid = _isUsernameValid &&
        _isPasswordValid &&
        _isConfirmPasswordValid &&
        !_isCheckingUsername;

    if (isValid) {
      context.read<OnboardingBloc>().add(
        SaveUsername(_usernameController.text.trim()),
      );
    }
  }

  bool _hasUppercase(String password) => RegExp(r'[A-Z]').hasMatch(password);
  bool _hasLowercase(String password) => RegExp(r'[a-z]').hasMatch(password);
  bool _hasNumber(String password) => RegExp(r'\d').hasMatch(password);
  bool _hasSpecialChar(String password) =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildWelcomeText(),
              const SizedBox(height: 24),
              _buildDescriptionText(),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildUsernameField(),
                      // Username suggestions
                      if (_showUsernameSuggestions)
                        _buildUsernameSuggestions(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      const SizedBox(height: 20),
                      _buildConfirmPasswordField(),
                      const SizedBox(height: 24),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: _showPasswordRequirements ? null : 0,
                        child: _buildPasswordRequirements(),
                      ),
                      const SizedBox(height: 40),
                      _buildLoginPrompt(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              _buildCreateAccountButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome to',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF8B5FBF), Color(0xFFB47ED1)],
          ).createShader(bounds),
          child: const Text(
            'Emora!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionText() {
    return Text(
      'Create your account to get started. Choose a unique username and secure password.',
      style: TextStyle(
        color: Colors.grey[400],
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
    );
  }

  Widget _buildUsernameField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _usernameError != null
              ? Colors.red.withOpacity(0.5)
              : _isUsernameValid
                  ? const Color(0xFF8B5FBF).withOpacity(0.5)
                  : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Icon(Icons.person_outline, color: Colors.grey, size: 24),
              ),
              Expanded(
                child: TextField(
                  controller: _usernameController,
                  focusNode: _usernameFocusNode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Choose a unique username...',
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                    border: InputBorder.none,
                  ),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildUsernameStatusIcon(),
              ),
            ],
          ),
          if (_usernameError != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _usernameError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUsernameSuggestions() {
    return FadeTransition(
      opacity: _suggestionAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
        ).animate(_suggestionAnimation),
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF8B5FBF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: const Color(0xFF8B5FBF),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Here are some suggestions:',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _usernameSuggestions.map((suggestion) {
                  return GestureDetector(
                    onTap: () => _selectSuggestion(suggestion),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF8B5FBF).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            suggestion,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.add_circle_outline,
                            color: const Color(0xFF8B5FBF),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameStatusIcon() {
    if (_isCheckingUsername) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5FBF)),
        ),
      );
    } else if (_isUsernameValid) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 20);
    } else if (_usernameError != null) {
      return const Icon(Icons.error, color: Colors.red, size: 20);
    }
    return const SizedBox(width: 20);
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _passwordError != null
              ? Colors.red.withOpacity(0.5)
              : _showPasswordRequirements
                  ? const Color(0xFF8B5FBF).withOpacity(0.5)
                  : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(Icons.lock_outline, color: Colors.grey, size: 24),
          ),
          Expanded(
            child: TextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: _obscurePassword,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Create a secure password...',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                border: InputBorder.none,
                errorText: _passwordError,
                errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
              ),
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
              HapticFeedback.lightImpact();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _confirmPasswordError != null
              ? Colors.red.withOpacity(0.5)
              : _isConfirmPasswordValid
                  ? const Color(0xFF8B5FBF).withOpacity(0.5)
                  : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(Icons.lock_outline, color: Colors.grey, size: 24),
          ),
          Expanded(
            child: TextField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              obscureText: _obscureConfirmPassword,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Confirm your password...',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                border: InputBorder.none,
                errorText: _confirmPasswordError,
                errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (widget.canContinue && widget.onContinue != null) {
                  widget.onContinue!();
                }
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
              HapticFeedback.lightImpact();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.grey,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildRequirementItem(
            'At least 8 characters',
            _passwordController.text.length >= 8,
          ),
          _buildRequirementItem(
            'One uppercase letter',
            _hasUppercase(_passwordController.text),
          ),
          _buildRequirementItem(
            'One lowercase letter',
            _hasLowercase(_passwordController.text),
          ),
          _buildRequirementItem(
            'One number',
            _hasNumber(_passwordController.text),
          ),
          _buildRequirementItem(
            'One special character',
            _hasSpecialChar(_passwordController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isMet ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: isMet ? Colors.green : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // Navigate to login
          },
          child: const Text(
            'Log In',
            style: TextStyle(
              color: Color(0xFF8B5FBF),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF8B5FBF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    final isEnabled = widget.canContinue && !_isCheckingUsername;

    return ScaleTransition(
      scale: _pulseAnimation,
      child: GestureDetector(
        onTap: isEnabled
            ? () {
                HapticFeedback.mediumImpact();
                widget.onContinue?.call();
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? const LinearGradient(
                    colors: [Color(0xFF8B5FBF), Color(0xFFB47ED1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey[700]!, Colors.grey[600]!],
                  ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF8B5FBF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create Account',
                style: TextStyle(
                  color: isEnabled ? Colors.white : Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                color: isEnabled ? Colors.white : Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}