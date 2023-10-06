import 'package:flutter/material.dart';
import 'package:to_do_list_app/repositories/todo_repository.dart';
import 'package:to_do_list_app/widgets/todo_list_item.dart';

import '../models/todo.dart';

//WIDGET DA TELA DE INICIO DO MEU APP
class TodoListPage extends StatefulWidget {
  TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  //CREATE AN EMPTY LIST TASK
  List<Todo> to_do_tasks = [];

  //CREATE THE TEMPORARY VARIABLES TO DELETED TASKS
  Todo? deletedTodo;
  int? deletedTodoPos;
  List<Todo> deletedList = [];

  String? errorText;

  final TextEditingController to_do_controller = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        to_do_tasks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        //SCAFFOLD IS TEH MATERIAL WIDGET: THE BLANK PAGE WHERE IMAGES AND TEXTS ARE DRAWN
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: Expanded(
                          child:
                          Text('To do List:',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ),
                    ),
                  ]
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      //THE CONTROLLER IS USED TO PASS THE TYPED TEXT TO A VARIABLE
                      controller: to_do_controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Add a task",
                        hintText: "Go to the Supermarket",
                        errorText: errorText,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //ON PRESSED, ADD THE TEXT ON THE TEXTBOX TO THE TASKLIST
                      String text = to_do_controller.text;
                      if(text == '') {
                        setState(() {
                          errorText = "Please, add a name to the task!";
                        });

                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Your task name is empty!',
                                style: TextStyle(color: Colors.red),
                              ),
                              backgroundColor: Colors.white,
                            ),
                        );

                      }
                      else{
                        errorText = null;
                        //SETSTATE IS USED TO UPDATE THE SCREEN AFTER THE CHANGES
                        setState(() {
                          Todo newTodo = Todo(
                            title: text,
                            dateTime: DateTime.now(),
                          );
                          //ADD AN ITEM IN THE TO DO OBJECT LIST
                          to_do_tasks.add(newTodo);
                          todoRepository.SaveTodoList(to_do_tasks);
                        });
                        //CLEAN THE TEXT ON THE TEXTBOX WHEN PRESSED
                        to_do_controller.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff00d7f3),
                      padding: EdgeInsets.all(15),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (Todo to_do in to_do_tasks)
                      TodoListItem(
                        todo: to_do,
                        onDelete: onDelete,
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(
                      child:
                          Text('You have ${to_do_tasks.length} tasks to do')),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: showDeleteDialog,
                    child: Text('Clean All'),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff00d7f3),
                      padding: EdgeInsets.all(15),
                    ),
                  )
                ],
              )
            ],
          ),
        )),
      ),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoPos = to_do_tasks.indexOf(todo);

    setState(() {
      to_do_tasks.remove(todo);
    });

    todoRepository.SaveTodoList(to_do_tasks);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa ${todo.title} foi removida com sucesso',
          style: TextStyle(color: Color(0xff060708)),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: const Color(0xff00d7f3),
          onPressed: undo_delete,
        ),
      ),
    );
  }

  void undo_delete() {
    setState(() {
      to_do_tasks.insert(deletedTodoPos!, deletedTodo!);
    });

    todoRepository.SaveTodoList(to_do_tasks);
  }

  void undo_delete_list() {
    setState(() {
      to_do_tasks = List.from(deletedList);
    });

    todoRepository.SaveTodoList(to_do_tasks);
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clean All Tasks'),
        content: Text('Are you sure you want to delete all tasks?'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
          ),
          //DELETE THE ENTIRE TASK LIST
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                delete_all_todos();
              },
            style: TextButton.styleFrom(primary: Colors.red),
              child: Text('Clean All'),
          ),
        ],
      ),
    );
  }

  void delete_all_todos() {
    setState(() {
      //ADD THE DELETED LIST TO A TEMPORARY VARIABLE
      deletedList =  List.from(to_do_tasks);
      print('#####################################################################');
      print(deletedList);
      to_do_tasks.clear();
      todoRepository.SaveTodoList(to_do_tasks);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'All tasks have been removed',
            style: TextStyle(color: Color(0xff060708)),
          ),
          backgroundColor: Colors.white,
          action: SnackBarAction(
            label: 'Undo it',
            textColor: const Color(0xff00d7f3),
            onPressed: undo_delete_list,
          ),
        ),
      );
    });
  }
}
