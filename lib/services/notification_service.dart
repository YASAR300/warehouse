import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import '../models/container_model.dart';

/// Service for handling notifications and alerts
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;
  String? _adminEmail;

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      // Request permission for notifications
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        
        // Configure message handlers
        _setupMessageHandlers();
      }
    } catch (e) {
      throw Exception('Failed to initialize notification service: $e');
    }
  }

  /// Set admin email for notifications
  void setAdminEmail(String email) {
    _adminEmail = email;
  }

  /// Setup Firebase Cloud Messaging handlers
  void _setupMessageHandlers() {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    // Show toast notification for foreground messages
    Fluttertoast.showToast(
      msg: message.notification?.title ?? 'New notification',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  /// Handle notification taps
  void _handleNotificationTap(RemoteMessage message) {
    // Handle navigation based on notification data
    final data = message.data;
    if (data.containsKey('containerNumber')) {
      // Navigate to specific container
      // This would be handled by the app's navigation system
    }
  }

  /// Send email notification to admin about discrepancies
  Future<void> notifyAdminAboutDiscrepancies(ContainerModel container) async {
    if (_adminEmail == null || _adminEmail!.isEmpty) {
      throw Exception('Admin email not configured');
    }

    try {
      final email = Email(
        body: _buildDiscrepancyEmailBody(container),
        subject: 'Discrepancy Alert - Container ${container.containerNumber}',
        recipients: [_adminEmail!],
        isHTML: false,
      );

      await FlutterEmailSender.send(email);
    } catch (e) {
      throw Exception('Failed to send email notification: $e');
    }
  }

  /// Build email body for discrepancy notification
  String _buildDiscrepancyEmailBody(ContainerModel container) {
    final buffer = StringBuffer();
    
    buffer.writeln('DISCREPANCY ALERT');
    buffer.writeln('==================');
    buffer.writeln('');
    buffer.writeln('Container Number: ${container.containerNumber}');
    buffer.writeln('Type: ${container.type.displayName}');
    buffer.writeln('Door Number: ${container.doorNumber ?? 'Not specified'}');
    buffer.writeln('Date: ${DateTime.now().toString().split(' ')[0]}');
    buffer.writeln('');
    buffer.writeln('DISCREPANCIES REPORTED:');
    buffer.writeln('------------------------');
    
    if (container.discrepancies.isEmpty) {
      buffer.writeln('No discrepancies reported');
    } else {
      for (int i = 0; i < container.discrepancies.length; i++) {
        final discrepancy = container.discrepancies[i];
        buffer.writeln('${i + 1}. ${discrepancy.description}');
        buffer.writeln('   Reported: ${discrepancy.timestamp.toString()}');
        buffer.writeln('');
      }
    }
    
    buffer.writeln('');
    buffer.writeln('PIECE COUNT SUMMARY:');
    buffer.writeln('--------------------');
    buffer.writeln(container.pieceCountSummary);
    buffer.writeln('');
    buffer.writeln('MATERIALS SUPPLIED:');
    buffer.writeln('-------------------');
    if (container.materialsSupplied.isEmpty) {
      buffer.writeln('No materials recorded');
    } else {
      buffer.writeln(container.materialsSupplied.map((m) => m.displayName).join(', '));
    }
    
    if (container.shareableLink != null) {
      buffer.writeln('');
      buffer.writeln('SHAREABLE LINK:');
      buffer.writeln('---------------');
      buffer.writeln(container.shareableLink);
    }
    
    return buffer.toString();
  }

  /// Send push notification to admin
  Future<void> sendPushNotificationToAdmin({
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    // This would typically use a backend service to send FCM messages
    // For now, we'll just show a local toast
    Fluttertoast.showToast(
      msg: '$title: $body',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  /// Show local notification
  void showLocalNotification({
    required String title,
    required String body,
    Color? backgroundColor,
    Color? textColor,
  }) {
    Fluttertoast.showToast(
      msg: '$title: $body',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: backgroundColor ?? Colors.blue,
      textColor: textColor ?? Colors.white,
    );
  }

  /// Show success notification
  void showSuccessNotification(String message) {
    showLocalNotification(
      title: 'Success',
      body: message,
      backgroundColor: Colors.green,
    );
  }

  /// Show error notification
  void showErrorNotification(String message) {
    showLocalNotification(
      title: 'Error',
      body: message,
      backgroundColor: Colors.red,
    );
  }

  /// Show warning notification
  void showWarningNotification(String message) {
    showLocalNotification(
      title: 'Warning',
      body: message,
      backgroundColor: Colors.orange,
    );
  }

  /// Show info notification
  void showInfoNotification(String message) {
    showLocalNotification(
      title: 'Info',
      body: message,
      backgroundColor: Colors.blue,
    );
  }

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Subscribe to topic for notifications
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      throw Exception('Failed to subscribe to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      throw Exception('Failed to unsubscribe from topic: $e');
    }
  }

  /// Send notification about container completion
  Future<void> notifyContainerCompletion(ContainerModel container) async {
    final hasDiscrepancies = container.hasDiscrepancies;
    
    if (hasDiscrepancies) {
      // Notify admin about discrepancies
      await notifyAdminAboutDiscrepancies(container);
      
      // Also send push notification
      await sendPushNotificationToAdmin(
        title: 'Container Completed with Discrepancies',
        body: 'Container ${container.containerNumber} has been completed but contains discrepancies.',
        data: {
          'containerNumber': container.containerNumber,
          'type': 'discrepancy_alert',
        },
      );
    } else {
      // Send completion notification
      await sendPushNotificationToAdmin(
        title: 'Container Completed',
        body: 'Container ${container.containerNumber} has been completed successfully.',
        data: {
          'containerNumber': container.containerNumber,
          'type': 'completion',
        },
      );
    }
  }

  /// Send notification about offline sync
  Future<void> notifyOfflineSync(List<String> containerNumbers) async {
    await sendPushNotificationToAdmin(
      title: 'Offline Data Synced',
      body: '${containerNumbers.length} containers have been synced from offline queue.',
      data: {
        'type': 'offline_sync',
        'count': containerNumbers.length.toString(),
      },
    );
  }

  /// Send notification about sync errors
  Future<void> notifySyncError(String containerNumber, String error) async {
    await sendPushNotificationToAdmin(
      title: 'Sync Error',
      body: 'Failed to sync container $containerNumber: $error',
      data: {
        'containerNumber': containerNumber,
        'type': 'sync_error',
        'error': error,
      },
    );
  }
}

/// Background message handler for Firebase Cloud Messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here
  print('Handling background message: ${message.messageId}');
}
