// lib/features/home/presentation/widget/dialogs/language_selector_dialog.dart
import 'package:emora_mobile_app/core/utils/dialog_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// Language selection dialog
///
/// Features:
/// - List of supported languages with flags
/// - Current selection highlighting
/// - iOS-style presentation
/// - Haptic feedback on selection
class LanguageSelectorDialog {
  /// Shows the language selector dialog
  static void show(
    BuildContext context,
    String selectedLanguage,
    ValueChanged<String> onLanguageChanged,
  ) {
    final languages = DialogUtils.getAvailableLanguages();

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

            // Language list
            _buildLanguageList(
              context,
              languages,
              selectedLanguage,
              onLanguageChanged,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the handle bar
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

  /// Builds the header
  static Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(CupertinoIcons.globe, color: Color(0xFF8B5CF6)),
          const SizedBox(width: 12),
          const Text(
            'Select Language',
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

  /// Builds the language list
  static Widget _buildLanguageList(
    BuildContext context,
    List<Map<String, String>> languages,
    String selectedLanguage,
    ValueChanged<String> onLanguageChanged,
  ) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final language = languages[index];
          return _buildLanguageItem(
            context,
            language,
            selectedLanguage,
            onLanguageChanged,
          );
        },
      ),
    );
  }

  /// Builds individual language item
  static Widget _buildLanguageItem(
    BuildContext context,
    Map<String, String> language,
    String selectedLanguage,
    ValueChanged<String> onLanguageChanged,
  ) {
    final isSelected =
        selectedLanguage == language['name'] ||
        selectedLanguage == language['code'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          onLanguageChanged(language['name']!);
          Navigator.pop(context);
          HapticFeedback.selectionClick();
          DialogUtils.showSuccessSnackBar(
            context,
            'Language updated to ${language['name']}',
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? const Color(0xFF8B5CF6).withOpacity(0.2)
                : const Color(0xFF2A2A3E),
            border: isSelected
                ? Border.all(color: const Color(0xFF8B5CF6))
                : Border.all(color: Colors.grey[700]!),
          ),
          child: Row(
            children: [
              // Flag
              Text(language['flag']!, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 16),

              // Language name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language['name']!,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF8B5CF6)
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    Text(
                      language['code']!.toUpperCase(),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected) ...[
                const Icon(CupertinoIcons.check_mark, color: Color(0xFF8B5CF6)),
              ] else ...[
                Icon(
                  CupertinoIcons.chevron_right,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
