import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../journal/controllers/journal_controller.dart';

class MediaLibraryScreen extends GetView<JournalController> {
  const MediaLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text("Media Library",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Obx(() {
        // Extract all media paths from all entries
        final List<String> allMedia = [];
        for (var entry in controller.entries) {
          allMedia.addAll(entry.mediaPaths);
        }

        if (allMedia.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined,
                    size: 60, color: Colors.grey.withValues(alpha: 0.3)),
                const SizedBox(height: 15),
                const Text("No photos attached to your memories yet.",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 images per row
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: allMedia.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Pass the whole list and current index to the full-screen view
                Get.toNamed(
                  AppRoutes.fullScreenMedia,
                  arguments: {
                    'images': allMedia,
                    'initialIndex': index,
                  },
                );
              },
              child: Hero(
                tag: 'media_$index', // Smooth transition animation
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(File(allMedia[index])),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
