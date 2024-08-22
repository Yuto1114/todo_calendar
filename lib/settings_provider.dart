import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 設定プロバイダー
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier();
});

// 設定を管理するモデル
class Settings {
  String language;
  String theme;
  bool notifyDayBefore;
  bool notifyOnTheDay;
  String dayBeforeTime;
  String onTheDayTime;

  // 初期値
  Settings({
    this.language = 'English',
    this.theme = 'Light',
    this.notifyDayBefore = false,
    this.notifyOnTheDay = false,
    this.dayBeforeTime = '09:00',
    this.onTheDayTime = '09:00',
  });
}

// 更新やロードを管理するStateNotifier
class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(Settings()) {
    // コンストラクタを作成し初期化時に_loadSettings関数を実行
    _loadSettings();
  }

  // 初期化用ロード関数
  Future<void> _loadSettings() async {
    // ローカルからデータを取得
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language') ?? 'English';
    final theme = prefs.getString('theme') ?? 'Light';
    final notifyDayBefore = prefs.getBool('notifyDayBefore') ?? false;
    final notifyOnTheDay = prefs.getBool('notifyOnTheDay') ?? false;
    final dayBeforeTime = prefs.getString('dayBeforeTime') ?? '09:00';
    final onTheDayTime = prefs.getString('onTheDayTime') ?? '09:00';
    // ステートに代入
    state = Settings(
        language: language,
        theme: theme,
        notifyDayBefore: notifyDayBefore,
        notifyOnTheDay: notifyOnTheDay,
        dayBeforeTime: dayBeforeTime,
        onTheDayTime: onTheDayTime);
  }

  // アップデート関数
  Future<void> updateSettings({
    String? language,
    String? theme,
    bool? notifyDayBefore,
    bool? notifyOnTheDay,
    String? dayBeforeTime,
    String? onTheDayTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // 引数として与えられた項目のみを更新
    final newSettings = Settings(
      language: language ?? state.language,
      theme: theme ?? state.theme,
      notifyDayBefore: notifyDayBefore ?? state.notifyDayBefore,
      notifyOnTheDay: notifyOnTheDay ?? state.notifyOnTheDay,
      dayBeforeTime: dayBeforeTime ?? state.dayBeforeTime,
      onTheDayTime: onTheDayTime ?? state.onTheDayTime,
    );

    // 新しい設定で上書き
    state = newSettings;

    // ローカルデータの方も上書き
    await prefs.setString('language', newSettings.language);
    await prefs.setString('theme', newSettings.theme);
    await prefs.setBool('notifyDayBefore', newSettings.notifyDayBefore);
    await prefs.setBool('notifyOnTheDay', newSettings.notifyOnTheDay);
    await prefs.setString('dayBeforeTime', newSettings.dayBeforeTime);
    await prefs.setString('onTheDayTime', newSettings.onTheDayTime);
  }
}
