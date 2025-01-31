import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/task_controller.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize AuthController
    Get.put(AuthController());
    // Initialize TaskController
    Get.put(TaskController());
  }
} 