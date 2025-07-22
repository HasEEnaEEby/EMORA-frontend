import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entity/onboarding_entity.dart';
import '../view_model/bloc/onboarding_bloc.dart';
import '../view_model/bloc/onboarding_event.dart';
import '../view_model/bloc/onboarding_state.dart';
import '../widget/onboarding_progress_bar.dart';
import 'pages/age_page.dart';
import 'pages/avatar_page.dart';
import 'pages/pronouns_page.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _currentPageIndex = 0;
  bool _isAnimating = false;
  int _retryCount = 0;
  static const int maxRetries = 3;
  bool _hasNavigated = false;

  // Store onboarding data to pass to auth
  Map<String, dynamic> _collectedData = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Logger.info('🔄 Initializing OnboardingView - Loading steps');
        context.read<OnboardingBloc>().add(LoadOnboardingSteps());
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _animateToPage(int pageIndex) {
    if (!mounted ||
        _isAnimating ||
        !_pageController.hasClients ||
        pageIndex == _currentPageIndex) {
      return;
    }

    setState(() {
      _isAnimating = true;
      _currentPageIndex = pageIndex;
    });

    _pageController
        .animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        )
        .then((_) {
          if (mounted) {
            setState(() {
              _isAnimating = false;
            });
          }
        })
        .catchError((error) {
          Logger.error('Page animation error', error);
          if (mounted) {
            setState(() {
              _isAnimating = false;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090110),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: BlocConsumer<OnboardingBloc, OnboardingState>(
            listener: (context, state) {
              Logger.info(
                '🔄 OnboardingBloc state changed: ${state.runtimeType}',
              );

              if (state is OnboardingStepsLoaded) {
                _retryCount = 0;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    int actualStepIndex = _mapToDisplayIndex(
                      state.currentStepIndex,
                      state.steps,
                    );
                    _animateToPage(actualStepIndex);
                    _updateCollectedData(state.userData);
                  }
                });
              } else if (state is OnboardingCompleted) {
                _handleOnboardingCompletion(state.userData);
              } else if (state is OnboardingError) {
                _handleOnboardingError(state.message);
              }
            },
            builder: (context, state) {
              Logger.info(
                '🏗️ Building OnboardingView with state: ${state.runtimeType}',
              );

              // Handle all possible states explicitly
              if (state is OnboardingLoading) {
                return _buildLoadingView();
              }

              if (state is OnboardingDataSaving) {
                return _buildSavingView();
              }

              if (state is OnboardingStepsLoaded) {
                return _buildOnboardingContent(state);
              }

              if (state is OnboardingCompleted) {
                // Show completion state while navigation is happening
                return _buildCompletionView();
              }

              if (state is OnboardingError) {
                return _buildErrorView(state.message);
              }

              // Handle initial state or any other unexpected states
              if (state is OnboardingInitial) {
                return _buildInitialView();
              }

              // Last resort fallback with more detailed error info
              Logger.error(
                '. Unexpected OnboardingBloc state: ${state.runtimeType}',
                'Unhandled state',
              );
              return _buildErrorView('Unexpected state: ${state.runtimeType}');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5FBF)),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          const Text(
            'Starting setup...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Logger.info('🔄 Manual retry from initial state');
              context.read<OnboardingBloc>().add(LoadOnboardingSteps());
            },
            child: const Text(
              'Tap to start',
              style: TextStyle(color: Color(0xFF8B5FBF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionView() {
    // Immediately navigate to auth choice when completion view would be shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasNavigated) {
        _navigateToAuthChoice();
      }
    });

    // Show a simple loading state while navigating
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5FBF)),
        strokeWidth: 3,
      ),
    );
  }

  void _handleOnboardingError(String message) {
    Logger.error('. Onboarding error: $message', message);

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout')) {
      _retryCount++;

      if (_retryCount <= maxRetries) {
        Future.delayed(Duration(seconds: _retryCount * 2), () {
          if (mounted) {
            Logger.info(
              '🔄 Auto-retrying onboarding load (attempt $_retryCount)',
            );
            context.read<OnboardingBloc>().add(LoadOnboardingSteps());
          }
        });
        return;
      }
    }

    _showErrorSnackBar(message);
  }

  // FIXED: Ensure we capture the ACTUAL onboarding data
  void _updateCollectedData(UserOnboardingEntity userData) {
    _collectedData = {
      'username': userData.username,
      'pronouns': userData.pronouns, // ACTUAL selected pronouns
      'ageGroup': userData.ageGroup, // ACTUAL selected age group
      'selectedAvatar': userData.selectedAvatar, // ACTUAL selected avatar
      'hasCompletedOnboarding': userData.isCompleted,
      'timestamp': DateTime.now().toIso8601String(),
    };

    Logger.info('. Updated collected data with ACTUAL onboarding values:');
    Logger.info('  username: ${userData.username}');
    Logger.info('  pronouns: ${userData.pronouns}');
    Logger.info('  ageGroup: ${userData.ageGroup}');
    Logger.info('  selectedAvatar: ${userData.selectedAvatar}');
    Logger.info('  Full data: $_collectedData');
  }

  Future<void> _handleOnboardingCompletion(
    UserOnboardingEntity userData,
  ) async {
    try {
      Logger.info('. Handling onboarding completion');
      _updateCollectedData(userData);
      await _saveOnboardingData(_collectedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Preferences saved! 🎉'),
              ],
            ),
            backgroundColor: const Color(0xFF8B5FBF),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        // Direct navigation without delay
        _navigateToAuthChoice();
      }
    } catch (e) {
      Logger.error('Error handling onboarding completion', e);
      if (mounted) {
        _showErrorSnackBar('Failed to save preferences');
        // Fallback navigation
        _navigateToAuthChoice();
      }
    }
  }

  // FIXED: Pass the actual collected data to auth choice
  void _navigateToAuthChoice() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    Logger.info('🧭 Attempting navigation to auth choice');
    Logger.info('📦 Onboarding data to pass: $_collectedData');

    try {
      // Primary navigation attempt with proper data passing
      Navigator.of(context).pushReplacementNamed(
        AppRouter.authChoice,
        arguments: _collectedData, // Pass the ACTUAL collected data
      );
      Logger.info('. Primary navigation successful with data');
    } catch (primaryError) {
      Logger.error('. Primary navigation failed', primaryError);

      try {
        // Fallback 1: Use NavigationService
        NavigationService.pushReplacementNamed(
          AppRouter.authChoice,
          arguments: _collectedData,
        );
        Logger.info('. Fallback 1 navigation successful');
      } catch (fallback1Error) {
        Logger.error('. Fallback 1 navigation failed', fallback1Error);

        try {
          // Fallback 2: Navigate to auth wrapper
          Navigator.of(context).pushReplacementNamed(AppRouter.auth);
          Logger.info('. Fallback 2 navigation successful');
        } catch (fallback2Error) {
          Logger.error('. Fallback 2 navigation failed', fallback2Error);
          _showNavigationError();
        }
      }
    }
  }

  void _showNavigationError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Navigation Error',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Unable to navigate automatically. Please choose how to continue:',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _retryNavigation();
              },
              child: const Text('Retry'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _manualNavigation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5FBF),
              ),
              child: const Text('Continue Manually'),
            ),
          ],
        );
      },
    );
  }

  void _retryNavigation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _navigateToAuthChoice();
    });
  }

  void _manualNavigation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Continue Setup',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed(
                    AppRouter.register,
                    arguments: _collectedData, // Pass data here too
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5FBF),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Create Account'),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed(AppRouter.login);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5FBF),
                  side: const BorderSide(color: Color(0xFF8B5FBF)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Sign In'),
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // FIXED: Save onboarding data more reliably
  Future<void> _saveOnboardingData(Map<String, dynamic> data) async {
    try {
      Logger.info('. Saving onboarding data: $data');
      final prefs = await SharedPreferences.getInstance();

      // Save individual fields
      await prefs.setString('onboarding_username', data['username'] ?? '');
      await prefs.setString('onboarding_pronouns', data['pronouns'] ?? '');
      await prefs.setString('onboarding_age_group', data['ageGroup'] ?? '');
      await prefs.setString('onboarding_avatar', data['selectedAvatar'] ?? '');
      await prefs.setBool('onboarding_completed', true);
      await prefs.setString('onboarding_timestamp', data['timestamp'] ?? '');

      // Save complete JSON for easy retrieval
      final jsonString =
          '''
{
  "username": "${data['username'] ?? ''}",
  "pronouns": "${data['pronouns'] ?? ''}",
  "ageGroup": "${data['ageGroup'] ?? ''}",
  "selectedAvatar": "${data['selectedAvatar'] ?? ''}",
  "hasCompletedOnboarding": true,
  "timestamp": "${data['timestamp'] ?? ''}"
}''';

      await prefs.setString('onboarding_data_json', jsonString);

      Logger.info('. Onboarding data saved successfully');
      Logger.info('  Saved pronouns: ${data['pronouns']}');
      Logger.info('  Saved ageGroup: ${data['ageGroup']}');
      Logger.info('  Saved avatar: ${data['selectedAvatar']}');
    } catch (e) {
      Logger.error('. Failed to save onboarding data', e);
      rethrow;
    }
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5FBF)),
            strokeWidth: 3,
          ),
          SizedBox(height: 24),
          Text(
            'Preparing your experience...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5FBF)),
            strokeWidth: 3,
          ),
          SizedBox(height: 24),
          Text(
            'Saving your preferences...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String? errorMessage) {
    final canRetry = _retryCount < maxRetries;
    final isNetworkError =
        errorMessage?.toLowerCase().contains('network') == true ||
        errorMessage?.toLowerCase().contains('connection') == true ||
        errorMessage?.toLowerCase().contains('404') == true ||
        errorMessage?.toLowerCase().contains('timeout') == true;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isNetworkError ? Icons.wifi_off : Icons.error_outline,
            color: isNetworkError ? Colors.orange : Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            isNetworkError ? 'Connection Issue' : 'Something went wrong',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              isNetworkError
                  ? 'Please check your internet connection and try again'
                  : errorMessage ?? 'An unexpected error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (canRetry) ...[
            ElevatedButton(
              onPressed: () {
                _retryCount++;
                Logger.info('🔄 Manual retry (attempt $_retryCount)');
                context.read<OnboardingBloc>().add(LoadOnboardingSteps());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5FBF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                _retryCount > 0 ? 'Retry ($_retryCount/$maxRetries)' : 'Retry',
              ),
            ),
            const SizedBox(height: 12),
          ],
          Column(
            children: [
              TextButton(
                onPressed: () => _navigateToAuthChoice(),
                child: Text(
                  'Continue to account setup',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRouter.home);
                },
                child: Text(
                  'Skip to app',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingContent(OnboardingStepsLoaded state) {
    final displayableSteps = state.steps
        .where(
          (step) =>
              step.type != OnboardingStepType.welcome &&
              step.type != OnboardingStepType.completion,
        )
        .toList();

    if (displayableSteps.isEmpty) {
      Logger.error('. No displayable steps found', 'Empty steps list');
      return _buildErrorView('No onboarding steps available');
    }

    int displayIndex = _mapToDisplayIndex(state.currentStepIndex, state.steps);
    if (displayIndex >= displayableSteps.length) {
      displayIndex = displayableSteps.length - 1;
    }
    if (displayIndex < 0) {
      displayIndex = 0;
    }

    return Column(
      children: [
        _buildAppBar(state),

        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: _buildProgressIndicator(displayIndex, displayableSteps),
        ),

        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayableSteps.length,
            onPageChanged: (index) {
              if (!_isAnimating) {
                _currentPageIndex = index;
              }
            },
            itemBuilder: (context, index) {
              final step = displayableSteps[index];
              return _buildPage(step, state.userData, state);
            },
          ),
        ),
      ],
    );
  }

  int _mapToDisplayIndex(
    int fullStepIndex,
    List<OnboardingStepEntity> allSteps,
  ) {
    if (fullStepIndex < 0 || fullStepIndex >= allSteps.length) return 0;

    final currentStep = allSteps[fullStepIndex];

    switch (currentStep.type) {
      case OnboardingStepType.welcome:
        return 0;
      case OnboardingStepType.pronouns:
        return 0;
      case OnboardingStepType.age:
        return 1;
      case OnboardingStepType.avatar:
        return 2;
      case OnboardingStepType.completion:
        return 2;
    }
  }

  Widget _buildAppBar(OnboardingStepsLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBackButton(state),
          _buildBrandTitle(),
          _buildSkipButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton(OnboardingStepsLoaded state) {
    return SizedBox(
      width: 48,
      height: 48,
      child: AnimatedOpacity(
        opacity: state.canGoPrevious ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: state.canGoPrevious
            ? IconButton(
                onPressed: !_isAnimating
                    ? () => context.read<OnboardingBloc>().add(PreviousStep())
                    : null,
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              )
            : const SizedBox(),
      ),
    );
  }


Widget _buildBrandTitle() {
  return SvgPicture.asset(
    'assets/images/EmoraLogo.svg',
    width: 100, 
    height: 80, 
    fit: BoxFit.contain,
    placeholderBuilder: (context) => SizedBox(
      width: 100,
      height: 80,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF8B5FBF),
        ),
      ),
    ),
  );
}

  Widget _buildSkipButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
      ),
      child: TextButton(
        onPressed: _isAnimating ? null : () => _showSkipConfirmation(),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Skip',
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
    int currentIndex,
    List<OnboardingStepEntity> displayableSteps,
  ) {
    final progressValue = (currentIndex + 1) / displayableSteps.length;

    return OnboardingProgressBar(
      progress: progressValue,
      totalSteps: displayableSteps.length,
      currentStep: currentIndex,
      backgroundColor: const Color(0xFF2A2A3E),
      progressColor: const Color(0xFF8B5FBF),
      height: 6.0,
    );
  }

  Widget _buildPage(
    OnboardingStepEntity step,
    UserOnboardingEntity userData,
    OnboardingStepsLoaded state,
  ) {
    switch (step.type) {
      case OnboardingStepType.pronouns:
        return PronounsPage(
          step: step,
          userData: userData,
          canContinue: true,
          onContinue: () => context.read<OnboardingBloc>().add(NextStep()),
        );
      case OnboardingStepType.age:
        return AgePage(
          step: step,
          userData: userData,
          canContinue: true,
          onContinue: () => context.read<OnboardingBloc>().add(NextStep()),
        );
      case OnboardingStepType.avatar:
        return AvatarPage(
          step: step,
          userData: userData,
          canContinue: true,
          onContinue: () => context.read<OnboardingBloc>().add(NextStep()),
        );
      case OnboardingStepType.welcome:
      case OnboardingStepType.completion:
        // These should never be reached since we filter them out
        return const SizedBox.shrink();
    }
  }

  void _showSkipConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFF8B5FBF).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          title: const Text(
            'Skip Personalization?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'You can always customize your experience later in settings.',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 15,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Continue Setup',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<OnboardingBloc>().add(SkipOnboarding());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5FBF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Skip'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
