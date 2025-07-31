import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/logger.dart';
import '../view_model/bloc/auth_bloc.dart';
import '../view_model/bloc/auth_event.dart';
import '../view_model/bloc/auth_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
bool _isLoading = false; 

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    if (!mounted) return;

    try {
      final authBloc = context.read<AuthBloc>();
      
      if (authBloc.isClosed) {
        Logger.error('❌ AuthBloc is closed, cannot process login');
        _showErrorSnackBar('Session expired. Please try again.');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      Logger.info('🔐 Starting login process...');
      Logger.info('  Username: ${_usernameController.text.trim()}');

      authBloc.add(
        AuthLogin(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        ),
      );

    } catch (e, stackTrace) {
      Logger.error('❌ Error during login process: $e', e, stackTrace);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Login failed. Please try again.');
      }
    }
  }

  void _navigateToRegister() {
if (_isLoading) return; 
    
    Logger.info('📝 Navigating to registration');
    Navigator.pushReplacementNamed(context, AppRouter.register);
  }

  void _navigateToForgotPassword() {
if (_isLoading) return; 
    Logger.info('🔑 Navigating to forgot password');
    Navigator.pushNamed(context, AppRouter.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090110),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (mounted && _isLoading) {
              setState(() {
                _isLoading = false;
              });
            }

            if (state is AuthLoginSuccess) {
              Logger.info('✅ Login successful, navigating to home');
              if (mounted) {
                Navigator.of(context, rootNavigator: true)
                    .pushReplacementNamed(AppRouter.home);
              }
            } else if (state is AuthAuthenticated) {
              Logger.info('✅ User authenticated, navigating to home');
              if (mounted) {
                Navigator.of(context, rootNavigator: true)
                    .pushReplacementNamed(AppRouter.home);
              }
            } else if (state is AuthError) {
              Logger.error('❌ Login error:', state.message);
              if (mounted) {
                _showErrorSnackBar(state.message);
              }
            }
          },
          builder: (context, state) {
            final isLoading = _isLoading || state is AuthLoading;

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

                      const SizedBox(height: 50),

                      _buildLoginForm(isLoading),

                      const SizedBox(height: 20),

                      _buildRememberMeAndForgotPassword(),

                      const SizedBox(height: 32),

                      _buildLoginButton(isLoading),

                      const SizedBox(height: 24),

                      _buildDivider(),

                      const SizedBox(height: 24),

                      _buildSocialLoginOptions(isLoading),

                      const SizedBox(height: 32),

                      _buildSignUpLink(),

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
    return IconButton(
      onPressed: _isLoading ? null : () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
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
                  colors: [Color(0xFF8B5FBF), Color(0xFF6B3FA0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5FBF).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
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
            const Text(
              'Emora',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'Welcome back',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const Text(
          'to your emotional journey',
          style: TextStyle(
            color: Color(0xFF8B5FBF),
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Sign in to continue exploring your emotions and connect with your community',
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

  Widget _buildLoginForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildUsernameField(isLoading),

          const SizedBox(height: 20),

          _buildPasswordField(isLoading),
        ],
      ),
    );
  }

  Widget _buildUsernameField(bool isLoading) {
    return TextFormField(
      controller: _usernameController,
      enabled: !isLoading,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Username',
        labelStyle: TextStyle(color: Colors.grey[400]),
        hintText: 'Enter your username',
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.person, color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B5FBF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Username is required';
        }
        if (value.trim().length < 3) {
          return 'Username must be at least 3 characters';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(bool isLoading) {
    return TextFormField(
      controller: _passwordController,
      enabled: !isLoading,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.grey[400]),
        hintText: 'Enter your password',
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.lock, color: Colors.grey[400]),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[400],
          ),
          onPressed: isLoading ? null : () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        filled: true,
        fillColor: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B5FBF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: Checkbox(
                value: _rememberMe,
                onChanged: _isLoading ? null : (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: const Color(0xFF8B5FBF),
                checkColor: Colors.white,
                side: BorderSide(color: Colors.grey[600]!),
              ),
            ),
            Text(
              'Remember me',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),

        TextButton(
          onPressed: _isLoading ? null : _navigateToForgotPassword,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              color: Color(0xFF8B5FBF),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: !isLoading
            ? const LinearGradient(
                colors: [Color(0xFF8B5FBF), Color(0xFF6B3FA0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isLoading ? Colors.grey.withValues(alpha: 0.3) : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: !isLoading
            ? [
                BoxShadow(
                  color: const Color(0xFF8B5FBF).withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: !isLoading ? _handleLogin : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginOptions(bool isLoading) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: TextButton(
        onPressed: _isLoading ? null : _navigateToRegister,
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
            children: [
              const TextSpan(text: "Don't have an account? "),
              const TextSpan(
                text: 'Sign Up',
                style: TextStyle(
                  color: Color(0xFF8B5FBF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}