import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_calendar/pages/settings_page.dart';
import 'package:todo_calendar/pages/todo_page.dart';
import 'package:todo_calendar/settings_provider.dart';

class BasePage extends ConsumerStatefulWidget {
  const BasePage({super.key});

  @override
  ConsumerState<BasePage> createState() => _BasePageState();
}

class _BasePageState extends ConsumerState<BasePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // settingsProviderから言語を取得
    final settings = ref.watch(settingsProvider);
    final String language = settings.language;

    final List<Widget> screens = [
      const TodoListPage(),
      const SettingsMainPage(),
    ];

    void onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your ToDo', // 常に共通のタイトル
          style: TextStyle(color: colorScheme.primary),
        ),
        backgroundColor: colorScheme.surface,
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: colorScheme.primary,
            unselectedItemColor: Colors.grey, // 選択されていないアイテムの色
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          elevation: 0, // 影を消す
          backgroundColor: Colors.transparent, // 背景色を透明に
          onTap: onItemTapped,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'ToDo',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: language == 'Japanese' ? '設定' : 'Settings',
            ),
          ],
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
