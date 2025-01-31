import 'package:get/get.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../core/utils/notification_helper.dart';

class TaskController extends GetxController {
  final TaskService _taskService = TaskService();
  final RxList<Task> tasks = <Task>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      final fetchedTasks = await _taskService.getAllTasks();
      tasks.assignAll(fetchedTasks);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      NotificationHelper.showError('Error fetching tasks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTask(String title) async {
    try {
      final task = await _taskService.createTask(title);
      tasks.add(task);
      NotificationHelper.showSuccess('Task created successfully');
    } catch (e) {
      NotificationHelper.showError(e.toString());
    }
  }

  Future<void> toggleTask(String taskId) async {
    try {
      final updatedTask = await _taskService.toggleTask(taskId);
      final index = tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        tasks[index] = updatedTask;
      }
    } catch (e) {
      NotificationHelper.showError(e.toString());
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      tasks.removeWhere((task) => task.id == taskId);
      NotificationHelper.showSuccess('Task deleted successfully');
    } catch (e) {
      NotificationHelper.showError(e.toString());
    }
  }
} 