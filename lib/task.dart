import 'package:hive_flutter/adapters.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool done;

  Task({required this.title, this.done = false});
}