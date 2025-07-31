import 'dart:convert';
import 'dart:ui' as ui;

import 'package:emora_mobile_app/core/utils/dialog_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class SafeQRCodeDialog {
  static void show(BuildContext context, dynamic profile) {
    if (profile == null) {
      DialogUtils.showErrorSnackBar(context, 'Profile data not available');
      return;
    }

    try {
      final qrData = _generateQRData(profile);

      showCupertinoModalPopup<void>(
        context: context,
        builder: (context) => _buildQRDialog(context, profile, qrData),
      );
    } catch (e) {
      DialogUtils.showErrorSnackBar(
        context,
        'Failed to generate QR code: ${e.toString()}',
      );
    }
  }

  static Widget _buildQRDialog(
    BuildContext context,
    dynamic profile,
    String qrData,
  ) {
    return CupertinoPopupSurface(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              _buildHeader(context, profile),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildContent(qrData),
                ),
              ),

              _buildActions(context, qrData, profile),
            ],
          ),
        ),
      ),
    );
  }

  static String _generateQRData(dynamic profile) {
    try {
      final data = {
        'type': 'emora_profile',
        'userId': profile?.id ?? 'unknown',
        'username': profile?.username ?? profile?.name ?? 'user',
        'avatar': profile?.avatar ?? 'fox',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final jsonData = jsonEncode(data);

      if (jsonData.length > 2000) {
        throw Exception('Profile data too large for QR code');
      }

      return jsonData;
    } catch (e) {
      throw Exception('Failed to generate QR data: $e');
    }
  }

  static Widget _buildHeader(BuildContext context, dynamic profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CupertinoColors.separator)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Center(
              child: Text(
                DialogUtils.getEmojiForAvatar(profile?.avatar ?? 'fox'),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${profile?.username ?? profile?.name ?? "Your"} Profile',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const Text(
                  'Share your QR code',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),

          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: const Icon(
              CupertinoIcons.xmark_circle_fill,
              color: CupertinoColors.systemGrey,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildContent(String qrData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 240,
          height: 240,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 200.0,
            backgroundColor: Colors.white,
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black,
            ),
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.black,
            ),
          ),
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.info_circle,
                color: const Color(0xFF8B5CF6),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to use',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Share this QR code with friends to connect instantly on EMORA!',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildActions(
    BuildContext context,
    String qrData,
    dynamic profile,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: CupertinoColors.separator)),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoButton(
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(12),
              onPressed: () => _shareQRCode(context, qrData),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.share, size: 18),
                  const SizedBox(width: 8),
                  const Text('Share'),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: CupertinoButton(
              color: const Color(0xFF8B5CF6),
              borderRadius: BorderRadius.circular(12),
              onPressed: () => _saveQRCode(context, qrData, profile),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.download_circle, size: 18),
                  const SizedBox(width: 8),
                  const Text('Save'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _shareQRCode(BuildContext context, String qrData) {
    try {
      Share.share('Connect with me on EMORA! Scan this QR code: $qrData');
      HapticFeedback.lightImpact();
      DialogUtils.showSuccessSnackBar(context, 'QR code shared successfully!');
    } catch (e) {
      DialogUtils.showErrorSnackBar(context, 'Failed to share QR code');
    }
  }

  static void _saveQRCode(
    BuildContext context,
    String qrData,
    dynamic profile,
  ) async {
    try {
      final permission = await Permission.photos.request();
      if (!permission.isGranted) {
        if (context.mounted) {
          DialogUtils.showErrorSnackBar(
            context,
            'Permission denied. Please allow access to Photos in Settings.',
          );
        }
        return;
      }

      if (context.mounted) {
        showCupertinoDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const CupertinoAlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoActivityIndicator(radius: 15),
                SizedBox(height: 16),
                Text('Saving QR code...'),
              ],
            ),
          ),
        );
      }

      final qrValidationResult = QrValidator.validate(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Color(0xFF000000),
          ),
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Color(0xFF000000),
          ),
          gapless: true,
        );

        final picData = await painter.toImageData(
          512,
          format: ui.ImageByteFormat.png,
        );

        if (picData != null) {
          final result = await ImageGallerySaver.saveImage(
            picData.buffer.asUint8List(),
            name:
                'emora_qr_${profile?.username ?? 'user'}_${DateTime.now().millisecondsSinceEpoch}',
            quality: 100,
          );

          if (context.mounted) {
            Navigator.pop(context);

            if (result['isSuccess'] == true) {
              Navigator.pop(context);

              DialogUtils.showSuccessSnackBar(
                context,
                'QR code saved to Photos!',
              );
              HapticFeedback.lightImpact();
            } else {
              DialogUtils.showErrorSnackBar(context, 'Failed to save QR code');
            }
          }
        } else {
          if (context.mounted) {
Navigator.pop(context); 
            DialogUtils.showErrorSnackBar(
              context,
              'Failed to generate QR image',
            );
          }
        }
      } else {
        if (context.mounted) {
Navigator.pop(context); 
          DialogUtils.showErrorSnackBar(context, 'Invalid QR code data');
        }
      }
    } catch (e) {
      if (context.mounted) {
        try {
          Navigator.pop(context);
        } catch (_) {
        }

        DialogUtils.showErrorSnackBar(
          context,
          'Failed to save QR code: ${e.toString()}',
        );
      }
    }
  }

  static void showSimpleQRDialog(BuildContext context, dynamic profile) {
    if (profile == null) {
      DialogUtils.showErrorSnackBar(context, 'Profile data not available');
      return;
    }

    try {
      final qrData = _generateQRData(profile);

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('${profile?.username ?? "Your"} Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 200,
                height: 200,
                color: Colors.white,
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Share this QR code with friends!',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                _shareQRCode(context, qrData);
              },
              isDefaultAction: true,
              child: const Text('Share'),
            ),
          ],
        ),
      );
    } catch (e) {
      DialogUtils.showErrorSnackBar(context, 'Failed to create QR code');
    }
  }
}
