import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/config/dependency_injection.dart';
import 'routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // 1. Ensure Flutter engine is completely ready
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Storage সবার আগে ইনিশিয়ালাইজ করতে হবে
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. ডিপেন্ডেন্সি (Isar DB, Controllers, AuthService) রেডি করা
  await DependencyInjection.init();

  // 4. ফাস্ট সিকিউরিটি চেক (অ্যাপ লক করা আছে কি না)
  final box = GetStorage();
  bool isPinEnabled = box.read('isPinEnabled') ?? false;
  bool isBiometricEnabled = box.read('isBiometricEnabled') ?? false;

  bool isLocked = isPinEnabled || isBiometricEnabled;

  // 5. অ্যাপ রান!
  runApp(MemoirOSApp(initialRoute: isLocked ? AppRoutes.lock : AppRoutes.home));
}

class MemoirOSApp extends StatelessWidget {
  final String initialRoute;
  const MemoirOSApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MemoirOS',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // MemoirOS এর প্রিমিয়াম ডার্ক ফিল!
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        primaryColor: Colors.greenAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.greenAccent,
          secondary: Colors.green,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      initialRoute: initialRoute,
      getPages: AppRoutes.routes,
    );
  }
}
