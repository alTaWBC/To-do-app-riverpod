import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

var _uuid = Uuid();

/// Todo class
class Todo {
  /// Todo id
  final String id;

  /// Todo description
  final String description;

  /// Is todo done?
  final bool completed;

  /// Default constructor
  Todo({
    this.description,
    this.completed = false,
    String id,
  }) : id = id ?? _uuid.v4();

  @override
  String toString() {
    return 'Todo(description: $description, completed: $completed)';
  }
}

/// ToDo Logic
class TodoList extends StateNotifier<List<Todo>> {
  ///Initial Todos
  TodoList([List<Todo> initialTodo]) : super(initialTodo ?? []);

  /// Stuff
  void add(String description) {
    state = [
      ...state,
      Todo(description: description),
    ];
  }

  /// Things
  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: todo.id,
            completed: !todo.completed,
            description: todo.description,
          )
        else
          todo,
    ];
  }

  /// Edit Todo
  void edit({@required String id, @required String description}) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            completed: todo.completed,
            id: todo.id,
            description: description,
          )
        else
          todo,
    ];
  }

  /// Remove Todo
  void remove(Todo target) {
    state = state.where((todo) => todo.id != target.id).toList();
  }
}

/// Todo Provider
final todoListProvider = StateNotifierProvider<TodoList>((ref) {
  return TodoList([
    Todo(id: 'todo-0', description: 'hi'),
    Todo(id: 'todo-1', description: 'hello'),
    Todo(id: 'todo-2', description: 'bonjour'),
  ]);
});

///List Filter
enum TodoListFilter {
  /// Show all Todos
  all,

  /// Show Todo with [Todo.completed] == False
  active,

  /// Show Todo with [Todo.completed] == True
  completed
}

///
final todoListFilter = StateProvider((_) => TodoListFilter.all);

///
final filteredTodos = Provider<List<Todo>>((read) {
  final filter = read.watch(todoListFilter);
  final todos = read.watch(todoListProvider.state);
  List<Todo> filteredTodos;

  switch (filter.state) {
    case TodoListFilter.completed:
      filteredTodos = todos.where((todo) => todo.completed).toList();
      break;
    case TodoListFilter.active:
      filteredTodos = todos.where((todo) => !todo.completed).toList();
      break;
    case TodoListFilter.all:
    default:
      filteredTodos = todos;
      break;
  }
  return filteredTodos;
});

///
final uncompletedTodosCount = Provider<int>((ref) {
  return ref.watch(todoListProvider.state).where((todo) => !todo.completed).length;
});

///
final currentTodo = ScopedProvider<Todo>(null);
