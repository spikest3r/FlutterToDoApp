import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>("tasks");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Todo list'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Box<Task> box;

  @override
  void initState() {
    super.initState();
    box = Hive.box<Task>('tasks');
  }

  void addNewTask(String text) {
    final task = Task(title: text, done: false);
    box.add(task);
  }

  Widget buildList(Box<Task> box) {
    final keys = box.keys.toList();

    if (keys.isEmpty) {
      return const Center(
        child: Text(
          "The list is empty",
          style: TextStyle(fontSize: 30),
        ),
      );
    }

    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        final task = box.get(key)!;

        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Checkbox(
                value: task.done,
                onChanged: (val) {
                  final updatedTask = Task(title: task.title, done: val!);
                  box.put(key, updatedTask); // update by key
                },
              ),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    decoration:
                    task.done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  box.delete(key); // delete task
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final inputController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(onPressed: () {
                box.clear();
              }, child: const Text("Delete all")),
              SizedBox(width: 16),
              ElevatedButton(onPressed: () {
                final k = box.keys.toList();
                for(int i = 0; i < k.length; i++) {
                  final key = k[i];
                  final task = box.get(key)!;
                  if(!task.done) continue;
                  box.delete(key);
                }
              }, child: const Text("Delete finished"))
            ],)
          ),
          Expanded(
            child: ValueListenableBuilder<Box<Task>>(
              valueListenable: box.listenable(),
              builder: (context, box_, _) => buildList(box_),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: inputController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Task title',
              ),
              onSubmitted: (value) {
                if (value.trim().isEmpty) return;
                addNewTask(value.trim());
                inputController.clear();
              },
            ),
          ),
        ],
      ),
    );
  }
}
