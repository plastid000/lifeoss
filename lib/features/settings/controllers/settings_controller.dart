import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/auth_service.dart';

class SettingsController extends GetxController {
  final AuthService authService = Get.find<AuthService>();
  final _box = GetStorage();

  // Observable for Theme
  var isDarkMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  // Load saved theme preference (Default is Dark for that premium vibe)
  void _loadTheme() {
    isDarkMode.value = _box.read('isDarkMode') ?? true;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Toggle Theme instantly & save to storage
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _box.write('isDarkMode', isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Master security toggle directly calls our powerful AuthService
  void disableAllSecurity() {
    authService.disableSecurity();
    Get.snackbar(
      'Security Disabled',
      'App lock has been removed.',
      backgroundColor: Colors.greenAccent.withValues(alpha: 0.2),
      colorText: Colors.white,
    );
  }
}
