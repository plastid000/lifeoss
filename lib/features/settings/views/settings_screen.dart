import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../core/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Injecting Controllers
    final controller = Get.put(SettingsController());
    final authService = Get.find<AuthService>();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader("Appearance"),
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Dark Mode"),
              secondary: const Icon(Icons.dark_mode, color: Colors.greenAccent),
              value: controller.isDarkMode.value,
              activeColor: Colors.greenAccent,
              onChanged: (val) => controller.toggleTheme(),
            ),
          ),
          const Divider(color: Colors.white10, height: 30),

          _buildSectionHeader("Security & Privacy"),

          // Biometric Toggle (Fingerprint / FaceID)
          Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Fingerprint / Face ID"),
              subtitle: const Text(
                "Unlock MemoirOS instantly",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              secondary: const Icon(
                Icons.fingerprint,
                color: Colors.greenAccent,
              ),
              value: authService.isBiometricEnabled.value,
              activeColor: Colors.greenAccent,
              onChanged: (val) => authService.toggleBiometric(val),
            ),
          ),

          // Set / Change PIN
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.pin_outlined, color: Colors.blueAccent),
            title: Obx(
              () => Text(
                authService.isPinEnabled.value
                    ? "Change App PIN"
                    : "Set App PIN",
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () => _showPinSetupDialog(context, authService),
          ),

          // Remove Security (Only shows if PIN or Biometric is active)
          Obx(() {
            if (authService.isPinEnabled.value ||
                authService.isBiometricEnabled.value) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.no_encryption_outlined,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  "Remove App Lock",
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  controller.disableAllSecurity();
                },
              );
            }
            return const SizedBox.shrink();
          }),

          const Divider(color: Colors.white10, height: 30),

          _buildSectionHeader("Data & Cloud (Phase 9)"),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.cloud_upload_outlined,
              color: Colors.blueAccent,
            ),
            title: const Text("Backup to Google Drive"),
            subtitle: const Text(
              "Coming soon",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            onTap: () {
              Get.snackbar(
                'Notice',
                'Drive Backup logic will be implemented next phase.',
              );
            },
          ),

          const Divider(color: Colors.white10, height: 30),
          _buildSectionHeader("About"),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline, color: Colors.grey),
            title: Text("MemoirOS Version"),
            trailing: Text(
              "v1.0.0",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Elegant PIN Setup Dialog
  void _showPinSetupDialog(BuildContext context, AuthService authService) {
    final TextEditingController pinController = TextEditingController();

    Get.defaultDialog(
      backgroundColor: Colors.black87,
      title: authService.isPinEnabled.value ? "Change PIN" : "Set New PIN",
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        children: [
          const Text(
            "Enter a 4-digit security PIN",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            autofocus: true,
            style: const TextStyle(
              color: Colors.white,
              letterSpacing: 15,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: Colors.black45,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.greenAccent,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
      textConfirm: "Save PIN",
      textCancel: "Cancel",
      confirmTextColor: Colors.black,
      cancelTextColor: Colors.white,
      buttonColor: Colors.greenAccent,
      onConfirm: () {
        if (pinController.text.length == 4) {
          authService.savePin(pinController.text, 4);
          Get.back();
          Get.snackbar(
            'Success',
            'Your PIN has been saved securely!',
            backgroundColor: Colors.greenAccent.withValues(alpha: 0.2),
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Invalid PIN',
            'PIN must be exactly 4 digits.',
            backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
            colorText: Colors.white,
          );
        }
      },
    );
  }
}
