import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:todo_app/core/services/logger_service.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker = InternetConnectionChecker();
  final RxBool isConnected = true.obs;
  late StreamSubscription _connectivitySubscription;
  late StreamSubscription _internetSubscription;

  Future<ConnectivityService> init() async {
    await _initConnectivity();
    _setupConnectivityStream();
    _setupInternetStream();
    return this;
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none) {
        isConnected.value = await _internetChecker.hasConnection;
      } else {
        isConnected.value = false;
      }
    } catch (e) {
      debugPrint('Connectivity init error: $e');
      isConnected.value = false;
    }
  }

  void _setupConnectivityStream() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) async {
      if (result == ConnectivityResult.none) {
        isConnected.value = false;
        AppLogger.connectionStatus(false);
      } else {
        isConnected.value = await _internetChecker.hasConnection;
        AppLogger.connectionStatus(isConnected.value);
      }
    });
  }

  void _setupInternetStream() {
    _internetSubscription = _internetChecker.onStatusChange.listen((status) {
      isConnected.value = status == InternetConnectionStatus.connected;
      _showConnectivitySnackbar();
    });
  }

  void _showConnectivitySnackbar() {
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
    
    Get.showSnackbar(GetSnackBar(
      message: isConnected.value 
        ? 'Back Online' 
        : 'No Internet Connection',
      icon: Icon(
        isConnected.value ? Icons.wifi : Icons.wifi_off,
        color: Colors.white,
      ),
      backgroundColor: isConnected.value ? Colors.green : Colors.red,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    ));
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    _internetSubscription.cancel();
    super.onClose();
  }

  Future<void> checkConnectivity() async {
    await _initConnectivity();
  }
} 