import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/core/services/connectivity_service.dart';
import 'package:todo_app/core/widgets/no_internet_widget.dart';

class BaseScreen extends StatelessWidget {
  final Widget child;
  final bool showAppBar;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const BaseScreen({
    Key? key,
    required this.child,
    this.showAppBar = true,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(
                title ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: actions,
            )
          : null,
      body: Obx(
        () => connectivityService.isConnected.value
            ? child
            : NoInternetWidget(
                onRetry: () => connectivityService.checkConnectivity(),
              ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
} 