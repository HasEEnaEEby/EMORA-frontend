import 'package:emora_mobile_app/core/network/dio_client.dart';
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
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get_it/get_it.dart';
import 'features/auth/data/data_source/local/auth_local_data_source.dart';
import 'features/auth/data/model/user_model.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'core/navigation/app_router.dart';
import '../../features/auth/presentation/view/forgot_password_view.dart';


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
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: const EmoraApp(),
      ),
    );

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

class MessageEntity {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;

  MessageEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
  });

  factory MessageEntity.fromJson(Map<String, dynamic> json) {
    return MessageEntity(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      content: json['content'],
      sentAt: DateTime.parse(json['sentAt']),
    );
  }
}

class MessageRepository {
  Future<List<MessageEntity>> fetchInbox() async {
    final response = await DioClient.instance.get('/api/messages/inbox');
    if (response.statusCode == 200) {
      final List data = response.data['data']['messages'];
      return data.map((json) => MessageEntity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }
}

class MessagesInboxPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messages')),
      body: FutureBuilder<List<MessageEntity>>(
        future: MessageRepository().fetchInbox(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No messages yet'));
          }
          final messages = snapshot.data!;
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              return ListTile(
                title: Text(msg.senderName),
                subtitle: Text(msg.content),
                trailing: Text(
                  '${msg.sentAt.hour.toString().padLeft(2, '0')}:${msg.sentAt.minute.toString().padLeft(2, '0')}',
                ),
                onTap: () {
                  // Optionally open conversation
                },
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _notifications = [];

  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);

  void addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}

class NotificationService {
  static IO.Socket? _socket;

  static Future<void> connectAndListen(BuildContext context) async {
    final userId = await getCurrentUserId();
    if (userId == null) return;

    _socket = IO.io('http://localhost:8000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.on('connect', (_) {
      _socket!.emit('join', {'room': 'user:$userId'});
    });

    _socket!.on('new_message', (data) {
      // Add to notification provider
      Provider.of<NotificationProvider>(context, listen: false).addNotification(data);
      // Optionally show a SnackBar as well
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New message from ${data['senderName']}: ${data['content']}'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  static void disconnect() {
    _socket?.disconnect();
  }
}

Future<String?> getCurrentUserId() async {
  final authLocalDataSource = GetIt.instance<AuthLocalDataSource>();
  final user = await authLocalDataSource.getCurrentUser();
  return user?.id;
}

class NotificationListDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifications = Provider.of<NotificationProvider>(context).notifications;
    return AlertDialog(
      title: Text('Notifications'),
      content: SizedBox(
        width: double.maxFinite,
        child: notifications.isEmpty
            ? Text('No new messages')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return ListTile(
                    title: Text(n['senderName'] ?? 'Unknown'),
                    subtitle: Text(n['content'] ?? ''),
                    trailing: Text(
                      n['sentAt'] != null
                          ? DateTime.parse(n['sentAt']).toLocal().toString().substring(0, 16)
                          : '',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Provider.of<NotificationProvider>(context, listen: false).clearNotifications();
            Navigator.pop(context);
          },
          child: Text('Clear All'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }
}
