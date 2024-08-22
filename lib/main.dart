import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:todo_calendar/pages/base_page.dart';
import 'package:todo_calendar/settings_provider.dart';
import 'package:todo_calendar/theme/theme.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  // Flutterのウィジェットバインディングを初期化します。
  // これにより、ウィジェットの操作を行う前にFlutterのサービスが利用可能になります。
  WidgetsFlutterBinding.ensureInitialized();

  // タイムゾーンのデータベースを初期化します。
  // これにより、アプリケーションで正確なタイムゾーン情報を使用できます。
  tz.initializeTimeZones();

  // Flutterのローカル通知プラグインを初期化します。
  FlutterLocalNotificationsPlugin()
    // Androidプラットフォーム固有の通知プラグインを解決し、通知の許可を要求します。
    ..resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission()
    // 通知プラグインの初期化を行います。
    ..initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // Android向けの初期設定
      iOS: DarwinInitializationSettings(), // iOS向けの初期設定
    ));

  // 日本語の日時フォーマットを初期化します。
  // 初期化が完了したら、Flutterアプリケーションを起動します。
  initializeDateFormatting('ja')
      .then((_) => runApp(const ProviderScope(child: MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    ThemeData myTheme(ColorScheme colorScheme) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        fontFamily: 'Noto Sans JP',
      );
    }

    final ThemeData themeData;
    if (settings.theme == 'Light') {
      themeData = myTheme(MaterialTheme.lightScheme());
    } else {
      themeData = myTheme(MaterialTheme.darkScheme());
    }

    return MaterialApp(
      title: 'Themed App',
      theme: themeData,
      home: const BasePage(),
    );
  }
}
