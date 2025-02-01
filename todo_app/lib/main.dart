import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/core/routes/app_pages.dart';
import 'package:todo_app/core/theme/app_theme.dart';
import 'package:get_storage/get_storage.dart';
import 'package:todo_app/services/storage_service.dart';
import 'package:todo_app/controllers/auth_controller.dart';
import 'package:todo_app/core/services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize services
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => ConnectivityService().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ToDo App',
      theme: AppTheme.lightTheme,
      initialRoute: Routes.ONBOARDING,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
    );
  }
}
