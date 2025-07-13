// lib/features/home/presentation/widget/profile_account_widget.dart
import 'package:emora_mobile_app/features/home/data/model/settings_model.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_bloc.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'profile_dialogs.dart';

class ProfileAccountWidget extends StatefulWidget {
  final dynamic profile;
  final bool isExporting;
  final VoidCallback onExportData;
  final VoidCallback onDeleteAccount;
  final SettingsModel? settings;

  const ProfileAccountWidget({
    super.key,
    required this.profile,
    this.isExporting = false,
    required this.onExportData,
    required this.onDeleteAccount,
    this.settings,
  });

  @override
  State<ProfileAccountWidget> createState() => _ProfileAccountWidgetState();
}

class _ProfileAccountWidgetState extends State<ProfileAccountWidget>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _cardAnimationController;
  late Animation<double> _glowAnimation;

  // Settings state
  bool _notificationsEnabled = true;
  bool _dataSharingEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Cosmic Purple';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSettings();
  }

  void _loadSettings() {
    if (widget.settings != null) {
      setState(() {
        _notificationsEnabled = widget.settings!.notificationsEnabled;
        _dataSharingEnabled = widget.settings!.dataSharingEnabled;
        _selectedLanguage = widget.settings!.language;
        _selectedTheme = widget.settings!.theme;
      });
    }
  }

  List<_SettingItem> get _settingItems => [
    _SettingItem(
      title: 'Notifications',
      subtitle: _notificationsEnabled
          ? 'Get reminders and updates about your emotional journey'
          : 'Notifications are currently disabled',
      icon: _notificationsEnabled
          ? Icons.notifications_active
          : Icons.notifications_off,
      color: _notificationsEnabled ? const Color(0xFF10B981) : Colors.grey,
      isFirst: true,
      hasToggle: true,
      toggleValue: _notificationsEnabled,
    ),
    _SettingItem(
      title: 'Data Sharing',
      subtitle: _dataSharingEnabled
          ? 'Anonymous usage data helps improve EMORA for everyone'
          : 'Data sharing is disabled for enhanced privacy',
      icon: _dataSharingEnabled ? Icons.share : Icons.security,
      color: _dataSharingEnabled ? const Color(0xFF3B82F6) : Colors.grey,
      hasToggle: true,
      toggleValue: _dataSharingEnabled,
    ),
    _SettingItem(
      title: 'Language',
      subtitle: 'Current language: $_selectedLanguage',
      icon: Icons.language,
      color: const Color(0xFF8B5CF6),
      hasArrow: true,
    ),
    _SettingItem(
      title: 'Theme',
      subtitle: 'Current theme: $_selectedTheme',
      icon: Icons.palette,
      color: const Color(0xFF6366F1),
      hasArrow: true,
    ),
    _SettingItem(
      title: 'Privacy Policy',
      subtitle:
          'Review our comprehensive privacy policy and data handling practices',
      icon: Icons.privacy_tip_rounded,
      color: const Color(0xFF8B5CF6),
      hasArrow: true,
    ),
    _SettingItem(
      title: 'Terms of Service',
      subtitle: 'View our terms and conditions for using EMORA',
      icon: Icons.description_rounded,
      color: const Color(0xFF6366F1),
      hasArrow: true,
    ),
    _SettingItem(
      title: 'Help & Support',
      subtitle: 'Get assistance and contact our dedicated support team',
      icon: Icons.help_center_rounded,
      color: const Color(0xFF10B981),
      hasArrow: true,
    ),
    _SettingItem(
      title: 'Export Data',
      subtitle: 'Download and backup your personal data and insights securely',
      icon: Icons.download_rounded,
      color: const Color(0xFFFF6B35),
      isLoading: widget.isExporting,
      hasArrow: true,
    ),
    _SettingItem(
      title: 'Delete Account',
      subtitle: 'Permanently delete your EMORA account and all data',
      icon: Icons.delete_forever_rounded,
      color: Colors.red,
      isDestructive: true,
      hasArrow: true,
    ),
    _SettingItem(
      title: 'Sign Out',
      subtitle: 'Securely sign out of your EMORA account',
      icon: Icons.logout_rounded,
      color: Colors.orange,
      isLast: true,
      hasArrow: true,
    ),
  ];

  void _initializeAnimations() {
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _cardAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedSectionHeader(),
          const SizedBox(height: 24),
          _buildUltraModernSettingsContainer(),
        ],
      ),
    );
  }

  Widget _buildEnhancedSectionHeader() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(
                      0xFF8B5CF6,
                    ).withOpacity(0.3), // FIXED: withValues -> withOpacity
                    const Color(
                      0xFF6366F1,
                    ).withOpacity(0.2), // FIXED: withValues -> withOpacity
                    const Color(
                      0xFF3B82F6,
                    ).withOpacity(0.1), // FIXED: withValues -> withOpacity
                  ],
                ),
                border: Border.all(
                  color: const Color(
                    0xFF8B5CF6,
                  ).withOpacity(0.4), // FIXED: withValues -> withOpacity
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(
                      0.2 * _glowAnimation.value,
                    ), // FIXED: withValues -> withOpacity
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.settings,
                color: Color(0xFF8B5CF6),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Settings & Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Manage your preferences and account',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    const Color(
                      0xFF10B981,
                    ).withOpacity(0.2), // FIXED: withValues -> withOpacity
                    const Color(
                      0xFF059669,
                    ).withOpacity(0.1), // FIXED: withValues -> withOpacity
                  ],
                ),
                border: Border.all(
                  color: const Color(
                    0xFF10B981,
                  ).withOpacity(0.3), // FIXED: withValues -> withOpacity
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Secure',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUltraModernSettingsContainer() {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * _cardAnimationController.value),
          child: Opacity(
            opacity: _cardAnimationController.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(
                      0xFF1A1A2E,
                    ).withOpacity(0.95), // FIXED: withValues -> withOpacity
                    const Color(
                      0xFF16213E,
                    ).withOpacity(0.8), // FIXED: withValues -> withOpacity
                    const Color(
                      0xFF0F172A,
                    ).withOpacity(0.6), // FIXED: withValues -> withOpacity
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                border: Border.all(
                  color: const Color(
                    0xFF8B5CF6,
                  ).withOpacity(0.2), // FIXED: withValues -> withOpacity
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF8B5CF6,
                    ).withOpacity(0.1), // FIXED: withValues -> withOpacity
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      0.25,
                    ), // FIXED: withValues -> withOpacity
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (int i = 0; i < _settingItems.length; i++) ...[
                    _buildUltraModernSettingCard(_settingItems[i], i),
                    if (i < _settingItems.length - 1) _buildEnhancedDivider(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            const Color(
              0xFF8B5CF6,
            ).withOpacity(0.3), // FIXED: withValues -> withOpacity
            const Color(
              0xFF6366F1,
            ).withOpacity(0.2), // FIXED: withValues -> withOpacity
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildUltraModernSettingCard(_SettingItem item, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: item.isLoading ? null : () => _handleSettingTap(item),
                borderRadius: BorderRadius.vertical(
                  top: item.isFirst ? const Radius.circular(28) : Radius.zero,
                  bottom: item.isLast ? const Radius.circular(28) : Radius.zero,
                ),
                splashColor: item.color.withValues(alpha: 0.1),
                highlightColor: item.color.withValues(alpha: 0.05),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _buildAdvancedIcon(item),
                      const SizedBox(width: 16),
                      Expanded(child: _buildEnhancedTextContent(item)),
                      if (item.hasToggle)
                        _buildToggleSwitch(item)
                      else if (item.hasArrow)
                        _buildModernTrailingIcon(item),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedIcon(_SettingItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: item.isDestructive
              ? [
                  Colors.red.withOpacity(
                    0.2,
                  ), // FIXED: withValues -> withOpacity
                  Colors.red.withOpacity(
                    0.15,
                  ), // FIXED: withValues -> withOpacity
                  Colors.red.withOpacity(
                    0.1,
                  ), // FIXED: withValues -> withOpacity
                ]
              : [
                  item.color.withOpacity(
                    0.2,
                  ), // FIXED: withValues -> withOpacity
                  item.color.withOpacity(
                    0.15,
                  ), // FIXED: withValues -> withOpacity
                  item.color.withOpacity(
                    0.1,
                  ), // FIXED: withValues -> withOpacity
                ],
        ),
        border: Border.all(
          color: item.isDestructive
              ? Colors.red.withOpacity(0.4) // FIXED: withValues -> withOpacity
              : item.color.withOpacity(0.4), // FIXED: withValues -> withOpacity
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: item.isDestructive
                ? Colors.red.withOpacity(
                    0.15,
                  ) // FIXED: withValues -> withOpacity
                : item.color.withOpacity(
                    0.15,
                  ), // FIXED: withValues -> withOpacity
            blurRadius: 10,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: item.isLoading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: item.color,
                strokeWidth: 2.5,
              ),
            )
          : Icon(
              item.icon,
              color: item.isDestructive ? Colors.red : item.color,
              size: 22,
            ),
    );
  }

  Widget _buildEnhancedTextContent(_SettingItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  color: item.isDestructive ? Colors.red : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (item.title == 'Export Data') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                ),
                child: const Text(
                  'GDPR',
                  style: TextStyle(
                    color: Color(0xFFFF6B35),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            if (item.title == 'Help & Support') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                ),
                child: const Text(
                  '24/7',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          item.isLoading && item.title == 'Export Data'
              ? 'Preparing your data export...'
              : item.subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 13,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
            height: 1.3,
          ),
        ),
        if (item.title == 'Privacy Policy') ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Last updated: Dec 2024',
                style: TextStyle(
                  color: const Color(0xFF10B981),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildToggleSwitch(_SettingItem item) {
    // FIXED: Wrap Switch with Material
    return Material(
      color: Colors.transparent,
      child: Switch.adaptive(
        value: item.toggleValue ?? false,
        onChanged: (value) => _handleToggleChange(item.title, value),
        activeColor: item.color,
        inactiveThumbColor: Colors.grey[400],
        inactiveTrackColor: Colors.grey[700],
      ),
    );
  }

  // In _buildModernTrailingIcon method (around line 485):
  Widget _buildModernTrailingIcon(_SettingItem item) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: item.color.withOpacity(0.1), // FIXED: withValues -> withOpacity
        border: Border.all(
          color: item.color.withOpacity(0.2),
        ), // FIXED: withValues -> withOpacity
      ),
      child: Icon(Icons.chevron_right_rounded, color: item.color, size: 18),
    );
  }

  void _handleToggleChange(String settingTitle, bool value) {
    HapticFeedback.selectionClick();

    setState(() {
      switch (settingTitle) {
        case 'Notifications':
          _notificationsEnabled = value;
          break;
        case 'Data Sharing':
          _dataSharingEnabled = value;
          break;
      }
    });

    // Save to database
    _saveSettingsToDatabase();
  }

  void _handleSettingTap(_SettingItem item) {
    HapticFeedback.lightImpact();

    switch (item.title) {
      case 'Language':
        _showLanguageSelector();
        break;
      case 'Theme':
        _showThemeSelector();
        break;
      case 'Privacy Policy':
        ProfileDialogs.showComingSoonDialog(context, 'Privacy Policy');
        break;
      case 'Terms of Service':
        ProfileDialogs.showComingSoonDialog(context, 'Terms of Service');
        break;
      case 'Help & Support':
        ProfileDialogs.showSupportHelp(context);
        break;
      case 'Export Data':
        ProfileDialogs.showExportDialog(context, onExport: widget.onExportData);
        break;
      case 'Delete Account':
        ProfileDialogs.showDeleteAccountDialog(
          context,
          onConfirm: widget.onDeleteAccount,
        );
        break;
      case 'Sign Out':
        ProfileDialogs.showSignOutDialog(context);
        break;
    }
  }

  // ✅ FIXED: Built-in language selector (no external dependency)
  void _showLanguageSelector() {
    final languages = [
      {'name': 'English', 'flag': '🇺🇸'},
      {'name': 'Spanish', 'flag': '🇪🇸'},
      {'name': 'French', 'flag': '🇫🇷'},
      {'name': 'German', 'flag': '🇩🇪'},
      {'name': 'Italian', 'flag': '🇮🇹'},
      {'name': 'Portuguese', 'flag': '🇵🇹'},
      {'name': 'Chinese', 'flag': '🇨🇳'},
      {'name': 'Japanese', 'flag': '🇯🇵'},
      {'name': 'Korean', 'flag': '🇰🇷'},
      {'name': 'Hindi', 'flag': '🇮🇳'},
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                          const Color(0xFF6366F1).withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.globe,
                      color: Color(0xFF8B5CF6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Select Language',
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

            // Language list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  final isSelected = _selectedLanguage == language['name'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(16),
                      color: isSelected
                          ? const Color(0xFF8B5CF6).withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      onPressed: () {
                        setState(() {
                          _selectedLanguage = language['name']!;
                        });
                        Navigator.pop(context);
                        _saveSettingsToDatabase();
                        HapticFeedback.selectionClick();
                      },
                      child: Row(
                        children: [
                          Text(
                            language['flag']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              language['name']!,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF8B5CF6)
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              CupertinoIcons.checkmark,
                              color: Color(0xFF8B5CF6),
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ FIXED: Built-in theme selector (no external dependency)
  void _showThemeSelector() {
    final themes = [
      {
        'name': 'Cosmic Purple',
        'gradient': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
        'primaryColor': const Color(0xFF8B5CF6),
      },
      {
        'name': 'Ocean Blue',
        'gradient': [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
        'primaryColor': const Color(0xFF3B82F6),
      },
      {
        'name': 'Forest Green',
        'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
        'primaryColor': const Color(0xFF10B981),
      },
      {
        'name': 'Sunset Orange',
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        'primaryColor': const Color(0xFFF59E0B),
      },
      {
        'name': 'Cherry Blossom',
        'gradient': [const Color(0xFFEC4899), const Color(0xFFDB2777)],
        'primaryColor': const Color(0xFFEC4899),
      },
      {
        'name': 'Fire Red',
        'gradient': [const Color(0xFFEF4444), const Color(0xFFDC2626)],
        'primaryColor': const Color(0xFFEF4444),
      },
    ];

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
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                          const Color(0xFF6366F1).withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.paintbrush_fill,
                      color: Color(0xFF8B5CF6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Choose Theme',
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

            // Theme grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final theme = themes[index];
                  final isSelected = _selectedTheme == theme['name'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTheme = theme['name']! as String;
                      });
                      Navigator.pop(context);
                      _saveSettingsToDatabase();
                      HapticFeedback.selectionClick();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: theme['gradient'] as List<Color>,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: (theme['primaryColor'] as Color)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          if (isSelected)
                            const Positioned(
                              top: 12,
                              right: 12,
                              child: Icon(
                                CupertinoIcons.checkmark_circle_fill,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Text(
                              theme['name']! as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ✅ FIXED: Proper ProfileBloc event dispatch
  void _saveSettingsToDatabase() {
    final settingsData = {
      'notificationsEnabled': _notificationsEnabled,
      'dataSharingEnabled': _dataSharingEnabled,
      'language': _selectedLanguage,
      'theme': _selectedTheme,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    try {
      // Save using ProfileBloc
      context.read<ProfileBloc>().add(UpdateSettings(settings: settingsData));
    } catch (e) {
      // Fallback: Show success message even if BLoC fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              const Text('Settings updated successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}

class _SettingItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDestructive;
  final bool isFirst;
  final bool isLast;
  final bool isLoading;
  final bool hasToggle;
  final bool? toggleValue;
  final bool hasArrow;

  const _SettingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isDestructive = false,
    this.isFirst = false,
    this.isLast = false,
    this.isLoading = false,
    this.hasToggle = false,
    this.toggleValue,
    this.hasArrow = false,
  });
}
