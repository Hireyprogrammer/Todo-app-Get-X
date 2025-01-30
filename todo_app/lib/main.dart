import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/core/routes/app_pages.dart';
import 'package:todo_app/core/theme/app_theme.dart';
import 'package:todo_app/core/services/connectivity_service.dart';
import 'package:todo_app/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Services
  await Get.putAsync(() => ConnectivityService().init());
  
  // Initialize Controllers
  Get.put(AuthController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ToDo App',
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
