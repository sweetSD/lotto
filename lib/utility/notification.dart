import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
final androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
final iosSetting = IOSInitializationSettings();
final initializeSettings = InitializationSettings(android: androidSetting, iOS: iosSetting);

final androidWeeklyNoti = AndroidNotificationDetails(
  'weekly_notification', '주간 알림', '매주 토요일 로또 알림을 보냅니다.', importance: Importance.max
);

Future<void> scheduleWeeklyNotification() async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    1,
    '아직 로또 구매 안 하셨나요?',
    '오후 8시 45분에 로또 추첨이 진행됩니다. 오늘도 대박을 노려봅시다.',
    _nextInstanceOfSaturday(12, 0, 0),
    NotificationDetails(
      android: androidWeeklyNoti,
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    2,
    '로또 추첨이 진행되었습니다.',
    '어서 확인해 보세요!',
    _nextInstanceOfSaturday(20, 55, 0),
    NotificationDetails(
      android: androidWeeklyNoti,
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime
  );
}

tz.TZDateTime _nextInstanceOfTime(int hour, int minute, int second) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute, second);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

tz.TZDateTime _nextInstanceOfSaturday([int hour = 12, int minute = 0, int second = 0]) {
  tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute, second);
  while (scheduledDate.weekday != DateTime.saturday) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}