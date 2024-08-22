import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_calendar/settings_provider.dart';
import 'package:todo_calendar/items_provider.dart';

class DetailPage extends ConsumerStatefulWidget {
  final TodoItem todoItem;

  const DetailPage({super.key, required this.todoItem});

  @override
  DetailPageState createState() => DetailPageState();
}

class DetailPageState extends ConsumerState<DetailPage> {
  late TextEditingController titleController;
  late TextEditingController timeController;
  TimeOfDay? selectedTime; // TimeOfDay を保持する変数

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.todoItem.title);
    selectedTime = TimeOfDay.fromDateTime(widget.todoItem.dateTime);
    timeController = TextEditingController(text: selectedTime!.format(context));
  }

  @override
  void dispose() {
    titleController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider); // プロバイダーから言語設定を取得
    final String language = settings.language;

    String titleLabel = language == 'Japanese' ? 'タイトル' : 'Title';
    String timeLabel = language == 'Japanese' ? '時間' : 'Time';

    return Scaffold(
      appBar: AppBar(
        title: Text(language == 'Japanese' ? 'ToDoを編集' : 'Edit ToDo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // タイトル入力フィールド
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: titleLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // 時間選択フィールド
            GestureDetector(
              onTap: () async {
                selectedTime = await showTimePicker(
                  context: context,
                  initialTime: selectedTime ?? TimeOfDay.now(),
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(alwaysUse24HourFormat: true), // 24時間制を強制
                      child: child!,
                    );
                  },
                );

                if (selectedTime != null && context.mounted) {
                  // 選択した時間をTextFieldに設定
                  timeController.text = selectedTime!.format(context);
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: timeLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (titleController.text.isNotEmpty && selectedTime != null) {
            // 選択された日付と時間を組み合わせてDateTimeを作成
            final date = DateTime(
              widget.todoItem.dateTime.year,
              widget.todoItem.dateTime.month,
              widget.todoItem.dateTime.day,
              selectedTime!.hour,
              selectedTime!.minute,
            );

            // ToDoItemを更新
            TodoItem updatedItem = widget.todoItem.copyWith(
              title: titleController.text,
              dateTime: date,
            );

            // updatedItem を Navigator.pop に渡す
            Navigator.pop(context, updatedItem);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  language == 'Japanese'
                      ? "タイトルと時間を入力してください"
                      : "Please enter both title and time",
                ),
              ),
            );
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
