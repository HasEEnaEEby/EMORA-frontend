// lib/features/auth/presentation/view/register_view.dart - COMPLETE FIXED VERSION
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/logger.dart';
import '../view_model/bloc/auth_bloc.dart';
import '../view_model/bloc/auth_event.dart';
import '../view_model/bloc/auth_state.dart';

class RegisterView extends StatefulWidget {
  final Map<String, dynamic>? onboardingData;

  const RegisterView({super.key, this.onboardingData});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController(); // ✅ EMAIL FIELD
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isUsernameAvailable = false;
  bool _isCheckingUsername = false;
  Timer? _usernameDebounceTimer;

  // Location data
  String? _currentLocation;
  double? _currentLatitude;
  double? _currentLongitude;
  bool _isLoadingLocation = true;
  bool _locationPermissionDenied = false;

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // ✅ FIXED: Only use onboarding data if user actually completed onboarding
  String? get _onboardingPronouns => (widget.onboardingData != null && widget.onboardingData!['isCompleted'] == true) ? widget.onboardingData!['pronouns'] : null;
  String? get _onboardingAgeGroup => (widget.onboardingData != null && widget.onboardingData!['isCompleted'] == true) ? widget.onboardingData!['ageGroup'] : null;
  String? get _onboardingAvatar => (widget.onboardingData != null && widget.onboardingData!['isCompleted'] == true) ? widget.onboardingData!['selectedAvatar'] : null;

