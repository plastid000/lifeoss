import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🟢 Added for Haptic Feedback
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final AuthService authService = Get.find<AuthService>();
  String enteredPin = '';

  @override
  void initState() {
    super.initState();
    // Auto-trigger biometric if it's enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authService.isBiometricEnabled.value) {
        _triggerBiometric();
      }
    });
  }

  Future<void> _triggerBiometric() async {
    HapticFeedback.mediumImpact();
    bool success = await authService.authenticateBiometric();
    if (success) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  void _onNumPressed(String num) {
    if (enteredPin.length < authService.pinLength.value) {
      HapticFeedback.lightImpact(); // 🟢 Premium feel on tap
      setState(() {
        enteredPin += num;
      });
      // Automatically verify when max length is reached
      if (enteredPin.length == authService.pinLength.value) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (enteredPin.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      });
    }
  }

  void _verifyPin() {
    if (authService.verifyPin(enteredPin)) {
      HapticFeedback.heavyImpact(); // Success vibe
      Get.offAllNamed(AppRoutes.home);
    } else {
      HapticFeedback.vibrate(); // 🟢 Error vibration
      Get.snackbar(
        'Access Denied',
        'Incorrect PIN. Please try again.',
        backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      setState(() {
        enteredPin = ''; // Reset PIN on failure
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Lock Icon
            Icon(
              Icons.lock_outline,
              size: 50,
              color: Colors.greenAccent.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 20),
            const Text(
              "Enter MemoirOS PIN",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 30),

            // PIN Dots Indicator using Obx for reactivity
            Obx(() {
              int pinLength = authService.pinLength.value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pinLength, (index) {
                  bool isFilled = index < enteredPin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? Colors.greenAccent : Colors.transparent,
                      border: Border.all(
                        color: isFilled
                            ? Colors.greenAccent
                            : Colors.grey.shade700,
                        width: 2,
                      ),
                    ),
                  );
                }),
              );
            }),

            const Spacer(),

            // Custom Numpad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  _buildNumberRow(['1', '2', '3']),
                  _buildNumberRow(['4', '5', '6']),
                  _buildNumberRow(['7', '8', '9']),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Biometric Button (Reactive)
                      Obx(() => _buildNumpadButton(
                            icon: Icons.fingerprint,
                            onPressed: authService.isBiometricEnabled.value
                                ? _triggerBiometric
                                : null,
                          )),
                      // 0 Button
                      _buildNumpadButton(
                        text: '0',
                        onPressed: () => _onNumPressed('0'),
                      ),
                      // Backspace Button
                      _buildNumpadButton(
                        icon: Icons.backspace_outlined,
                        onPressed: _onBackspace,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((num) {
        return _buildNumpadButton(
          text: num,
          onPressed: () => _onNumPressed(num),
        );
      }).toList(),
    );
  }

  Widget _buildNumpadButton({
    String? text,
    IconData? icon,
    VoidCallback? onPressed,
  }) {
    bool isActionBtn = icon != null;

    return Container(
      margin: const EdgeInsets.all(10),
      width: 75,
      height: 75,
      child: Material(
        color:
            Colors.grey.withValues(alpha: 0.05), // Subtle background like iOS
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          splashColor: Colors.greenAccent.withValues(alpha: 0.2),
          highlightColor: Colors.greenAccent.withValues(alpha: 0.1),
          child: Center(
            child: isActionBtn
                ? Icon(
                    icon,
                    size: 30,
                    color: onPressed == null
                        ? Colors.transparent
                        : Colors.grey.shade400,
                  )
                : Text(
                    text!,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
