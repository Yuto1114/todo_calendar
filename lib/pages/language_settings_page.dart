import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:todo_calendar/settings_provider.dart';

class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 現在の言語を取得
    final settings = ref.watch(settingsProvider);
    String language = settings.language;

    // 言語に応じたテキスト
    String pageTitle = language == 'English' ? 'Language Settings' : '言語設定';
    String englishButtonLabel = language == 'English' ? 'English' : '英語';
    String japaneseButtonLabel = language == 'English' ? 'Japanese' : '日本語';

    // 言語を更新する関数
    void updateLanguage(String newLanguage) {
      ref.read(settingsProvider.notifier).updateSettings(language: newLanguage);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => updateLanguage('English'),
                  child: Text(englishButtonLabel),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => updateLanguage('Japanese'),
                  child: Text(japaneseButtonLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}