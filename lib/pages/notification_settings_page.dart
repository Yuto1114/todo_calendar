import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_calendar/pages/todo_page.dart';
import 'package:todo_calendar/settings_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:todo_calendar/items_provider.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  late bool _notifyDayBefore;
  late bool _notifyOnTheDay;
  late TimeOfDay _dayBeforeTime; // 1日前の通知時間
  late TimeOfDay _onTheDayTime; // 当日の通知時間

  @override
  void initState() {
    super.initState();
    _loadSettings(); // 初期設定を読み込む
  }


  // 設定を読み込む関数
  void _loadSettings() {
    final settings = ref.read(settingsProvider);
    _notifyDayBefore = settings.notifyDayBefore;
    _notifyOnTheDay = settings.notifyOnTheDay;
    _dayBeforeTime = _parseTime(settings.dayBeforeTime);
    _onTheDayTime = _parseTime(settings.onTheDayTime);
  }



  // 時間をパースする関数
  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // 通知を再スケジュールする関数
  Future<void> _rescheduleNotifications() async {
    // 既存の通知を全てキャンセル
    await flutterLocalNotificationsPlugin.cancelAll();

    // 新しい通知をスケジュール
    await scheduleDailyNotifications();
  }

  Future<List<TodoItem>> loadTodoItems() async {
    final todoList = ref.read(todoListProvider);
    return todoList;
  }

  // 通知をスケジュールする関数
  Future<void> scheduleDailyNotifications() async {
    final List<TodoItem> todoItems = await loadTodoItems(); // すべてのToDoアイテムを取得
    final now = DateTime.now();

    // 1日前の通知
    if (_notifyDayBefore) {
      final DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day - 1,
        _dayBeforeTime.hour,
        _dayBeforeTime.minute,
      ); // 1日前の設定した時間
      final List<String> titles = todoItems
          .where((item) => isSameDay(
              item.dateTime, DateTime.now().add(const Duration(days: 1))))
          .map((item) => item.title)
          .toList();

      if (titles.isNotEmpty) {
        await _scheduleNotification(scheduledTime, titles.join(', '));
      }
    }

    // 当日の通知
    if (_notifyOnTheDay) {
      final DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        _onTheDayTime.hour,
        _onTheDayTime.minute,
      ); // 当日の設定した時間
      final List<String> titles = todoItems
          .where((item) => isSameDay(item.dateTime, DateTime.now()))
          .map((item) => item.title)
          .toList();

      if (titles.isNotEmpty) {
        await _scheduleNotification(scheduledTime, titles.join(', '));
      }
    }
  }

  // 通知をスケジュールする内部関数
  Future<void> _scheduleNotification(
      DateTime scheduledTime, String message) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // 通知ID。ユニークなIDを設定
      'ToDo Reminder', // 通知のタイトル
      message, // 通知メッセージ
      tz.TZDateTime.from(scheduledTime, tz.local), // 通知をスケジュールする時刻
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id', // チャンネルID
          'your_channel_name', // チャンネル名
          channelDescription: 'your_channel_description', // チャンネルの説明
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 日時のコンポーネントで一致させる
    );
  }

  // 通知時間を選択するダイアログ
  Future<void> _pickTime(BuildContext context, bool isDayBefore) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isDayBefore ? _dayBeforeTime : _onTheDayTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          // 24時間制を強制
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDayBefore) {
          _dayBeforeTime = picked;
        } else {
          _onTheDayTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final String language = settings.language;

    // 言語に応じたテキスト
    String pageTitle = language == 'English' ? 'Notification Settings' : '通知設定';
    String notifyDayBeforeLabel =
        language == 'English' ? 'Notify 1 day before' : '1日前に通知';
    String notifyOnTheDayLabel =
        language == 'English' ? 'Notify on the day' : '当日に通知';
    String saveButtonLabel = language == 'English' ? 'Save Settings' : '設定を保存';
    String timePickerLabel = language == 'English' ? 'Choose time' : '時間を選択';

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(notifyDayBeforeLabel),
              value: _notifyDayBefore,
              onChanged: (bool value) {
                setState(() {
                  _notifyDayBefore = value;
                });
              },
            ),
            if (_notifyDayBefore)
              ListTile(
                title: Text(timePickerLabel),
                subtitle: Text(_dayBeforeTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(context, true), // 1日前の時間を選択
              ),
            SwitchListTile(
              title: Text(notifyOnTheDayLabel),
              value: _notifyOnTheDay,
              onChanged: (bool value) {
                setState(() {
                  _notifyOnTheDay = value;
                });
              },
            ),
            if (_notifyOnTheDay)
              ListTile(
                title: Text(timePickerLabel),
                subtitle: Text(_onTheDayTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(context, false), // 当日の時間を選択
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 設定を更新してから通知を再スケジュール
                await ref.read(settingsProvider.notifier).updateSettings(
                      notifyDayBefore: _notifyDayBefore,
                      notifyOnTheDay: _notifyOnTheDay,
                      dayBeforeTime:
                          '${_dayBeforeTime.hour.toString().padLeft(2, '0')}:${_dayBeforeTime.minute.toString().padLeft(2, '0')}',
                      onTheDayTime:
                          '${_onTheDayTime.hour.toString().padLeft(2, '0')}:${_onTheDayTime.minute.toString().padLeft(2, '0')}',
                    );
                await _rescheduleNotifications(); // 通知を再スケジュール
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(language == 'English'
                          ? 'Notifications Scheduled'
                          : '通知がスケジュールされました'),
                    ),
                  );
                }
              },
              child: Text(saveButtonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
