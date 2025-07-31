import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isUsernameAvailable = false;
  bool _isCheckingUsername = false;
  Timer? _usernameDebounceTimer;

  String? _currentLocation;
  double? _currentLatitude;
  double? _currentLongitude;
  bool _isLoadingLocation = true;
  bool _locationPermissionDenied = false;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _errorController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _errorSlideAnimation;
  late Animation<double> _errorFadeAnimation;

  String? _currentError;
  String? _errorCode;
  bool _showError = false;
  Timer? _errorTimer;

  String? _pronouns;
  String? _ageGroup;
  String? _selectedAvatar;
  bool _hasCompletedOnboarding = false;

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

    _slideController.forward();
    _fadeController.forward();
  }

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (!_hasCompletedOnboarding) {
    _extractOnboardingData();
  }
}

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _errorController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameDebounceTimer?.cancel();
    _errorTimer?.cancel();
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

    _errorController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    _errorSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _errorController, curve: Curves.easeOutBack),
        );

    _errorFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _errorController, curve: Curves.easeOut));
  }

  void _showErrorMessage(String message, String? errorCode) {
    _errorTimer?.cancel();

    setState(() {
      _currentError = message;
      _errorCode = errorCode;
      _showError = true;
    });

    _errorController.forward();

    _errorTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        _hideErrorMessage();
      }
    });
  }

  void _hideErrorMessage() {
    _errorTimer?.cancel();
    _errorController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showError = false;
          _currentError = null;
          _errorCode = null;
        });
      }
    });
  }

  String _getUserFriendlyErrorMessage(String message, String? errorCode) {
    switch (errorCode) {
      case 'EMAIL_EXISTS':
        return 'This email address is already registered. Please try logging in instead or use a different email.';
      case 'USERNAME_EXISTS':
        return 'This username is already taken. Please choose a different username.';
      case 'INVALID_EMAIL':
        return 'Please enter a valid email address.';
      case 'WEAK_PASSWORD':
        return 'Password does not meet security requirements. Please use a stronger password.';
      case 'NETWORK_ERROR':
        return 'Network connection failed. Please check your internet connection and try again.';
      case 'SERVER_ERROR':
        return 'Our servers are experiencing issues. Please try again in a few moments.';
      case 'VALIDATION_ERROR':
        return message.isNotEmpty
            ? message
            : 'Please check your input and try again.';
      default:
        return message.isNotEmpty
            ? message
            : 'Registration failed. Please try again.';
    }
  }

  String _getErrorActionText(String? errorCode) {
    switch (errorCode) {
      case 'EMAIL_EXISTS':
        return 'Go to Login';
      case 'USERNAME_EXISTS':
        return 'Try Another Username';
      case 'NETWORK_ERROR':
        return 'Retry';
      default:
        return 'Try Again';
    }
  }

  void _handleErrorAction(String? errorCode) {
    switch (errorCode) {
      case 'EMAIL_EXISTS':
        Navigator.pushReplacementNamed(context, AppRouter.login);
        break;
      case 'USERNAME_EXISTS':
        _usernameController.clear();
        setState(() {
          _isUsernameAvailable = false;
        });
        _hideErrorMessage();
        break;
      case 'NETWORK_ERROR':
        _hideErrorMessage();
        break;
      default:
        _hideErrorMessage();
        break;
    }
  }

  Widget _buildErrorBanner() {
    if (!_showError || _currentError == null) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _errorSlideAnimation,
      child: FadeTransition(
        opacity: _errorFadeAnimation,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFDC2626).withValues(alpha: 0.15),
                const Color(0xFFB91C1C).withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFDC2626).withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDC2626).withValues(alpha: 0.2),
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
                      color: const Color(0xFFDC2626).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Registration Failed',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getUserFriendlyErrorMessage(
                            _currentError!,
                            _errorCode,
                          ),
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _hideErrorMessage,
                    icon: Icon(Icons.close, color: Colors.grey[400], size: 20),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleErrorAction(_errorCode),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _getErrorActionText(_errorCode),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  if (_errorCode == 'EMAIL_EXISTS') ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _emailController.clear();
                          _hideErrorMessage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Try Different Email',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

