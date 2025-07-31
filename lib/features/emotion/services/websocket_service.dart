import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:latlong2/latlong.dart';
import 'package:emora_mobile_app/features/emotion/presentation/view/pages/models/emotion_map_models.dart';

class WebSocketService {
  static const String _wsUrl = 'ws:////////localhost:8000';
  
  WebSocketChannel? _channel;
  StreamController<MapEvent>? _eventController;
  StreamController<GlobalEmotionStats>? _statsController;
  StreamController<GlobalEmotionPoint>? _emotionController;
  
  bool _isConnected = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  
  bool get isConnected => _isConnected;
  
  Stream<MapEvent> get eventStream => _eventController!.stream;
  Stream<GlobalEmotionStats> get statsStream => _statsController!.stream;
  Stream<GlobalEmotionPoint> get emotionStream => _emotionController!.stream;

  WebSocketService() {
    _eventController = StreamController<MapEvent>.broadcast();
    _statsController = StreamController<GlobalEmotionStats>.broadcast();
    _emotionController = StreamController<GlobalEmotionPoint>.broadcast();
  }

  Future<void> connect() async {
    try {
      _channel = IOWebSocketChannel.connect(_wsUrl);
      _isConnected = true;
      
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      _startHeartbeat();
      
      print('WebSocket connected successfully');
    } catch (e) {
      print('WebSocket connection failed: $e');
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _stopHeartbeat();
    _stopReconnect();
    _channel?.sink.close();
    _isConnected = false;
    print('WebSocket disconnected');
  }

  void joinRoom(String room) {
    if (_isConnected) {
      _sendMessage({
        'type': 'joinRoom',
        'room': room,
      });
    }
  }

  void leaveRoom(String room) {
    if (_isConnected) {
      _sendMessage({
        'type': 'leaveRoom',
        'room': room,
      });
    }
  }

  Future<bool> submitEmotion({
    required double latitude,
    required double longitude,
    required String coreEmotion,
    required List<String> emotionTypes,
    required double intensity,
    String? city,
    String? country,
    String? context,
  }) async {
    if (!_isConnected) {
      print('WebSocket not connected');
      return false;
    }

    try {
      _sendMessage({
        'type': 'submitEmotion',
        'data': {
          'coordinates': [longitude, latitude],
          'coreEmotion': coreEmotion,
          'emotionTypes': emotionTypes,
          'intensity': intensity,
          'city': city,
          'country': country,
          'context': context,
        },
      });

      return true;
    } catch (e) {
      print('Error submitting emotion: $e');
      return false;
    }
  }

  void updateMapView({
    required Map<String, dynamic> bounds,
    required double zoom,
    required Map<String, dynamic> center,
  }) {
    if (_isConnected) {
      _sendMessage({
        'type': 'updateMapView',
        'data': {
          'bounds': bounds,
          'zoom': zoom,
          'center': center,
        },
      });
    }
  }

  void updateFilters(Map<String, dynamic> filters) {
    if (_isConnected) {
      _sendMessage({
        'type': 'updateFilters',
        'data': filters,
      });
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message);
      final type = data['type'];
      final payload = data['data'] ?? data;

      switch (type) {
        case 'connected':
          _handleConnected(payload);
          break;
        case 'newEmotion':
          _handleNewEmotion(payload);
          break;
        case 'globalStatsUpdated':
          _handleGlobalStatsUpdate(payload);
          break;
        case 'regionalStatsUpdated':
          _handleRegionalStatsUpdate(payload);
          break;
        case 'roomStatsUpdated':
          _handleRoomStatsUpdate(payload);
          break;
        case 'heartbeat':
          _handleHeartbeat(payload);
          break;
        case 'serverShutdown':
          _handleServerShutdown(payload);
          break;
        case 'error':
          _handleServerError(payload);
          break;
        default:
          print('Unknown WebSocket message type: $type');
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  void _handleConnected(Map<String, dynamic> data) {
    print('WebSocket connection established: ${data['clientId']}');
    _eventController?.add(MapEvent(
      type: MapEventType.connected,
      data: data,
    ));
  }

  void _handleNewEmotion(Map<String, dynamic> data) {
    try {
      final emotion = GlobalEmotionPoint(
        id: data['id'],
        coordinates: LatLng(data['coordinates'][1], data['coordinates'][0]),
        coreEmotion: data['coreEmotion'],
        emotionTypes: List<String>.from(data['emotionTypes']),
        count: 1,
        avgIntensity: _parseDouble(data['intensity']),
        maxIntensity: _parseDouble(data['intensity']),
        city: data['city'],
        country: data['country'],
        latestTimestamp: DateTime.parse(data['timestamp']),
      );

      _emotionController?.add(emotion);
      
      _eventController?.add(MapEvent(
        type: MapEventType.newEmotion,
        data: emotion,
      ));
    } catch (e) {
      print('Error parsing new emotion: $e');
    }
  }

  void _handleGlobalStatsUpdate(Map<String, dynamic> data) {
    try {
      final stats = GlobalEmotionStats(
        totalEmotions: data['totalEmotions'],
        avgIntensity: _parseDouble(data['avgIntensity']),
        coreEmotionStats: Map<String, CoreEmotionStats>.from(
          data['coreEmotionStats']?.map((key, value) => MapEntry(
            key,
            CoreEmotionStats(
              coreEmotion: value['coreEmotion'],
              count: value['count'],
              avgIntensity: _parseDouble(value['avgIntensity']),
            ),
          )) ?? {},
        ),
        lastUpdated: DateTime.parse(data['lastUpdated']),
      );

      _statsController?.add(stats);
      
      _eventController?.add(MapEvent(
        type: MapEventType.globalStatsUpdated,
        data: stats,
      ));
    } catch (e) {
      print('Error parsing global stats: $e');
    }
  }

  void _handleRegionalStatsUpdate(Map<String, dynamic> data) {
    _eventController?.add(MapEvent(
      type: MapEventType.regionalStatsUpdated,
      data: data,
    ));
  }

  void _handleRoomStatsUpdate(Map<String, dynamic> data) {
    _eventController?.add(MapEvent(
      type: MapEventType.roomStatsUpdated,
      data: data,
    ));
  }

  void _handleHeartbeat(Map<String, dynamic> data) {
    _eventController?.add(MapEvent(
      type: MapEventType.heartbeat,
      data: data,
    ));
  }

  void _handleServerShutdown(Map<String, dynamic> data) {
    print('Server shutdown notification received');
    _eventController?.add(MapEvent(
      type: MapEventType.serverShutdown,
      data: data,
    ));
    _scheduleReconnect();
  }

  void _handleServerError(Map<String, dynamic> data) {
    print('Server error: ${data['message']}');
    _eventController?.add(MapEvent(
      type: MapEventType.error,
      data: data,
    ));
  }

  void _handleError(error) {
    print('WebSocket error: $error');
    _isConnected = false;
    _eventController?.add(MapEvent(
      type: MapEventType.error,
      data: {'message': error.toString()},
    ));
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    print('WebSocket disconnected');
    _isConnected = false;
    _eventController?.add(MapEvent(
      type: MapEventType.disconnected,
      data: {},
    ));
    _scheduleReconnect();
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(json.encode(message));
      } catch (e) {
        print('Error sending WebSocket message: $e');
      }
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isConnected) {
        _sendMessage({
          'type': 'heartbeat',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _scheduleReconnect() {
    _stopReconnect();
    _reconnectTimer = Timer(Duration(seconds: 5), () {
      if (!_isConnected) {
        print('Attempting to reconnect...');
        connect();
      }
    });
  }

  void _stopReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  void dispose() {
    disconnect();
    _eventController?.close();
    _statsController?.close();
    _emotionController?.close();
  }
}

enum MapEventType {
  connected,
  disconnected,
  newEmotion,
  globalStatsUpdated,
  regionalStatsUpdated,
  roomStatsUpdated,
  heartbeat,
  serverShutdown,
  error,
}

class MapEvent {
  final MapEventType type;
  final dynamic data;

  MapEvent({
    required this.type,
    required this.data,
  });

  @override
  String toString() {
    return 'MapEvent(type: $type, data: $data)';
  }
} 