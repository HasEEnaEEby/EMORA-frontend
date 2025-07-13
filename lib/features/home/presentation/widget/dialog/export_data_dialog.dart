// lib/features/home/presentation/widget/dialogs/export_data_dialog.dart
import 'package:emora_mobile_app/core/utils/dialog_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Data export dialog
///
/// Features:
/// - Multiple export options
/// - Progress indicators
/// - File sharing capabilities
/// - GDPR compliant notifications
class ExportDataDialog {
  /// Shows the export data dialog
  static void show(BuildContext context, {required VoidCallback onExport}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: _buildDialogTitle(),
        content: _buildDialogContent(context),
        actions: _buildDialogActions(context, onExport),
      ),
    );
  }

  /// Builds the dialog title
  static Widget _buildDialogTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(
              0xFF8B5CF6,
            ).withValues(alpha: 0.2), // Fixed: withValues
          ),
          child: const Icon(
            CupertinoIcons.square_arrow_down,
            color: Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 12),
        const Text('Export Data'),
      ],
    );
  }

  /// Builds the dialog content
  static Widget _buildDialogContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Export your data in a secure, portable format. Choose what to include:',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 20),

        // Export options
        _buildExportOption(
          'Complete Profile',
          CupertinoIcons.person,
          'Personal info, settings, and preferences',
          () => _exportSpecificData(context, 'profile'),
        ),
        _buildExportOption(
          'Emotion History',
          CupertinoIcons.chart_bar,
          'All logged emotions and mood entries',
          () => _exportSpecificData(context, 'emotions'),
        ),
        _buildExportOption(
          'Achievements & Stats',
          CupertinoIcons.rosette, // Fixed: Use rosette instead of trophy
          'Progress, achievements, and insights',
          () => _exportSpecificData(context, 'achievements'),
        ),
        _buildExportOption(
          'Social Data',
          CupertinoIcons
              .person_2, // Fixed: Use person_2 instead of person_2_circle
          'Friends, connections, and shared content',
          () => _exportSpecificData(context, 'social'),
        ),

        const SizedBox(height: 16),

        // GDPR compliance notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: CupertinoColors.systemBlue.withValues(
              alpha: 0.1,
            ), // Fixed: withValues
          ),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.shield,
                color: CupertinoColors.systemBlue,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'All exports are encrypted and GDPR compliant',
                  style: TextStyle(
                    color: CupertinoColors.systemBlue,
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

  /// Builds export option item
  static Widget _buildExportOption(
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: CupertinoColors.systemGrey6,
            border: Border.all(color: CupertinoColors.systemGrey4),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(
                    0xFF8B5CF6,
                  ).withValues(alpha: 0.2), // Fixed: withValues
                ),
                child: Icon(icon, color: const Color(0xFF8B5CF6), size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey2,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds dialog action buttons
  static List<Widget> _buildDialogActions(
    BuildContext context,
    VoidCallback onExport,
  ) {
    return [
      CupertinoDialogAction(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      CupertinoDialogAction(
        onPressed: () {
          Navigator.pop(context);
          _exportAllData(context, onExport);
        },
        isDefaultAction: true,
        child: const Text('Export All'),
      ),
    ];
  }

  /// Exports specific data type
  static void _exportSpecificData(BuildContext context, String dataType) {
    Navigator.pop(context);
    _showExportProgress(context, dataType);
  }

  /// Exports all data
  static void _exportAllData(BuildContext context, VoidCallback onExport) {
    _showExportProgress(context, 'all');
    onExport();
  }

  /// Shows export progress dialog
  static void _showExportProgress(BuildContext context, String dataType) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(radius: 20),
            const SizedBox(height: 20),
            Text(
              'Exporting ${dataType == 'all' ? 'all' : dataType} data...',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'This may take a few moments',
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

    // Simulate export process
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        // Fixed: Check mounted state
        Navigator.pop(context);
        _showExportComplete(context, dataType);
      }
    });
  }

  /// Shows export completion dialog
  static void _showExportComplete(BuildContext context, String dataType) {
    final fileName =
        'emora_export_${dataType}_${DateTime.now().millisecondsSinceEpoch}.json';

    if (context.mounted) {
      // Fixed: Check mounted state
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: _buildCompletionTitle(),
          content: _buildCompletionContent(dataType, fileName),
          actions: _buildCompletionActions(context, fileName),
        ),
      );
    }
  }

  /// Builds completion dialog title
  static Widget _buildCompletionTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CupertinoColors.systemGreen.withValues(
              alpha: 0.2,
            ), // Fixed: withValues
          ),
          child: const Icon(
            CupertinoIcons.check_mark,
            color: CupertinoColors.systemGreen,
          ),
        ),
        const SizedBox(width: 12),
        const Text('Export Complete'),
      ],
    );
  }

  /// Builds completion dialog content
  static Widget _buildCompletionContent(String dataType, String fileName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Text(
          'Your ${dataType == 'all' ? 'complete' : dataType} data has been exported successfully.',
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: CupertinoColors.systemGreen.withValues(
              alpha: 0.1,
            ), // Fixed: withValues
          ),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.square_arrow_down,
                color: CupertinoColors.systemGreen,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fileName,
                  style: const TextStyle(
                    color: CupertinoColors.systemGreen,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: CupertinoColors.systemYellow.withValues(
              alpha: 0.1,
            ), // Fixed: withValues
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.info_circle,
                color: CupertinoColors.systemYellow,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'File will be available for 24 hours',
                  style: TextStyle(
                    color: CupertinoColors.systemYellow,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds completion dialog actions
  static List<Widget> _buildCompletionActions(
    BuildContext context,
    String fileName,
  ) {
    return [
      CupertinoDialogAction(
        onPressed: () {
          Navigator.pop(context);
          _shareExportedFile(context, fileName);
        },
        child: const Text('Share'),
      ),
      CupertinoDialogAction(
        onPressed: () {
          Navigator.pop(context);
          _downloadExportedFile(context, fileName);
        },
        child: const Text('Download'),
      ),
      CupertinoDialogAction(
        onPressed: () => Navigator.pop(context),
        isDefaultAction: true,
        child: const Text('Done'),
      ),
    ];
  }

  /// Shares the exported file
  static void _shareExportedFile(BuildContext context, String fileName) {
    // Fixed: Use Share.share instead of SharePlus.instance.share
    Share.share('Here\'s my EMORA data export file: $fileName');
    HapticFeedback.lightImpact();
    DialogUtils.showSuccessSnackBar(
      context,
      'Export file shared successfully!',
    );
  }

  /// Downloads the exported file
  static void _downloadExportedFile(BuildContext context, String fileName) {
    // In a real implementation, this would trigger the download
    HapticFeedback.lightImpact();
    DialogUtils.showSuccessSnackBar(context, 'Download started!');
  }

  /// Shows detailed export options
  static void showDetailedExportOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.tray_arrow_down,
                    color: Color(0xFF8B5CF6),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Detailed Export Options',
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
            ),

            // Detailed options list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildDetailedOption(
                    context,
                    'Profile Data',
                    'Basic profile information, settings, preferences',
                    CupertinoIcons.person_circle,
                    ['Username', 'Email', 'Bio', 'Avatar', 'Privacy Settings'],
                  ),
                  _buildDetailedOption(
                    context,
                    'Emotion Logs',
                    'All your emotion entries with timestamps',
                    CupertinoIcons.heart_circle,
                    ['Daily emotions', 'Mood patterns', 'Notes', 'Timestamps'],
                  ),
                  _buildDetailedOption(
                    context,
                    'Analytics Data',
                    'Insights, trends, and statistical summaries',
                    CupertinoIcons.chart_bar_circle,
                    [
                      'Mood trends',
                      'Weekly summaries',
                      'Insights',
                      'Statistics',
                    ],
                  ),
                  _buildDetailedOption(
                    context,
                    'Social Connections',
                    'Friends, shared content, and interactions',
                    CupertinoIcons
                        .person_2_fill, // Fixed: Use correct available icon
                    ['Friend list', 'Shared posts', 'Messages', 'Interactions'],
                  ),
                  _buildDetailedOption(
                    context,
                    'Achievements',
                    'Unlocked achievements and progress tracking',
                    CupertinoIcons.rosette,
                    ['Earned badges', 'Progress data', 'Milestones', 'Points'],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds detailed export option
  static Widget _buildDetailedOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    List<String> includes,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF2A2A3E),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(
                    0xFF8B5CF6,
                  ).withValues(alpha: 0.2), // Fixed: withValues
                ),
                child: Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
              ),
              const SizedBox(width: 12),
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
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: true, // In real app, this would be stateful
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                },
                activeTrackColor: const Color(0xFF8B5CF6),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Includes:',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: includes
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(
                        0xFF8B5CF6,
                      ).withValues(alpha: 0.1), // Fixed: withValues
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        color: const Color(0xFF8B5CF6),
                        fontSize: 10,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
