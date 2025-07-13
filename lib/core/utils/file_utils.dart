// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:permission_handler/permission_handler.dart';

// class FileUtils {
//   static Future<String> getAppDocumentsPath() async {
//     final directory = await getApplicationDocumentsDirectory();
//     return directory.path;
//   }

//   static Future<String> getAppCachePath() async {
//     final directory = await getTemporaryDirectory();
//     return directory.path;
//   }

//   static Future<bool> saveJsonToFile(
//     Map<String, dynamic> data,
//     String fileName,
//   ) async {
//     try {
//       final path = await getAppDocumentsPath();
//       final file = File('$path/$fileName.json');
//       final jsonString = const JsonEncoder.withIndent('  ').convert(data);
//       await file.writeAsString(jsonString);
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   static Future<bool> shareJsonFile(
//     Map<String, dynamic> data,
//     String fileName,
//   ) async {
//     try {
//       final path = await getAppCachePath();
//       final file = File('$path/$fileName.json');
//       final jsonString = const JsonEncoder.withIndent('  ').convert(data);
//       await file.writeAsString(jsonString);

//       await Share.shareXFiles([
//         XFile(file.path),
//       ], text: 'EMORA Data Export - $fileName');
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   static Future<bool> saveImageToGallery(
//     Uint8List imageBytes,
//     String fileName,
//   ) async {
//     try {
//       final hasPermission = await Permission.photos.request().isGranted;
//       if (!hasPermission) return false;

//       final result = await ImageGallerySaver.saveImage(
//         imageBytes,
//         name: fileName,
//         quality: 100,
//       );
//       return result['isSuccess'] ?? false;
//     } catch (e) {
//       return false;
//     }
//   }

//   static Future<Uint8List?> generateQRCodeImage(String data) async {
//     try {
//       // This would typically use qr_flutter to generate the image
//       // For now, return null as a placeholder
//       return null;
//     } catch (e) {
//       return null;
//     }
//   }
// }
