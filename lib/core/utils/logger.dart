import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';

class Logger {
  static bool _initialized = false;
  static bool _enableFileLogging = false;
  static final List<LogEntry> _logHistory = [];
  static const int _maxHistorySize = 1000;
  static LogLevel _currentLevel = LogLevel.info;

  static const Map<LogLevel, int> _levelPriorities = {
    LogLevel.debug: 700,
    LogLevel.info: 800,
    LogLevel.warning: 900,
    LogLevel.error: 1000,
    LogLevel.critical: 1100,
  };

  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';
  static const String _bold = '\x1B[1m';

  static void init({
    LogLevel level = LogLevel.info,
    bool enableFileLogging = false,
    bool clearPreviousLogs = false,
  }) {
    if (_initialized && !clearPreviousLogs) return;
    
    _initialized = true;
    _currentLevel = level;
    _enableFileLogging = enableFileLogging;

    if (clearPreviousLogs) {
      _logHistory.clear();
    }

    if (kDebugMode) {
      info('🚀 Logger initialized - Level: ${level.name}, File logging: $enableFileLogging');
      info('📱 Platform: ${Platform.operatingSystem}, Debug mode: $kDebugMode');
    }
  }

  static void debug(String message, [dynamic data]) {
    if (!_shouldLog(LogLevel.debug)) return;
    
    _log(
      level: LogLevel.debug,
      message: message,
      data: data,
      emoji: '🐛',
      color: _cyan,
    );
  }

  static void info(String message, [dynamic data]) {
    if (!_shouldLog(LogLevel.info)) return;
    
    _log(
      level: LogLevel.info,
      message: message,
      data: data,
      emoji: 'ℹ️',
      color: _blue,
    );
  }

  static void warning(String message, [dynamic data]) {
    if (!_shouldLog(LogLevel.warning)) return;
    
    _log(
      level: LogLevel.warning,
      message: message,
      data: data,
      emoji: '.',
      color: _yellow,
    );
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_shouldLog(LogLevel.error)) return;
    
