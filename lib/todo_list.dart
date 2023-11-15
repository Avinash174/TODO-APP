import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/add_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List items = [];

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isLoading,
        child:  Center(
          child: CircularProgressIndicator(),
        ),
        replacement: RefreshIndicator(
          color: Colors.white,
          onRefresh: fetchTodo,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              final item = items[index] as Map;
              final id = item['_id'] as String;
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(
                  item['title'],
                ),
                subtitle: Text(item['description']),
                trailing: PopupMenuButton(onSelected: (value) {
                  if (value == 'edit') {
                    navigatoreditPage(item);
                  } else if (value == 'delete') {
                    deleteById(id);
                  }
                }, itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      child: Text('Edit'),
                      value: 'edit',
                    ),
                    const PopupMenuItem(
                      child: Text('Delete'),
                      value: 'delete',
                    ),
                  ];
                }),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AddTodoPage()));
        },
        label: const Text('Add Todo'),
      ),
    );
  }

  void showErrorMessage(String msg) {
    final snackBar = SnackBar(
      content: Text(
        msg,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> deleteById(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filterItem =
          items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filterItem;
      });
    } else {
      showErrorMessage('Deletion Failed');
    }
  }

  Future<void> navigatoreditPage(Map item) async {
    final routes = MaterialPageRoute(
      builder: (_) => AddTodoPage(todo: item),
    );
    Navigator.push(context, routes);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigatoraddPage(Map item) async {
    final routes = MaterialPageRoute(
      builder: (_) => AddTodoPage(todo: item),
    );
    Navigator.push(context, routes);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> fetchTodo() async {
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=20';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    } else {}

    setState(() {
      isLoading = false;
    });
    // log(response.toString());
    // log(response.statusCode.toString());
  }
}
