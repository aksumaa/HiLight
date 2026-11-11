import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

final _plugin = FlutterLocalNotificationsPlugin();
var _ready = false;

Future<void> scheduleDailyReview({
  required int hour,
  required int minute,
  required String title,
  required String body,
}) async {
  if (!_ready) {
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: false, sound: true);
    _ready = true;
  }
  final now = tz.TZDateTime.now(tz.local);
  var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (!when.isAfter(now)) when = when.add(const Duration(days: 1));
  await _plugin.zonedSchedule(
    1,
    title,
    body,
    when,
    const NotificationDetails(
      iOS: DarwinNotificationDetails(),
      android: AndroidNotificationDetails('review', 'Review'),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}
