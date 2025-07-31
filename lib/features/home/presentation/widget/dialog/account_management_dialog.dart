import 'package:emora_mobile_app/core/utils/dialog_utils.dart';
import 'package:emora_mobile_app/core/services/logout_service.dart';
import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_bloc.dart';
import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_event.dart';
import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountManagementDialog {
  static void showSignOut(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: _buildSignOutTitle(),
        content: _buildSignOutContent(),
        actions: _buildSignOutActions(context, dialogContext),
      ),
    );
  }

  static void showDeleteAccount(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    final TextEditingController confirmController = TextEditingController();
    bool isConfirmEnabled = false;

    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 0,
              ),
            ],
          ),
          child: CupertinoAlertDialog(
            title: _buildDeleteAccountTitle(),
            content: _buildDeleteAccountContent(
              confirmController,
              setState,
              isConfirmEnabled,
            ),
            actions: _buildDeleteAccountActions(
              context,
              dialogContext,
              confirmController,
              isConfirmEnabled,
              onConfirm,
            ),
          ),
        ),
      ),
    );
  }

  static void showPrivacySettings(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E).withValues(alpha: 0.95),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          CupertinoColors.systemBlue,
                          CupertinoColors.systemBlue.withValues(alpha: 0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemBlue.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.lock_shield_fill,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Privacy Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(CupertinoIcons.xmark, color: Colors.grey),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildPrivacyItem(
                      'Profile Visibility',
                      'Public',
                      CupertinoIcons.eye_fill,
                      () => showComingSoon(
                        context,
                        'Profile Visibility Settings',
                      ),
                    ),
                    _buildPrivacyItem(
                      'Data Sharing',
                      'Limited',
                      CupertinoIcons.square_arrow_up_fill,
                      () => showComingSoon(context, 'Data Sharing Settings'),
                    ),
                    _buildPrivacyItem(
                      'Location Tracking',
                      'Enabled',
                      CupertinoIcons.location_fill,
                      () => showComingSoon(context, 'Location Settings'),
                    ),
                    _buildPrivacyItem(
                      'Analytics',
                      'Anonymous',
                      CupertinoIcons.chart_bar_fill,
                      () => showComingSoon(context, 'Analytics Settings'),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: CupertinoButton(
                color: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(15),
                onPressed: () {
                  Navigator.pop(context);
                  showComingSoon(context, 'Advanced Privacy Controls');
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.gear_alt_fill, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Advanced Privacy',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showSupportHelp(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E).withValues(alpha: 0.95),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          CupertinoColors.systemTeal,
                          CupertinoColors.systemTeal.withValues(alpha: 0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemTeal.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.question_circle_fill,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Support & Help',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(CupertinoIcons.xmark, color: Colors.grey),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildSupportItem(
                      'FAQ',
                      'Common questions and answers',
                      CupertinoIcons.book_fill,
                      () => showComingSoon(context, 'FAQ Section'),
                    ),
                    _buildSupportItem(
                      'Contact Support',
                      'Get help from our team',
                      CupertinoIcons.chat_bubble_2_fill,
                      () => showComingSoon(context, 'Support Chat'),
                    ),
                    _buildSupportItem(
                      'User Guide',
                      'Learn how to use Emora',
                      CupertinoIcons.doc_text_fill,
                      () => showComingSoon(context, 'User Guide'),
                    ),
                    _buildSupportItem(
                      'Report Bug',
                      'Help us improve the app',
                      CupertinoIcons.exclamationmark_triangle_fill,
                      () => showComingSoon(context, 'Bug Report'),
                    ),
                    _buildSupportItem(
                      'Feature Request',
                      'Suggest new features',
                      CupertinoIcons.lightbulb_fill,
                      () => showComingSoon(context, 'Feature Request'),
                    ),
                    _buildSupportItem(
                      'Community',
                      'Join our community',
                      CupertinoIcons.person_3_fill,
                      () => showComingSoon(context, 'Community Forum'),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: CupertinoColors.systemRed.withValues(alpha: 0.1),
                border: Border.all(
                  color: CupertinoColors.systemRed.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.heart_fill,
                    color: CupertinoColors.systemRed,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Need immediate help? Contact crisis support services in your area.',
                      style: TextStyle(
                        color: CupertinoColors.systemRed,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showComingSoon(BuildContext context, String feature) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E).withValues(alpha: 0.95),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),

            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -10 * value),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF8B5CF6),
                          const Color(0xFF8B5CF6).withValues(alpha: 0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.rocket_fill,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            _buildComingSoonContent(feature),
            const Spacer(),
            _buildComingSoonActions(context, feature),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  static Widget _buildSignOutTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                CupertinoColors.systemOrange,
                CupertinoColors.systemOrange.withValues(alpha: 0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemOrange.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.square_arrow_left,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  static Widget _buildSignOutContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: CupertinoColors.systemOrange.withValues(alpha: 0.1),
            border: Border.all(
              color: CupertinoColors.systemOrange.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.info_circle,
                color: CupertinoColors.systemOrange,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'You\'ll need to sign back in to access your account',
                  style: TextStyle(
                    color: CupertinoColors.systemOrange,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static List<Widget> _buildSignOutActions(
    BuildContext context,
    BuildContext dialogContext,
  ) {
    return [
      CupertinoDialogAction(
        onPressed: () => Navigator.pop(dialogContext),
        child: const Text('Cancel'),
      ),
      CupertinoDialogAction(
        onPressed: () {
          Navigator.pop(dialogContext);
          _performSignOut(context);
        },
        isDefaultAction: true,
        child: const Text(
          'Sign Out',
          style: TextStyle(
            color: CupertinoColors.systemOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ];
  }

  static void _performSignOut(BuildContext context) {
    LogoutService.performLogout(context);
  }


  static Widget _buildDeleteAccountTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                CupertinoColors.systemRed,
                CupertinoColors.systemRed.withValues(alpha: 0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemRed.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Delete Account',
          style: TextStyle(
            color: CupertinoColors.systemRed,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  static Widget _buildDeleteAccountContent(
    TextEditingController confirmController,
    StateSetter setState,
    bool isConfirmEnabled,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'This action cannot be undone. All your data will be permanently deleted:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                CupertinoColors.systemRed.withValues(alpha: 0.1),
                CupertinoColors.systemRed.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(
              color: CupertinoColors.systemRed.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemRed.withValues(alpha: 0.1),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDeleteItem('🔒 Profile information and settings'),
              _buildDeleteItem('. All emotion logs and history'),
              _buildDeleteItem('🏆 Achievements and progress'),
              _buildDeleteItem('👥 Social connections and shared content'),
              _buildDeleteItem('📈 Analytics and insights data'),
              _buildDeleteItem('⚙️ Account preferences and customizations'),
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'Type "DELETE" to confirm:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemRed,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isConfirmEnabled
                  ? CupertinoColors.systemRed
                  : CupertinoColors.systemGrey,
              width: 2,
            ),
            boxShadow: isConfirmEnabled
                ? [
                    BoxShadow(
                      color: CupertinoColors.systemRed.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: CupertinoTextField(
            controller: confirmController,
            placeholder: 'Type DELETE to confirm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isConfirmEnabled
                  ? CupertinoColors.systemRed
                  : CupertinoColors.label,
            ),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onChanged: (value) {
              setState(() {
                isConfirmEnabled = value.trim().toUpperCase() == 'DELETE';
              });
              if (isConfirmEnabled) {
                HapticFeedback.lightImpact();
              }
            },
          ),
        ),
      ],
    );
  }

  static Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        text,
        style: const TextStyle(
          color: CupertinoColors.systemRed,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static List<Widget> _buildDeleteAccountActions(
    BuildContext context,
    BuildContext dialogContext,
    TextEditingController confirmController,
    bool isConfirmEnabled,
    VoidCallback onConfirm,
  ) {
    return [
      CupertinoDialogAction(
        onPressed: () => Navigator.pop(dialogContext),
        child: const Text('Cancel'),
      ),
      CupertinoDialogAction(
        onPressed: isConfirmEnabled
            ? () {
                Navigator.pop(dialogContext);
                _showFinalDeleteConfirmation(context, onConfirm);
              }
            : null,
        isDestructiveAction: true,
        child: Text(
          'Delete Account',
          style: TextStyle(
            color: isConfirmEnabled
                ? CupertinoColors.systemRed
                : CupertinoColors.inactiveGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ];
  }

  static void _showFinalDeleteConfirmation(
    BuildContext context,
    VoidCallback onConfirm,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 0,
            ),
          ],
        ),
        child: CupertinoAlertDialog(
          title: const Text(
            'Final Confirmation',
            style: TextStyle(
              color: CupertinoColors.systemRed,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                color: CupertinoColors.systemRed,
                size: 50,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your account will be deleted immediately. Are you absolutely sure?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: CupertinoColors.systemRed.withValues(alpha: 0.1),
                ),
                child: const Text(
                  'This action is permanent and cannot be reversed.',
                  style: TextStyle(
                    color: CupertinoColors.systemRed,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Account'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                _performAccountDeletion(context, onConfirm);
              },
              isDestructiveAction: true,
              child: const Text(
                'Delete Forever',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _performAccountDeletion(
    BuildContext context,
    VoidCallback onConfirm,
  ) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(radius: 20),
            const SizedBox(height: 20),
            const Text(
              'Deleting account...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Securely removing your data',
              style: TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context).pop();
        onConfirm();
        HapticFeedback.heavyImpact();

        DialogUtils.showSuccessSnackBar(
          context,
          'Account deleted successfully',
        );
      }
    });
  }


  static Widget _buildComingSoonContent(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$feature is coming soon!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'We\'re working hard to bring you the best emotion tracking experience. Stay tuned for exciting updates!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.bell_fill,
                  color: const Color(0xFF8B5CF6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Get notified when this feature launches',
                    style: TextStyle(
                      color: const Color(0xFF8B5CF6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  static Widget _buildComingSoonActions(BuildContext context, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: CupertinoButton(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Got it!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CupertinoButton(
              color: const Color(0xFF8B5CF6),
              borderRadius: BorderRadius.circular(15),
              onPressed: () {
                Navigator.pop(context);
                DialogUtils.showSuccessSnackBar(
                  context,
                  'You\'ll be notified when $feature is available! 🔔',
                );
                HapticFeedback.lightImpact();
              },
              child: const Text(
                'Notify Me',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  static void showAccountSecurity(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E).withValues(alpha: 0.95),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          CupertinoColors.systemGreen,
                          CupertinoColors.systemGreen.withValues(alpha: 0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGreen.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.shield_fill,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Account Security',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(CupertinoIcons.xmark, color: Colors.grey),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildEnhancedSecurityItem(
                      'Two-Factor Authentication',
                      'Enabled',
                      CupertinoColors.systemGreen,
                      CupertinoIcons.checkmark_shield_fill,
                    ),
                    _buildEnhancedSecurityItem(
                      'Password Strength',
                      'Strong',
                      CupertinoColors.systemGreen,
                      CupertinoIcons.lock_shield_fill,
                    ),
                    _buildEnhancedSecurityItem(
                      'Last Login',
                      '2 hours ago',
                      CupertinoColors.systemBlue,
                      CupertinoIcons.clock_fill,
                    ),
                    _buildEnhancedSecurityItem(
                      'Data Encryption',
                      'Active',
                      CupertinoColors.systemGreen,
                      CupertinoIcons.eye_slash_fill,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: CupertinoButton(
                color: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(15),
                onPressed: () {
                  Navigator.pop(context);
                  showComingSoon(context, 'Advanced Security Settings');
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.gear_alt_fill, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Manage Security',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildEnhancedSecurityItem(
    String label,
    String status,
    Color statusColor,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: statusColor.withValues(alpha: 0.2),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }


  static Widget _buildPrivacyItem(
    String label,
    String status,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16),
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        onPressed: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CupertinoColors.systemBlue.withValues(alpha: 0.2),
              ),
              child: Icon(icon, color: CupertinoColors.systemBlue, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: CupertinoColors.systemBlue.withValues(alpha: 0.2),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemBlue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.chevron_right,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }


  static Widget _buildSupportItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16),
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        onPressed: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CupertinoColors.systemTeal.withValues(alpha: 0.2),
              ),
              child: Icon(icon, color: CupertinoColors.systemTeal, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
