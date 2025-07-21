// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'lib/features/home/presentation/widget/enhanced_emotion_entry_modal.dart';

// void main() {
//   runApp(const TestApp());
// }

// class TestApp extends StatelessWidget {
//   const TestApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Enhanced Emotion Privacy Test',
//       theme: ThemeData.dark(),
//       home: const TestHomePage(),
//     );
//   }
// }

// class TestHomePage extends StatelessWidget {
//   const TestHomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0A0F),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Enhanced Emotion Entry Modal Test',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _showEmotionModal(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF8B5CF6),
//                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//               ),
//               child: const Text(
//                 'Test Enhanced Emotion Modal',
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'This will test the new privacy options:\n• Private logging\n• Community posting\n• Anonymous posting',
//               style: TextStyle(color: Colors.grey, fontSize: 14),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showEmotionModal(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => EnhancedEmotionEntryModal(
//         onEmotionLogged: (emotion, intensity, contextText, tags, location, isPrivate, isAnonymous) {
//           print('🎭 Emotion logged:');
//           print('  - Emotion: $emotion');
//           print('  - Intensity: $intensity');
//           print('  - Context: $contextText');
//           print('  - Tags: $tags');
//           print('  - Location: ${location != null ? '${location.latitude}, ${location.longitude}' : 'None'}');
//           print('  - Private: $isPrivate');
//           print('  - Anonymous: $isAnonymous');
          
//           // Show result in a snackbar
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 isPrivate 
//                   ? '. $emotion logged privately'
//                   : '🌍 $emotion posted to community${isAnonymous ? ' (anonymous)' : ''}',
//               ),
//               backgroundColor: const Color(0xFF8B5CF6),
//             ),
//           );
//         },
//       ),
//     );
//   }
// } 