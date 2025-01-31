import 'package:get/get.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/tasks/add_task_screen.dart';
import '../bindings/task_binding.dart';

class AppRoutes {
  static final routes = [
    GetPage(
      name: '/home',
      page: () => const HomeScreen(),
      binding: TaskBinding(),
    ),
    GetPage(
      name: '/add-task',
      page: () => const AddTaskScreen(),
      binding: TaskBinding(),
    ),
  ];
} 