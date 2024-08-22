import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

// ToDoItemリストを管理するプロバイダー
final todoListProvider =
    StateNotifierProvider<TodoListNotifier, List<TodoItem>>((ref) {
  return TodoListNotifier();
});

// 設定を管理するモデル
class TodoItem {
  String id;
  bool isChecked;
  String title;
  DateTime dateTime;

  // 初期化
  TodoItem({
    String? id,
    this.isChecked = false,
    this.title = '',
    DateTime? dateTime,
  })  : id = id ?? const Uuid().v4(),
        dateTime = dateTime ?? DateTime.now();

  // JSON変換のためのメソッド
  Map<String, dynamic> toJson() => {
        'id': id,
        'isChecked': isChecked,
        'title': title,
        'dateTime': dateTime.toIso8601String(),
      };

  static TodoItem fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'],
        isChecked: json['isChecked'],
        title: json['title'],
        dateTime: DateTime.parse(json['dateTime']),
      );

  // 引数で受け取ったものだけ上書きしたものを返す関数
  TodoItem copyWith({
    String? id,
    bool? isChecked,
    String? title,
    DateTime? dateTime,
  }) {
    return TodoItem(
      id: id ?? this.id,
      isChecked: isChecked ?? this.isChecked,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
// List<TodoItem>の状態を管理
class TodoListNotifier extends StateNotifier<List<TodoItem>> {
  TodoListNotifier() : super([]) {
    _loadToDoItems();
  }

  // ロード関数
  Future<void> _loadToDoItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedItems = prefs.getStringList('todoItems') ?? [];

    final List<TodoItem> loadedItems = savedItems.map((item) {
      final Map<String, dynamic> json = jsonDecode(item);
      return TodoItem.fromJson(json);
    }).toList();

    state = loadedItems;
  }

  // TodoItemを追加する関数
  Future<void> addTodoItem(TodoItem newItem) async {
    state = [...state, newItem];
    await _saveToPreferences();
  }

  // TodoItemを削除する関数
  Future<void> deleteTodoItem(String id) async {
    state = state.where((item) => item.id != id).toList();
    await _saveToPreferences();
  }

  // TodoItemのチェック状態を切り替える関数
  Future<void> checkTodoItem(String id) async {
    state = state.map((item) {
      if (item.id == id) {
        return TodoItem(
          id: item.id,
          isChecked: !item.isChecked, // チェック状態を切り替える
          title: item.title,
          dateTime: item.dateTime,
        );
      }
      return item;
    }).toList();

    await _saveToPreferences(); // チェック状態の変更を保存
  }

  // TodoItemを更新する関数
  void updateTodoItem(TodoItem updatedItem) {
    state = state.map((item) {
      return item.id == updatedItem.id ? updatedItem : item;
    }).toList();
    _saveToPreferences(); // 必要に応じてローカルに保存
  }

  // ローカルに保存する関数
  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> itemStrings = state.map((item) {
      return jsonEncode(item.toJson());
    }).toList();

    await prefs.setStringList('todoItems', itemStrings);
  }
}
