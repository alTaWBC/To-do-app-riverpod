import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'todo.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

/// My APP
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

/// Main Page
class Home extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final newTodoController = useTextEditingController();
    final todos = useProvider(filteredTodos);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              children: [
                Title(),
                TextField(
                  controller: newTodoController,
                  decoration: InputDecoration(
                    labelText: 'What needs to be done?',
                  ),
                  onSubmitted: (value) {
                    context.read(todoListProvider).add(value);
                    newTodoController.clear();
                  },
                ),
                SizedBox(height: 42),
                Column(
                  children: [
                    ToolBar(),
                    if (todos.isNotEmpty)
                      const Divider(
                        height: 0,
                      ),
                    for (var i = 0; i < todos.length; i++) ...[
                      if (i > 0) const Divider(height: 0),
                      Dismissible(
                          key: ValueKey(todos[i].id),
                          onDismissed: (_) {
                            context.read(todoListProvider).remove(todos[i]);
                          },
                          child: ProviderScope(
                            overrides: [
                              currentTodo.overrideWithValue(todos[i]),
                            ],
                            child: TodoItem(),
                          ))
                    ]
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///
class ToolBar extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final filter = useProvider(todoListFilter);

    Color textColorFor(TodoListFilter value) {
      return filter.state == value ? Colors.blue : null;
    }

    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${useProvider(uncompletedTodosCount).toString()} items left',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Tooltip(
            message: 'All todos',
            child: FlatButton(
              onPressed: () => filter.state = TodoListFilter.all,
              visualDensity: VisualDensity.comfortable,
              textColor: textColorFor(TodoListFilter.all),
              child: Text('All'),
            ),
          ),
          Tooltip(
            message: 'Only uncompleted todos',
            child: FlatButton(
              onPressed: () => filter.state = TodoListFilter.active,
              visualDensity: VisualDensity.compact,
              textColor: textColorFor(TodoListFilter.active),
              child: Text('Active'),
            ),
          ),
          Tooltip(
            message: 'Only completed todos',
            child: FlatButton(
              onPressed: () => filter.state = TodoListFilter.completed,
              visualDensity: VisualDensity.compact,
              textColor: textColorFor(TodoListFilter.completed),
              child: Text('Completed'),
            ),
          ),
        ],
      ),
    );
  }
}

///
class Title extends StatelessWidget {
  static const double _size = 86;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          'todos',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: _size,
            fontWeight: FontWeight.w100,
          ),
        ),
        Icon(
          Icons.check,
          size: _size,
        ),
      ],
    );
  }
}

///
class TodoItem extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final todo = useProvider(currentTodo);
    final itemFocusNode = useFocusNode();
    useListenable(itemFocusNode);
    final isFocused = itemFocusNode.hasFocus;

    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();

    return Padding(
      padding: EdgeInsets.all(1.0),
      child: Material(
        color: Colors.white,
        elevation: 6,
        child: Focus(
          focusNode: itemFocusNode,
          onFocusChange: (focused) {
            if (focused) {
              textEditingController.text = todo.description;
            } else {
              context.read(todoListProvider).edit(id: todo.id, description: textEditingController.text);
            }
          },
          child: ListTile(
            onTap: () {
              itemFocusNode.requestFocus();
              textFieldFocusNode.requestFocus();
            },
            leading: Checkbox(
              value: todo.completed,
              onChanged: (value) {
                context.read(todoListProvider).toggle(todo.id);
              },
            ),
            title: isFocused
                ? TextField(
                    autofocus: true,
                    focusNode: textFieldFocusNode,
                    controller: textEditingController,
                  )
                : Text(todo.description),
          ),
        ),
      ),
    );
  }
}
