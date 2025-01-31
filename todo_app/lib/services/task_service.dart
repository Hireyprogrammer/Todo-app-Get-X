import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class TaskService {
  final Dio _dio;
  final StorageService _storage = Get.find<StorageService>();

  TaskService() : _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    validateStatus: (status) => status! < 500,
  )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storage.getToken();
        if (token != null) {
          options.headers = ApiConstants.headers(token);
        } else {
          // Handle no token scenario
          Get.find<AuthController>().handleAuthenticationChanged(false);
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle token expiration
          Get.find<AuthController>().handleAuthenticationChanged(false);
        }
        return handler.next(error);
      },
    ));
  }

  Future<List<Task>> getAllTasks() async {
    try {
      final response = await _dio.get('/tasks');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['tasks'];
        return data.map((json) => Task.fromJson(json)).toList();
      }
      throw 'Failed to fetch tasks';
    } catch (e) {
      throw 'Error getting tasks: $e';
    }
  }

  Future<Task> createTask(String title) async {
    try {
      final response = await _dio.post('/tasks', data: {'title': title});
      if (response.statusCode == 201) {
        return Task.fromJson(response.data['task']);
      }
      throw 'Failed to create task';
    } catch (e) {
      throw 'Error creating task: $e';
    }
  }

  Future<Task> toggleTask(String taskId) async {
    try {
      final response = await _dio.put('/tasks/$taskId/toggle');
      if (response.statusCode == 200) {
        return Task.fromJson(response.data['task']);
      }
      throw 'Failed to toggle task';
    } catch (e) {
      throw 'Error toggling task: $e';
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final response = await _dio.delete('/tasks/$taskId');
      if (response.statusCode != 200) {
        throw 'Failed to delete task';
      }
    } catch (e) {
      throw 'Error deleting task: $e';
    }
  }
} 