void _extractOnboardingData() {
  Map<String, dynamic>? data;

  if (widget.onboardingData != null) {
    data = widget.onboardingData;
  }

  if (data == null && mounted) {
    try {
      final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (routeArgs != null) {
        data = routeArgs;
      }
    } catch (e) {
      Logger.warning('. Could not access route arguments: $e');
      data = null;
    }
  }

  if (data != null) {
    _hasCompletedOnboarding =
        data['hasCompletedOnboarding'] == true || data['isCompleted'] == true;

    if (_hasCompletedOnboarding) {
      _pronouns = data['pronouns'] as String?;
      _ageGroup = data['ageGroup'] as String?;
      _selectedAvatar = data['selectedAvatar'] as String?;
    } else {
      _pronouns = null;
      _ageGroup = null;
      _selectedAvatar = null;
    }
  } else {
    _hasCompletedOnboarding = false;
    _pronouns = null;
    _ageGroup = null;
    _selectedAvatar = null;
  }
}

  void _logOnboardingData() {
    Logger.info('. RegisterView onboarding data:');
    Logger.info('  Has completed: $_hasCompletedOnboarding');
    Logger.info(
      '  Pronouns: $_pronouns | Age: $_ageGroup | Avatar: $_selectedAvatar',
    );

    if (!_hasCompletedOnboarding) {
      Logger.info('ℹ️ No completed onboarding data found');
    }
  }

  Map<String, String?> _getFinalOnboardingValues() {
    if (!_hasCompletedOnboarding) {
      Logger.info('📝 User did not complete onboarding - using null values');
      return {'pronouns': null, 'ageGroup': null, 'selectedAvatar': null};
    }

    Logger.info('📝 Using onboarding values from completed flow');
    return {
      'pronouns': _pronouns,
      'ageGroup': _ageGroup,
      'selectedAvatar': _selectedAvatar,
    };
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationPermissionDenied = false;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setDefaultLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _handleLocationPermissionDenied();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _handleLocationPermissionDenied();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      await _getAddressFromCoordinates(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _currentLatitude = position.latitude;
          _currentLongitude = position.longitude;
          _isLoadingLocation = false;
        });
      }

      Logger.info('📍 Location detected: $_currentLocation');
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

    if (originalText != normalizedText && originalText.isNotEmpty) {
      _usernameController.value = _usernameController.value.copyWith(
        text: normalizedText,
        selection: TextSelection.collapsed(offset: normalizedText.length),
      );
return; 
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
          context.read<AuthBloc>().add(AuthCheckUsername(normalizedText));
        }
      });
    }
  }

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

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  void _handleRegistration() async {
    if (_showError) {
      _hideErrorMessage();
    }

    if (!_formKey.currentState!.validate() || !_isUsernameAvailable) {
      return;
    }

    if (!mounted) return;

    final normalizedUsername = _normalizeUsername(_usernameController.text);
    final finalValues = _getFinalOnboardingValues();

    Logger.info('🔄 Starting registration:');
    Logger.info('  Username: $normalizedUsername');
    Logger.info('  Email: ${_emailController.text.trim()}');
    Logger.info('  Onboarding data: ${finalValues.toString()}');

    final authBloc = context.read<AuthBloc>();

    authBloc.add(
      AuthRegister(
        username: normalizedUsername,
        password: _passwordController.text,
confirmPassword: _confirmPasswordController.text, 
        email: _emailController.text.trim(),
        pronouns: finalValues['pronouns'],
        ageGroup: finalValues['ageGroup'],
        selectedAvatar: finalValues['selectedAvatar'],
        location: _currentLocation,
        latitude: _currentLatitude,
        longitude: _currentLongitude,
        termsAccepted: true,
        privacyAccepted: true,
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
            if (state is AuthUsernameChecked) {
              setState(() {
                _isCheckingUsername = false;
                _isUsernameAvailable = state.isAvailable;
              });
            } else if (state is AuthCheckingUsername) {
              setState(() {
                _isCheckingUsername = true;
              });
            } else if (state is AuthRegistrationSuccess) {
              Logger.info('. Registration successful, navigating to home');
              Navigator.pushReplacementNamed(context, AppRouter.home);
            } else if (state is AuthError) {
              _showErrorMessage(state.message, state.errorCode);
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
                      _buildErrorBanner(),
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

  Widget _buildOnboardingDataPreview() {
    if (!_hasCompletedOnboarding ||
        (_pronouns == null && _ageGroup == null && _selectedAvatar == null)) {
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
                'Your Preferences from Onboarding',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_pronouns != null)
            _buildPreviewItem('Pronouns', _pronouns!, Icons.person),
          if (_ageGroup != null) ...[
            const SizedBox(height: 8),
            _buildPreviewItem('Age Group', _ageGroup!, Icons.cake),
          ],
          if (_selectedAvatar != null) ...[
            const SizedBox(height: 8),
            _buildPreviewItem('Avatar', _selectedAvatar!, Icons.emoji_emotions),
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
          _buildEmailField(isLoading),
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
            if (RegExp(r'!@#\$%^&*(),.?":{}|<>]').hasMatch(normalized)) {
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

        final emailRegex = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
        );
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
            helperText:
                'Min 8 chars, uppercase, lowercase, number, special char',
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
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        _buildPasswordStrengthIndicators(),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicators() {
    final password = _passwordController.text;

    return Column(
      children: [
        _buildStrengthIndicator('At least 8 characters', password.length >= 8),
        _buildStrengthIndicator(
          'Uppercase letter (A-Z)',
          password.contains(RegExp(r'[A-Z]')),
        ),
        _buildStrengthIndicator(
          'Lowercase letter (a-z)',
          password.contains(RegExp(r'[a-z]')),
        ),
        _buildStrengthIndicator(
          'Number (0-9)',
          password.contains(RegExp(r'[0-9]')),
        ),
        _buildStrengthIndicator(
          'Special character (!@#\$%^&*)',
          password.contains(RegExp(r'!@#\$%^&*(),.?":{}|<>]')),
        ),
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
}
