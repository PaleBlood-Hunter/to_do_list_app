import 'package:flutter/material.dart';
import 'package:to_do_list_app/pages/todo_list_page.dart';


void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoListPage(),
      debugShowCheckedModeBanner: false,//TELA INICIAL DO MEU APP
    );
  }
}

