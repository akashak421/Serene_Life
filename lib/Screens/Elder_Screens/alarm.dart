import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

class MedicationReminder {

  // static Future<void> schedulePeriodicReminder(int hour, int minute,int alarmId) async {
  //   await AndroidAlarmManager.periodic(
  //     const Duration(seconds: 10),
  //     alarmId,
  //     _alarmCallback,
  //     startAt:DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
  //     exact: true,
  //     wakeup: true,
  //   );
  // }

  // static Duration _calculateInitialDelay(int hour, int minute) {
  //   DateTime now = DateTime.now();
  //   DateTime scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
  //   if (scheduledDate.isBefore(now)) {
  //     scheduledDate = scheduledDate.add(Duration(days: 1));
  //   }
  //   return scheduledDate.difference(now);
  // }
static Future<void> cancel() async {
  await AndroidAlarmManager.cancel(0);
  print('alarm canceled');
  }


  static Future<void> _alarmCallback() async {
    DateTime now = DateTime.now();
    print("Alarm fired at $now");
  }
}
