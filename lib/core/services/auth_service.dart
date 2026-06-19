import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthService extends GetxService {
  final _box = GetStorage();
  final LocalAuthentication _auth = LocalAuthentication();

  var isPinEnabled = false.obs;
  var isBiometricEnabled = false.obs;
  var pinLength = 4.obs;

  Future<AuthService> init() async {
    await GetStorage.init();
    isPinEnabled.value = _box.read('isPinEnabled') ?? false;
    isBiometricEnabled.value = _box.read('isBiometricEnabled') ?? false;
    pinLength.value = _box.read('pinLength') ?? 4;

    if (isPinEnabled.value == true) {
      _box.write('is_locked', true);
    }
    return this;
  }

  // 🔥 SHA-256 Hashing মেথড
  String _hashData(String data) {
    var bytes = utf8.encode(data);
    return sha256.convert(bytes).toString();
  }

  void savePin(String pin, int length) {
    _box.remove('user_pin'); // 🔥 পুরনো আনসেফ পিন রিমুভ করে দিবে
    _box.write('user_pin_hash', _hashData(pin)); // হ্যাশ সেভ!
    _box.write('pinLength', length);
    _box.write('isPinEnabled', true);
    _box.write('is_locked', false);
    isPinEnabled.value = true;
    pinLength.value = length;
  }

  bool verifyPin(String inputPin) {
    final savedHash = _box.read('user_pin_hash');

    // 🔥 অটো-মাইগ্রেশন লজিক (Fallback)
    if (savedHash == null) {
      final oldPin = _box.read('user_pin');
      if (oldPin != null && oldPin == inputPin) {
        // পুরনো পিন মিলে গেলে, সেটাকে সাথে সাথে সিকিউর করে হ্যাশ বানিয়ে সেভ করবে
        savePin(oldPin, oldPin.length);
        return true;
      }
      return false;
    }

    return savedHash == _hashData(inputPin);
  }

  // Security Question & Answer Hashing
  void saveSecurityQuestion(String question, String answer) {
    _box.write('sec_question', question);
    _box.write('sec_answer_hash', _hashData(answer.toLowerCase().trim()));
  }

  bool verifySecurityAnswer(String answer) {
    final savedHash = _box.read('sec_answer_hash');
    return savedHash == _hashData(answer.toLowerCase().trim());
  }

  String? getSecurityQuestion() {
    return _box.read('sec_question');
  }

  Future<bool> toggleBiometric(bool value) async {
    bool canAuth =
        await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    if (!canAuth) return false;
    _box.write('isBiometricEnabled', value);
    isBiometricEnabled.value = value;
    return true;
  }

  Future<bool> authenticateBiometric() async {
    try {
      bool canAuth =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canAuth) return false;

      return await _auth.authenticate(
        localizedReason: 'App লক আনলক করতে ফিঙ্গারপ্রিন্ট বা ফেস আইডি দিন',
        // Note: For local_auth 3.x this format works. If you get errors, wrap in options: AuthenticationOptions()
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      return false;
    }
  }

  void disableSecurity() {
    _box.remove('user_pin'); // 🔥 পুরনোটাও ডিলিট করবে
    _box.remove('user_pin_hash');
    _box.remove('sec_question');
    _box.remove('sec_answer_hash');
    _box.write('isPinEnabled', false);
    _box.write('isBiometricEnabled', false);
    _box.write('is_locked', false);
    isPinEnabled.value = false;
    isBiometricEnabled.value = false;
  }
}