  String _normalizeUsername(String username) {
    return username.toLowerCase().trim();
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _logOnboardingData();
    _initializeLocation();
    _usernameController.addListener(_onUsernameChanged);

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _usernameController.dispose();
    _emailController.dispose(); // ✅ DISPOSE EMAIL CONTROLLER
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameDebounceTimer?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  void _logOnboardingData() {
    Logger.info('🔍 RegisterView initialized with onboarding data:');
    Logger.info('  Full data: ${widget.onboardingData}');
    Logger.info('  Is completed: ${widget.onboardingData?['isCompleted']}');
    Logger.info('  Pronouns: $_onboardingPronouns');
    Logger.info('  Age Group: $_onboardingAgeGroup');
    Logger.info('  Avatar: $_onboardingAvatar');

    if (widget.onboardingData == null || widget.onboardingData?['isCompleted'] != true) {
      Logger.info('ℹ️ No completed onboarding data - user skipped onboarding');
    }
  }

  // ✅ FIXED: Only return values if onboarding was actually completed
  Future<Map<String, String?>> _getFinalOnboardingValues() async {
    // If user skipped onboarding, return null values
    if (widget.onboardingData?['isCompleted'] != true) {
      Logger.info('📝 User skipped onboarding - using null values');
      return {
        'pronouns': null,
        'ageGroup': null,
        'selectedAvatar': null,
      };
    }

    String? pronounsToUse = _onboardingPronouns;
    String? ageGroupToUse = _onboardingAgeGroup;
    String? avatarToUse = _onboardingAvatar;

    // Try SharedPreferences fallback only if onboarding was completed
    if (pronounsToUse == null || ageGroupToUse == null || avatarToUse == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final isCompleted = prefs.getBool('onboarding_completed') ?? false;
        
        if (isCompleted) {
          pronounsToUse ??= prefs.getString('onboarding_pronouns');
          ageGroupToUse ??= prefs.getString('onboarding_age_group');
          avatarToUse ??= prefs.getString('onboarding_avatar');
        }
      } catch (e) {
        Logger.error('SharedPreferences fallback failed', e);
      }
    }

    return {
      'pronouns': pronounsToUse,
      'ageGroup': ageGroupToUse,
      'selectedAvatar': avatarToUse,
    };
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationPermissionDenied = false;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Logger.info('📍 Location services are disabled');
        _setDefaultLocation();
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Logger.info('📍 Location permissions denied');
          _handleLocationPermissionDenied();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Logger.info('📍 Location permissions permanently denied');
        _handleLocationPermissionDenied();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Get address from coordinates
      await _getAddressFromCoordinates(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _currentLatitude = position.latitude;
          _currentLongitude = position.longitude;
          _isLoadingLocation = false;
        });
      }

      Logger.info('📍 Location detected: $_currentLocation');
      Logger.info(
        '📍 Coordinates: ${position.latitude}, ${position.longitude}',
      );
    } catch (e) {
      Logger.error('Failed to get location', e);
      _setDefaultLocation();
    }
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';

        if (place.locality != null && place.locality!.isNotEmpty) {
          address += place.locality!;
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }
        if (place.country != null && place.country!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.country!;
        }

        if (mounted) {
          setState(() {
            _currentLocation = address.isNotEmpty
                ? address
                : 'Unknown Location';
          });
        }
      }
    } catch (e) {
      Logger.error('Failed to get address from coordinates', e);
      if (mounted) {
        setState(() {
          _currentLocation = 'Unknown Location';
        });
      }
    }
  }

  void _handleLocationPermissionDenied() {
    if (mounted) {
      setState(() {
        _locationPermissionDenied = true;
        _isLoadingLocation = false;
      });
    }
    _setDefaultLocation();
  }

  void _setDefaultLocation() {
    if (mounted) {
      setState(() {
        _currentLocation = 'Location not available';
        _currentLatitude = null;
        _currentLongitude = null;
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _retryLocationPermission() async {
    await _initializeLocation();
  }

  void _onUsernameChanged() {
    final originalText = _usernameController.text;
    final normalizedText = _normalizeUsername(originalText);

    // If the text is different from normalized, update the controller
    if (originalText != normalizedText && originalText.isNotEmpty) {
      _usernameController.value = _usernameController.value.copyWith(
        text: normalizedText,
        selection: TextSelection.collapsed(offset: normalizedText.length),
      );
      return; // Exit early to avoid double processing
    }

    _usernameDebounceTimer?.cancel();

    setState(() {
      _isUsernameAvailable = false;
      _isCheckingUsername = false;
    });

    if (normalizedText.length >= 3) {
      setState(() {
        _isCheckingUsername = true;
      });

      _usernameDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.read<AuthBloc>().add(
            CheckUsernameAvailabilityEvent(normalizedText),
          );
        }
      });
    }
  }

  // ✅ ENHANCED PASSWORD VALIDATION - Matches backend exactly
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (value.length > 128) {
      return 'Password must be less than 128 characters';
    }

    // Check for uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for special character
    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character (!@#\$%^&*)';
    }

    return null;
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate() || !_isUsernameAvailable) {
      return;
    }

    if (!mounted) return;

    final normalizedUsername = _normalizeUsername(_usernameController.text);
    final finalValues = await _getFinalOnboardingValues();

    Logger.info('🔄 Starting registration with data:');
    Logger.info('  Username: $normalizedUsername (normalized)');
    Logger.info('  Email: ${_emailController.text.trim()}'); // ✅ LOG EMAIL
    Logger.info('  Pronouns: ${finalValues['pronouns'] ?? 'null'}');
    Logger.info('  Age Group: ${finalValues['ageGroup'] ?? 'null'}');
    Logger.info('  Avatar: ${finalValues['selectedAvatar'] ?? 'null'}');
    Logger.info('  Location: $_currentLocation');
    Logger.info('  Coordinates: $_currentLatitude, $_currentLongitude');

    final authBloc = context.read<AuthBloc>();

    authBloc.add(
      RegisterUserEvent(
        normalizedUsername,
        _passwordController.text,
        finalValues['pronouns'], // ✅ CAN BE NULL
        finalValues['ageGroup'], // ✅ CAN BE NULL
        finalValues['selectedAvatar'], // ✅ CAN BE NULL
        _currentLocation,
        _currentLatitude,
        _currentLongitude,
        _emailController.text.trim(), // ✅ PASS EMAIL
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUsernameCheckResult) {
              setState(() {
                _isCheckingUsername = false;
                _isUsernameAvailable = state.isAvailable;
              });
            } else if (state is AuthUsernameChecking) {
              setState(() {
                _isCheckingUsername = true;
              });
            } else if (state is AuthAuthenticated) {
              Logger.info('✅ Registration successful, navigating to home');
              Navigator.pushReplacementNamed(context, AppRouter.home);
            } else if (state is AuthError) {
              _showErrorSnackBar(state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildBackButton(),
                      const SizedBox(height: 40),
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildLocationCard(),
                      const SizedBox(height: 24),
                      _buildOnboardingDataPreview(),
                      const SizedBox(height: 24),
                      _buildRegistrationForm(isLoading),
                      const SizedBox(height: 32),
                      _buildRegisterButton(isLoading),
                      const SizedBox(height: 24),
                      _buildSignInLink(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFD8A5FF)],
              ).createShader(bounds),
              child: const Text(
                'Emora',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'Create your',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          ).createShader(bounds),
          child: const Text(
            'digital identity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Join the global emotional community and start your journey',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1B4B).withValues(alpha: 0.6),
            const Color(0xFF312E81).withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _locationPermissionDenied
                      ? Icons.location_off
                      : Icons.location_on,
                  color: _locationPermissionDenied
                      ? Colors.orange
                      : const Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Location',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_isLoadingLocation)
                      Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF8B5CF6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Detecting location...',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        _currentLocation ?? 'Location not available',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              if (_locationPermissionDenied)
                TextButton(
                  onPressed: _retryLocationPermission,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    backgroundColor: const Color(
                      0xFF8B5CF6,
                    ).withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (_locationPermissionDenied) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Location helps connect you with nearby users and relevant content',
                      style: TextStyle(color: Colors.orange[200], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ FIXED: Only show onboarding data if actually completed
  Widget _buildOnboardingDataPreview() {
    // Don't show if no onboarding data or if user skipped onboarding
    if (widget.onboardingData == null || 
        widget.onboardingData?['isCompleted'] != true ||
        (_onboardingPronouns == null && _onboardingAgeGroup == null && _onboardingAvatar == null)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF134E4A).withValues(alpha: 0.6),
            const Color(0xFF065F46).withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Your Preferences',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_onboardingPronouns != null)
            _buildPreviewItem('Pronouns', _onboardingPronouns!, Icons.person),
          if (_onboardingAgeGroup != null) ...[
            const SizedBox(height: 8),
            _buildPreviewItem('Age Group', _onboardingAgeGroup!, Icons.cake),
          ],
          if (_onboardingAvatar != null) ...[
            const SizedBox(height: 8),
            _buildPreviewItem('Avatar', _onboardingAvatar!, Icons.emoji_emotions),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[400], size: 16),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildUsernameField(isLoading),
          const SizedBox(height: 20),
          _buildEmailField(isLoading), // ✅ EMAIL FIELD ADDED HERE
          const SizedBox(height: 20),
          _buildPasswordField(isLoading),
          const SizedBox(height: 20),
          _buildConfirmPasswordField(isLoading),
        ],
      ),
    );
  }

  Widget _buildUsernameField(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _usernameController,
          enabled: !isLoading,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Username',
            labelStyle: TextStyle(color: Colors.grey[400]),
            hintText: 'Choose a unique username',
            hintStyle: TextStyle(color: Colors.grey[600]),
            helperText: 'Usernames are automatically converted to lowercase',
            helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
            prefixIcon: Icon(Icons.alternate_email, color: Colors.grey[400]),
            suffixIcon: _buildUsernameValidationIcon(),
            filled: true,
            fillColor: const Color(0xFF1F2937).withValues(alpha: 0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Username is required';
            }
            final normalized = _normalizeUsername(value);
            if (normalized.length < 3) {
              return 'Username must be at least 3 characters';
            }
            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(normalized)) {
              return 'Username can only contain letters, numbers, and underscores';
            }
            if (!_isUsernameAvailable && !_isCheckingUsername) {
              return 'Username is not available';
            }
            return null;
          },
        ),
        if (_isCheckingUsername)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF8B5CF6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Checking availability...',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget? _buildUsernameValidationIcon() {
    if (_isCheckingUsername) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
          ),
        ),
      );
    }

    if (_usernameController.text.trim().length >= 3) {
      return Icon(
        _isUsernameAvailable ? Icons.check_circle : Icons.cancel,
        color: _isUsernameAvailable ? const Color(0xFF10B981) : Colors.red,
      );
    }

    return null;
  }

  // ✅ EMAIL FIELD IMPLEMENTATION
  Widget _buildEmailField(bool isLoading) {
    return TextFormField(
      controller: _emailController,
      enabled: !isLoading,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email Address *',
        labelStyle: TextStyle(color: Colors.grey[400]),
        hintText: 'Enter your email address',
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFF1F2937).withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email address is required';
        }
        
        // Enhanced email validation
        final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Please enter a valid email address';
        }
        
        return null;
      },
    );
  }

  Widget _buildPasswordField(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _passwordController,
          enabled: !isLoading,
          obscureText: !_isPasswordVisible,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Password *',
            labelStyle: TextStyle(color: Colors.grey[400]),
            hintText: 'Create a secure password',
            hintStyle: TextStyle(color: Colors.grey[600]),
            helperText: 'Min 8 chars, uppercase, lowercase, number, special char',
            helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[400],
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            filled: true,
            fillColor: const Color(0xFF1F2937).withValues(alpha: 0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: _validatePassword,
          onChanged: (_) => setState(() {}), // Trigger rebuild for indicators
        ),
        const SizedBox(height: 8),
        // Password strength indicators
        _buildPasswordStrengthIndicators(),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicators() {
    final password = _passwordController.text;
    
    return Column(
      children: [
        _buildStrengthIndicator('At least 8 characters', password.length >= 8),
        _buildStrengthIndicator('Uppercase letter (A-Z)', password.contains(RegExp(r'[A-Z]'))),
        _buildStrengthIndicator('Lowercase letter (a-z)', password.contains(RegExp(r'[a-z]'))),
        _buildStrengthIndicator('Number (0-9)', password.contains(RegExp(r'[0-9]'))),
        _buildStrengthIndicator('Special character (!@#\$%^&*)', password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))),
      ],
    );
  }

  Widget _buildStrengthIndicator(String requirement, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? const Color(0xFF10B981) : Colors.grey[500],
          ),
          const SizedBox(width: 8),
          Text(
            requirement,
            style: TextStyle(
              color: isMet ? const Color(0xFF10B981) : Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordField(bool isLoading) {
    return TextFormField(
      controller: _confirmPasswordController,
      enabled: !isLoading,
      obscureText: !_isConfirmPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Confirm Password *',
        labelStyle: TextStyle(color: Colors.grey[400]),
        hintText: 'Re-enter your password',
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.lock, color: Colors.grey[400]),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[400],
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
        filled: true,
        fillColor: const Color(0xFF1F2937).withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton(bool isLoading) {
    final canRegister = _isUsernameAvailable && !isLoading;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: canRegister
            ? [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: canRegister ? _handleRegistration : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canRegister
              ? const Color(0xFF8B5CF6)
              : Colors.grey.withValues(alpha: 0.3),
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Creating Account...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.rocket_launch, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Create Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRouter.login);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
              children: [
                const TextSpan(text: 'Already have an account? '),
                TextSpan(
                  text: 'Sign In',
                  style: TextStyle(
                    color: const Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Registration Failed',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}