import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_calendar/pages/add_page.dart';
import 'package:todo_calendar/items_provider.dart';
import 'package:todo_calendar/settings_provider.dart';
import 'package:todo_calendar/pages/detail_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(); // 追加: ローカル通知プラグインのインスタンス

class TodoListPage extends ConsumerStatefulWidget {
  const TodoListPage({super.key});

  @override
  ConsumerState<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends ConsumerState<TodoListPage> {
  DateTime _selectedDay = DateTime.now(); // 初期選択日を現在の日付に設定


  void _addToDo(BuildContext context, DateTime selectedDay) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddToDoPage(selectedDay: selectedDay),
      ),
    );

    if (result != null && result is TodoItem) {
      // 結果が戻ってきた場合は、ToDoItemを追加
      ref.read(todoListProvider.notifier).addTodoItem(result);
    }
  }

  Future<void> navigateToDetailPage(BuildContext context, TodoItem todoItem) async {
    final updatedItem = await Navigator.push<TodoItem>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(todoItem: todoItem),
      ),
    );

    if (updatedItem != null) {
      // 更新されたアイテムで状態を更新
      ref.read(todoListProvider.notifier).updateTodoItem(updatedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider); // プロバイダーから言語を取得
    final String locale = settings.language == 'English' ? 'en_US' : 'ja_JP'; // ロケール設定
    // todoListProvider を使用して ToDoItem リストをフィルタリング
    final List<TodoItem> filteredItems = ref.watch(todoListProvider).where((item) {
      // item の dateTime の日付が _selectedDay と一致するかを確認
      return item.dateTime.year == _selectedDay.year &&
          item.dateTime.month == _selectedDay.month &&
          item.dateTime.day == _selectedDay.day;
    }).toList();

    // 時間の早い順にソート
    filteredItems.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // ToDoリストを取得
    final todoList = ref.watch(todoListProvider);

    // 日付ごとにToDoが存在するかを検知するマップを作成
    final Set<DateTime> daysWithTodo = todoList.map((item) => DateTime(
      item.dateTime.year,
      item.dateTime.month,
      item.dateTime.day,
    )).toSet();

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            TableCalendar(
              locale: locale,
              // 言語設定を反映
              focusedDay: _selectedDay,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 3, 31),

              //ある日にちが変数_selectedDayと同じ日(isSameDay)だったらtrueを返す。デフォルトではtrueの時は色がつく
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },

              //日にちが選択された際その日にちを_selectedDayに代入
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, date, _) {
                  // 時刻を無視して日付を比較するために、daysWithTodoの形式を統一
                  bool isDayWithTodo = daysWithTodo.contains(
                    DateTime(date.year, date.month, date.day),
                  );
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDayWithTodo
                          ? Colors.orange.withOpacity(0.6)
                          : null, // ToDoがある日は赤背景
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isDayWithTodo
                            ? Colors.white
                            : null, // ToDoがある日は白色テキスト
                      ),
                    ),
                  );
                },
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 19.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                weekendStyle: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(
                  color: colorScheme.inverseSurface,
                ),
                weekendTextStyle: TextStyle(
                  color: colorScheme.inverseSurface,
                ),
                disabledTextStyle: TextStyle(
                  color: colorScheme.inverseSurface.withOpacity(0.5),
                ),
                selectedDecoration: BoxDecoration(
                  color: colorScheme.inversePrimary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold),
                todayTextStyle:
                TextStyle(color: colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    TodoItem item = filteredItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Transform.scale(
                          scale: 1.3,
                          child: Checkbox(
                            value: item.isChecked,
                            onChanged: (bool? value) {
                              // チェック状態の変更をプロバイダ経由で行う
                              ref.read(todoListProvider.notifier).checkTodoItem(item.id);
                            },
                          ),
                        ),
                        title: Text(item.title),
                        subtitle: Text(DateFormat('HH:mm').format(item.dateTime)), // 時間表示を修正
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // アイテムの削除をプロバイダ経由で行う
                            ref.read(todoListProvider.notifier).deleteTodoItem(item.id);
                          },
                        ),
                        onTap: () async {
                          navigateToDetailPage(context, item);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(
              height: 15,
            )
          ],
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(-20, -20),
        child: FloatingActionButton(
          onPressed: () {
            _addToDo(context, _selectedDay);
          },
          backgroundColor: colorScheme.primary,
          child: Icon(
            Icons.add,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}