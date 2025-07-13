// lib/features/home/presentation/widget/dialogs/avatar_picker_dialog.dart
import 'package:emora_mobile_app/core/utils/dialog_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Standalone avatar picker dialog
///
/// Features:
/// - Grid layout with 32+ avatar options
/// - Visual selection feedback
/// - Haptic feedback on selection
/// - iOS-style bottom sheet presentation
class AvatarPickerDialog {
  /// Shows the avatar picker dialog
  static void show(
    BuildContext context,
    String currentAvatar,
    ValueChanged<String> onAvatarChanged,
  ) {
    final avatars = DialogUtils.getAvailableAvatars();

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            _buildHandleBar(),

            // Header
            _buildHeader(context),

            // Avatar grid
            _buildAvatarGrid(context, avatars, currentAvatar, onAvatarChanged),
          ],
        ),
      ),
    );
  }

  /// Builds the handle bar at the top
  static Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Builds the header with title and close button
  static Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(CupertinoIcons.smiley, color: Color(0xFF8B5CF6)),
          const SizedBox(width: 12),
          const Text(
            'Choose Avatar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: const Icon(CupertinoIcons.xmark, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Builds the avatar selection grid
  static Widget _buildAvatarGrid(
    BuildContext context,
    List<Map<String, String>> avatars,
    String currentAvatar,
    ValueChanged<String> onAvatarChanged,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: avatars.length,
          itemBuilder: (context, index) {
            final avatar = avatars[index];
            final isSelected = currentAvatar == avatar['name'];

            return _buildAvatarItem(
              context,
              avatar,
              isSelected,
              onAvatarChanged,
            );
          },
        ),
      ),
    );
  }

  /// Builds individual avatar item
  static Widget _buildAvatarItem(
    BuildContext context,
    Map<String, String> avatar,
    bool isSelected,
    ValueChanged<String> onAvatarChanged,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        onAvatarChanged(avatar['name']!);
        Navigator.pop(context);
        HapticFeedback.selectionClick();
        DialogUtils.showSuccessSnackBar(context, 'Avatar updated!');
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[600]!,
            width: isSelected ? 3 : 1,
          ),
          color: isSelected
              ? const Color(0xFF8B5CF6).withOpacity(0.2)
              : Colors.grey[800],
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(avatar['emoji']!, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
