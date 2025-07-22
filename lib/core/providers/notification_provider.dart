// lib/core/providers/notification_provider.dart
import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _notifications.length;
  bool get hasNotifications => _notifications.isNotEmpty;

  void addNotification({
    required String senderName,
    required String content,
    String? senderId,
    DateTime? sentAt,
  }) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'senderName': senderName,
      'content': content,
      'senderId': senderId,
      'sentAt': (sentAt ?? DateTime.now()).toIso8601String(),
      'isRead': false,
    };
    
    _notifications.insert(0, notification);
    notifyListeners();
    
    print('📱 Added notification from $senderName: $content');
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
    print('📱 Cleared all notifications');
  }

  void handleIncomingMessage({
    required String senderId,
    required String senderName,
    required String messageContent,
  }) {
    addNotification(
      senderName: senderName,
      content: messageContent.length > 50 
          ? '${messageContent.substring(0, 50)}...' 
          : messageContent,
      senderId: senderId,
    );
  }
}