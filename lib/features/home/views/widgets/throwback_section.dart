import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../journal/controllers/journal_controller.dart';
import '../../../journal/models/journal_entry.dart';

class ThrowbackSection extends GetView<JournalController> {
  const ThrowbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.throwbackEntries.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_toggle_off, color: Colors.greenAccent),
              SizedBox(width: 8),
              Text(
                "Memory Throwback",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.throwbackEntries.length,
              itemBuilder: (context, index) {
                return _buildThrowbackCard(controller.throwbackEntries[index]);
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
      );
    });
  }

  Widget _buildThrowbackCard(JournalEntry entry) {
    bool hasImage = entry.mediaPaths.isNotEmpty;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
        image: hasImage
            ? DecorationImage(
                image: FileImage(File(entry.mediaPaths.first)),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.6),
                  BlendMode.darken,
                ),
              )
            : null,
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                controller.getYearsAgo(entry.date),
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
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
            const SizedBox(height: 4),
            Text(
              entry.content,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade300),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
