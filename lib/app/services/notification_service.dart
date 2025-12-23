import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  static const int _notificationId = 1;
  DateTime? _lastIosUpdateTime;

  // 알림 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: false,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android 알림 채널 생성
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'quitting_timer_channel',
      '금연 타이머',
      description: '금연 시간을 실시간으로 표시합니다',
      importance: Importance.low,
      showBadge: false,
      enableVibration: false,
      playSound: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _isInitialized = true;
  }

  // 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    // 알림 탭 시 처리 (필요시 구현)
  }

  // 금연 시간 알림 업데이트
  Future<void> updateQuittingTimer(String elapsedTime) async {
    if (!_isInitialized) {
      await initialize();
    }

    // iOS에서는 알림 업데이트를 1분마다만 수행하여 소리/진동 방지
    if (Platform.isIOS) {
      final now = DateTime.now();
      if (_lastIosUpdateTime != null) {
        final difference = now.difference(_lastIosUpdateTime!);
        // 1분 미만이면 업데이트하지 않음
        if (difference.inSeconds < 60) {
          return;
        }
      }
      _lastIosUpdateTime = now;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'quitting_timer_channel',
          '금연 타이머',
          channelDescription: '금연 시간을 실시간으로 표시합니다',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          enableVibration: false,
          playSound: false,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
      interruptionLevel: InterruptionLevel.passive,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(_notificationId, '🚭 금연 중', elapsedTime, details);
  }

  // 알림 제거
  Future<void> cancelNotification() async {
    await _notifications.cancel(_notificationId);
  }
}
