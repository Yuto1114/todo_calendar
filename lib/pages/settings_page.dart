import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_calendar/settings_provider.dart';
import 'package:todo_calendar/pages/language_settings_page.dart';
import 'package:todo_calendar/pages/notification_settings_page.dart';

class SettingsMainPage extends ConsumerWidget {
  const SettingsMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider);
    final language = settings.language;
    final isDarkTheme = settings.theme == 'Dark';

    // 言語に応じたテキスト
    String settingsTitle = language == 'English' ? 'Settings' : '設定';
    String languageSettingsTitle =
        language == 'English' ? 'Language Settings' : '言語設定';
    String notificationSettingsTitle =
        language == 'English' ? 'Notification Settings' : '通知設定';
    String themeLabel = language == 'English' ? 'Theme' : 'テーマ';

    return Scaffold(
      appBar: AppBar(
        title: Text(settingsTitle),
        actions: [
          Text(themeLabel, style: TextStyle(color: colorScheme.primary)),
          // テーマ切り替えスイッチ
          Switch(
            value: isDarkTheme,
            onChanged: (value) {
              final newTheme = value ? 'Dark' : 'Light';
              ref
                  .read(settingsProvider.notifier)
                  .updateSettings(theme: newTheme);
            },
            activeColor: colorScheme.primary,
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(languageSettingsTitle),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSettingsPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(notificationSettingsTitle),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
