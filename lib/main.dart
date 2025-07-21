import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/bloc_observer.dart';
import 'app/di/injection_container.dart' as di;
import 'core/navigation/navigation_service.dart';
import 'core/utils/logger.dart';
import 'package:just_audio/just_audio.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {

    Logger.init(
      level: LogLevel
          .warning, 
      enableFileLogging: false,
      clearPreviousLogs: true,
    );

    Logger.info(' Starting Emora Mobile App...');

    // --- PROFESSIONAL PRACTICE ---
    // Do NOT clear onboarding data on every app start.
    // If you need to clear onboarding data for a migration or bug fix,
    // use the utility below ONCE, then comment it out again.
    // await clearOnboardingDataForMigration(); // <-- Only run manually if needed

    await _setupSystemUI();
    await _initializeDependencies();

    _setupBlocObserver();
    runApp(const EmoraApp());

    Logger.info(' App started successfully');
  } catch (e, stackTrace) {
    Logger.error(' Failed to start app: $e', stackTrace);
    runApp(_buildErrorApp(e.toString()));
  }
}

// --- ONBOARDING DATA CLEAR UTILITY (for one-time migrations/bugfixes) ---
// Call this ONLY if you need to reset onboarding for all users (e.g. after a breaking change).
// Never call this in production code on every app start!
Future<void> clearOnboardingDataForMigration() async {
  final prefs = await SharedPreferences.getInstance();
  final onboardingKeys = [
    'onboarding_pronouns',
    'onboarding_age_group',
    'onboarding_avatar',
    'onboarding_username',
    'onboarding_completed',
    'onboarding_timestamp',
    'onboarding_data_json',
    'user_onboarding_data',
  ];
  for (final key in onboardingKeys) {
    await prefs.remove(key);
  }
  Logger.info('🧹 Cleared cached onboarding data for migration/debug.');
}

Future<void> _setupSystemUI() async {
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF090110),
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    Logger.info('System UI configured');
  } catch (e, stackTrace) {
    Logger.error('Failed to setup system UI: $e', stackTrace);
  }
}

Future<void> _initializeDependencies() async {
  try {
    Logger.info('. Initializing dependencies...');
    await di.init();
    Logger.info(' Dependencies initialized');
  } catch (e, stackTrace) {
    Logger.error(' Failed to initialize dependencies: $e', stackTrace);
    rethrow;
  }
}

void _setupBlocObserver() {
  try {
    Bloc.observer = AppBlocObserver();
    Logger.info('. Bloc observer configured');
  } catch (e, stackTrace) {
    Logger.error('. Failed to setup Bloc observer: $e', stackTrace);
  }
}

Widget _buildErrorApp(String error) {
  return MaterialApp(
    title: 'Emora - Error',
    debugShowCheckedModeBanner: false,
    navigatorKey: NavigationService.navigatorKey,
    home: Scaffold(
      backgroundColor: const Color(0xFF090110),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'App Failed to Start',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We encountered an error while starting the app. Please restart the application.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5FBF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Restart App',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class SpotifyTrackPlayer extends StatefulWidget {
  final String previewUrl;
  final String trackName;
  final String artist;
  final String imageUrl;

  const SpotifyTrackPlayer({
    required this.previewUrl,
    required this.trackName,
    required this.artist,
    required this.imageUrl,
    Key? key,
  }) : super(key: key);

  @override
  State<SpotifyTrackPlayer> createState() => _SpotifyTrackPlayerState();
}

class _SpotifyTrackPlayerState extends State<SpotifyTrackPlayer> {
  late AudioPlayer _player;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.setUrl(widget.previewUrl);
      await _player.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(widget.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
      title: Text(widget.trackName),
      subtitle: Text(widget.artist),
      trailing: IconButton(
        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
        onPressed: _togglePlay,
      ),
    );
  }
}
