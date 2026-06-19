import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../services/auth_service.dart';
import '../../features/journal/models/journal_entry.dart';
import '../../features/journal/repositories/journal_repository.dart';
import '../../features/journal/controllers/journal_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    // 1. Init Database (Isar)
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open([JournalEntrySchema], directory: dir.path);

    // 2. Inject Auth Service (Ensuring it runs init() to load saved states)
    await Get.putAsync<AuthService>(() => AuthService().init());

    // 3. Inject Repositories
    Get.put<JournalRepository>(JournalRepository(isar));

    // 4. Inject Controllers
    Get.put<JournalController>(
      JournalController(Get.find<JournalRepository>()),
    );
  }
}
