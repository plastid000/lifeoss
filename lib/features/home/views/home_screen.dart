import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../journal/controllers/journal_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final controller = Get.put(JournalController(Get.find()));

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "MemoirOS",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => Get.toNamed(AppRoutes.search),
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined, color: Colors.white),
            onPressed: () => Get.toNamed(AppRoutes.map),
          ),
          IconButton(
            icon:
                const Icon(Icons.calendar_month_outlined, color: Colors.white),
            onPressed: () => Get.toNamed(AppRoutes.calendar),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent));
        }

        if (controller.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined,
                    size: 80, color: Colors.grey.withValues(alpha: 0.3)),
                const SizedBox(height: 20),
                const Text(
                  "No memories yet.",
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Tap the + button to start journaling.",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.entries.length,
          itemBuilder: (context, index) {
            final entry = controller.entries[index];
            final hasImage = entry.mediaPaths.isNotEmpty;

            return GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.viewJournal, arguments: entry),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasImage)
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          image: DecorationImage(
                            image: FileImage(File(entry.mediaPaths.first)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${entry.date.day}/${entry.date.month}/${entry.date.year}",
                                style: TextStyle(
                                    color: Colors.greenAccent
                                        .withValues(alpha: 0.8),
                                    fontSize: 12),
                              ),
                              Icon(
                                _getMoodIcon(entry.mood.name),
                                size: 16,
                                color: Colors.grey,
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.content,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: () => Get.toNamed(AppRoutes.createJournal),
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
    );
  }

  IconData _getMoodIcon(String moodName) {
    switch (moodName.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'excited':
        return Icons.sentiment_satisfied_alt;
      case 'angry':
        return Icons.mood_bad;
      case 'calm':
        return Icons.self_improvement;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