    _log(
      level: LogLevel.error,
      message: message,
      data: error,
      stackTrace: stackTrace,
      emoji: '.',
      color: _red,
    );
  }

  static void critical(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(
      level: LogLevel.critical,
      message: message,
      data: error,
      stackTrace: stackTrace,
      emoji: '🚨',
      color: _red,
      forcePrint: true,
    );
  }

  static void http({
    required String method,
    required String url,
    int? statusCode,
    Map<String, dynamic>? headers,
    dynamic body,
    Duration? duration,
    bool isRequest = true,
  }) {
    if (!_shouldLog(LogLevel.debug)) return;

    final direction = isRequest ? '🌐 →' : '🌐 ←';
    final status = statusCode != null ? ' [$statusCode]' : '';
    final time = duration != null ? ' (${duration.inMilliseconds}ms)' : '';
    
    final message = '$direction $method $url$status$time';
    
    debug(message, {
      'headers': headers,
      'body': body,
      'duration_ms': duration?.inMilliseconds,
    });
  }

  static void navigation(String action, String route, [Map<String, dynamic>? data]) {
    if (!_shouldLog(LogLevel.info)) return;
    
    info('🧭 $action: $route', data);
  }

  static void bloc(String blocName, String event, String state, [dynamic data]) {
    if (!_shouldLog(LogLevel.debug)) return;
    
    debug('🔄 $blocName: $event → $state', data);
  }

  static void performance(String operation, Duration duration, [Map<String, dynamic>? metrics]) {
    if (!_shouldLog(LogLevel.info)) return;
    
    final message = '⚡ $operation completed in ${duration.inMilliseconds}ms';
    info(message, metrics);
  }

  static void userAction(String action, [Map<String, dynamic>? data]) {
    if (!_shouldLog(LogLevel.info)) return;
    
    info('. User: $action', data);
  }

  static void database(String operation, [Map<String, dynamic>? data]) {
    if (!_shouldLog(LogLevel.debug)) return;
    
    debug('. DB: $operation', data);
  }

  static void cache(String operation, String key, [dynamic data]) {
    if (!_shouldLog(LogLevel.debug)) return;
    
    debug('📦 Cache: $operation ($key)', data);
  }

  static void auth(String event, [Map<String, dynamic>? data]) {
    if (!_shouldLog(LogLevel.info)) return;
    
    final sanitizedData = data != null ? _sanitizeAuthData(data) : null;
    info('🔐 Auth: $event', sanitizedData);
  }

  static void _log({
    required LogLevel level,
    required String message,
    dynamic data,
    StackTrace? stackTrace,
    required String emoji,
    required String color,
    bool forcePrint = false,
  }) {
    final timestamp = DateTime.now();
    final logEntry = LogEntry(
      timestamp: timestamp,
      level: level,
      message: message,
      data: data,
      stackTrace: stackTrace,
    );

    _addToHistory(logEntry);

    final formattedMessage = _formatMessage(
      timestamp: timestamp,
      level: level,
      message: message,
      emoji: emoji,
      color: color,
    );

    final priority = _levelPriorities[level] ?? 800;

    if (kDebugMode || forcePrint) {
      if (data != null) {
        developer.log(
          formattedMessage,
          name: 'EMORA_${level.name.toUpperCase()}',
          level: priority,
          error: data is Exception ? data : null,
          stackTrace: stackTrace,
        );
        
        if (data is! Exception) {
          developer.log(
            '   . Data: ${_formatData(data)}',
            name: 'EMORA_DATA',
            level: priority,
          );
        }
      } else {
        developer.log(
          formattedMessage,
          name: 'EMORA_${level.name.toUpperCase()}',
          level: priority,
          error: data is Exception ? data : null,
          stackTrace: stackTrace,
        );
      }

      if (stackTrace != null && data is! Exception) {
        developer.log(
          '   📚 Stack Trace:\n$stackTrace',
          name: 'EMORA_STACK',
          level: priority,
        );
      }
    }

    if (_enableFileLogging) {
      _writeToFile(logEntry);
    }
  }

  static String _formatMessage({
    required DateTime timestamp,
    required LogLevel level,
    required String message,
    required String emoji,
    required String color,
  }) {
    final timeStr = _formatTime(timestamp);
    final levelStr = level.name.toUpperCase().padRight(8);
    
    if (kDebugMode) {
      return '$color$_bold$emoji $levelStr$_reset$color | $timeStr | $message$_reset';
    } else {
      return '$emoji $levelStr | $timeStr | $message';
    }
  }

  static String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}.'
           '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }

  static String _formatData(dynamic data) {
    if (data == null) return 'null';
    if (data is String) return '"$data"';
    if (data is Map || data is List) {
      try {
        return data.toString();
      } catch (e) {
        return 'Unable to serialize data: $e';
      }
    }
    return data.toString();
  }

  static void _addToHistory(LogEntry entry) {
    _logHistory.add(entry);
    
    if (_logHistory.length > _maxHistorySize) {
      _logHistory.removeAt(0);
    }
  }

  static void _writeToFile(LogEntry entry) {
  }

  static bool _shouldLog(LogLevel level) {
    if (!_initialized) init();
    
    final currentPriority = _levelPriorities[_currentLevel] ?? 800;
    final messagePriority = _levelPriorities[level] ?? 800;
    
    return messagePriority >= currentPriority;
  }

  static Map<String, dynamic> _sanitizeAuthData(Map<String, dynamic> data) {
    final sanitized = Map<String, dynamic>.from(data);
    
    const sensitiveFields = [
      'password',
      'token',
      'access_token',
      'refresh_token',
      'secret',
      'key',
      'api_key',
    ];
    
    for (final field in sensitiveFields) {
      if (sanitized.containsKey(field)) {
        sanitized[field] = '[REDACTED]';
      }
    }
    
    return sanitized;
  }


  static LogLevel get currentLevel => _currentLevel;

  static void setLevel(LogLevel level) {
    _currentLevel = level;
    info('. Log level changed to: ${level.name}');
  }

  static List<LogEntry> getHistory({LogLevel? level, int? limit}) {
    var filtered = _logHistory;
    
    if (level != null) {
      filtered = filtered.where((entry) => entry.level == level).toList();
    }
    
    if (limit != null && limit > 0) {
      final startIndex = filtered.length > limit ? filtered.length - limit : 0;
      filtered = filtered.sublist(startIndex);
    }
    
    return List.unmodifiable(filtered);
  }

  static void clearHistory() {
    _logHistory.clear();
    info('🗑️ Log history cleared');
  }

  static String exportLogs({LogLevel? level, int? limit}) {
    final entries = getHistory(level: level, limit: limit);
    final buffer = StringBuffer();
    
    buffer.writeln('EMORA App Logs Export');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total entries: ${entries.length}');
    buffer.writeln('${'=' * 50}');
    
    for (final entry in entries) {
      buffer.writeln(entry.toString());
      if (entry.data != null) {
        buffer.writeln('  Data: ${_formatData(entry.data)}');
      }
      if (entry.stackTrace != null) {
        buffer.writeln('  Stack Trace:');
        buffer.writeln('    ${entry.stackTrace.toString().replaceAll('\n', '\n    ')}');
      }
      buffer.writeln('${'-' * 30}');
    }
    
    return buffer.toString();
  }

  static Map<String, dynamic> getStats() {
    final stats = <LogLevel, int>{};
    for (final level in LogLevel.values) {
      stats[level] = 0;
    }
    
    for (final entry in _logHistory) {
      stats[entry.level] = (stats[entry.level] ?? 0) + 1;
    }
    
    return {
      'initialized': _initialized,
      'current_level': _currentLevel.name,
      'file_logging_enabled': _enableFileLogging,
      'total_entries': _logHistory.length,
      'max_history_size': _maxHistorySize,
      'level_counts': stats.map((k, v) => MapEntry(k.name, v)),
'memory_usage_kb': (_logHistory.length * 100) ~/ 1024, 
    };
  }

  static void printStats() {
    final stats = getStats();
    info('. Logger Statistics:');
    stats.forEach((key, value) {
      info('   $key: $value');
    });
  }

  static bool get isInitialized => _initialized;

  static void setFileLogging(bool enabled) {
    _enableFileLogging = enabled;
    info('📁 File logging ${enabled ? 'enabled' : 'disabled'}');
  }
}


enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final dynamic data;
  final StackTrace? stackTrace;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.data,
    this.stackTrace,
  });

  @override
  String toString() {
    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}:'
                   '${timestamp.minute.toString().padLeft(2, '0')}:'
                   '${timestamp.second.toString().padLeft(2, '0')}.'
                   '${timestamp.millisecond.toString().padLeft(3, '0')}';
    
    return '${level.name.toUpperCase().padRight(8)} | $timeStr | $message';
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
      'data': data?.toString(),
      'has_stack_trace': stackTrace != null,
    };
  }
}


extension LoggerExtension on Object {
  void logInfo(String message) => Logger.info('${runtimeType}: $message');
  void logWarning(String message) => Logger.warning('${runtimeType}: $message');
  void logError(String message, [dynamic error, StackTrace? stackTrace]) => 
      Logger.error('${runtimeType}: $message', error, stackTrace);
  void logDebug(String message) => Logger.debug('${runtimeType}: $message');
}

extension DurationLogging on Duration {
  void logPerformance(String operation, [Map<String, dynamic>? metrics]) =>
      Logger.performance(operation, this, metrics);
}