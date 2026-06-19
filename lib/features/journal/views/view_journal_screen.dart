import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/journal_entry.dart';
import '../controllers/journal_controller.dart';

class ViewJournalScreen extends GetView<JournalController> {
  const ViewJournalScreen({super.key});

  void _showDeleteConfirm(int id) {
    Get.defaultDialog(
      backgroundColor: Colors.black87,
      title: "Delete Memory?",
      titleStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      middleText: "This action cannot be undone. Are you sure?",
      middleTextStyle: const TextStyle(color: Colors.grey),
      textCancel: "Keep It",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        controller.deleteJournal(id);
        Get.back(); // Close Dialog
        Get.back(); // Go back to previous screen
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Receiving the entry passed from Home or Calendar
    final JournalEntry entry = Get.arguments;
    final bool hasImage = entry.mediaPaths.isNotEmpty;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: hasImage ? 300.0 : 100.0,
            pinned: true,
            backgroundColor: context.theme.scaffoldBackgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _showDeleteConfirm(entry.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: hasImage
                  ? Image.file(
                      File(entry.mediaPaths.first),
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.4),
                      colorBlendMode: BlendMode.darken,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Info (Mood & Date)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.greenAccent.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          entry.mood.name.capitalizeFirst!,
                          style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "${entry.date.day}/${entry.date.month}/${entry.date.year}",
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    entry.title,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 10),

                  // Location Tag (If available)
                  if (entry.latitude != null && entry.longitude != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.grey, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          "Lat: ${entry.latitude!.toStringAsFixed(4)}, Lng: ${entry.longitude!.toStringAsFixed(4)}",
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: Colors.white10),
                  ),

                  // Content
                  Text(
                    entry.content,
                    style: TextStyle(
                        fontSize: 18, color: Colors.grey.shade300, height: 1.6),
                  ),

                  const SizedBox(height: 30),

                  // Extra Images Gallery (If more than 1 image)
                  if (entry.mediaPaths.length > 1) ...[
                    const Text(
                      "Gallery",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: entry.mediaPaths.length -
                            1, // Skip the first one (used in header)
                        itemBuilder: (context, index) {
                          return Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(
                                    File(entry.mediaPaths[index + 1])),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
