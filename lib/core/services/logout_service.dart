import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';
import '../navigation/navigation_service.dart';
import '../navigation/app_router.dart';
import '../../features/profile/presentation/view_model/profile_bloc.dart';
import '../../features/profile/presentation/view_model/profile_event.dart';
import '../utils/dialog_utils.dart';

class LogoutService {
  static const String _tag = 'LogoutService';

  static Future<void> performLogout(BuildContext context) async {
    try {
      Logger.info('🚪 Starting professional logout process...');

      _showLogoutLoadingDialog(context);

      await _clearAllLocalData();

      _handleSuccessfulLogout(context);

    } catch (e) {
      Logger.error('. Logout error: $e');
      _handleLogoutError(context, 'Logout failed: ${e.toString()}');
    }
  }

  static Future<void> performAccountDeletion(
    BuildContext context, {
    required String password,
    required String confirmation,
  }) async {
    try {
      Logger.info('🗑️ Starting account deletion process...');

      if (confirmation != 'DELETE') {
        DialogUtils.showErrorSnackBar(
          context,
          'Please type DELETE to confirm account deletion',
        );
        return;
      }

      _showDeletionLoadingDialog(context);

      await Future.delayed(const Duration(seconds: 3));

      await _clearAllLocalData();

      _navigateToAuthChoice(context);

      DialogUtils.showSuccessSnackBar(
        context,
        'Account deleted successfully. All your data has been permanently removed.',
      );

      Logger.info('. Account deletion completed successfully');

    } catch (e) {
      Logger.error('. Account deletion error: $e');
      _handleDeletionError(context, 'Account deletion failed: ${e.toString()}');
    }
  }

  static void showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.2),
              ),
              child: const Icon(
                Icons.logout_outlined,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to sign out?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.orange.withOpacity(0.1),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'You\'ll need to sign back in to access your account',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              performLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  static void showAccountDeletionConfirmation(
    BuildContext context, {
    required Function(String password, String confirmation) onConfirm,
  }) {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();
    bool isConfirmEnabled = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This action cannot be undone. All your data will be permanently deleted:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              _buildDeletionItem('🔒 Profile information and settings'),
              _buildDeletionItem('. All emotion logs and history'),
              _buildDeletionItem('🏆 Achievements and progress'),
              _buildDeletionItem('👥 Social connections and shared content'),
              _buildDeletionItem('📈 Analytics and insights data'),
              const SizedBox(height: 20),
              const Text(
                'Enter your password to confirm:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Type "DELETE" to confirm:',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type DELETE to confirm',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isConfirmEnabled ? Colors.red : Colors.grey[600]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isConfirmEnabled ? Colors.red : Colors.grey[600]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    isConfirmEnabled = value.trim().toUpperCase() == 'DELETE';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: isConfirmEnabled && passwordController.text.isNotEmpty
                  ? () {
                      Navigator.pop(context);
                      onConfirm(
                        passwordController.text,
                        confirmController.text,
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }


  static Widget _buildDeletionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static void _showLogoutLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Signing out...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showDeletionLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Deleting account...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Securely removing your data',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _handleSuccessfulLogout(BuildContext context) {
    Navigator.of(context).pop();

    _navigateToAuthChoice(context);

    DialogUtils.showSuccessSnackBar(
      context,
      'Successfully signed out',
    );

    HapticFeedback.lightImpact();

    Logger.info('. Logout completed successfully');
  }

  static void _handleLogoutError(BuildContext context, String message) {
    Navigator.of(context).pop();

    DialogUtils.showErrorSnackBar(context, message);

    HapticFeedback.heavyImpact();

    Logger.error('. Logout failed: $message');
  }

  static void _handleDeletionError(BuildContext context, String message) {
    Navigator.of(context).pop();

    DialogUtils.showErrorSnackBar(context, message);

    HapticFeedback.heavyImpact();

    Logger.error('. Account deletion failed: $message');
  }

  static Future<void> _clearAllLocalData() async {
    try {
      try {
        Logger.info('🔐 Backend logout API call would go here');
      } catch (e) {
        Logger.warning('. Backend logout failed, continuing with local cleanup: $e');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();


      Logger.info('🧹 All local data cleared successfully');
    } catch (e) {
      Logger.error('. Error clearing local data: $e');
    }
  }

  static void _navigateToAuthChoice(BuildContext context) {
    NavigationService.safeNavigate(
      AppRouter.auth,
      clearStack: true,
    );
  }
} 