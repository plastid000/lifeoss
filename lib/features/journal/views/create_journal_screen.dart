import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/journal_controller.dart';
import '../models/journal_entry.dart';

class CreateJournalScreen extends StatefulWidget {
  const CreateJournalScreen({super.key});

  @override
  State<CreateJournalScreen> createState() => _CreateJournalScreenState();
}

class _CreateJournalScreenState extends State<CreateJournalScreen> {
  final JournalController controller = Get.find<JournalController>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Mood _selectedMood = Mood.happy; // Default mood

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    // Clear temp images if user backs out without saving
    controller.tempMediaPaths.clear();
    super.dispose();
  }

  void _saveEntry() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    controller.addJournal(
      title: _titleController.text,
      content: _contentController.text,
      mood: _selectedMood,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.greenAccent),
                  ),
                )
              : TextButton(
                  onPressed: _saveEntry,
                  child: const Text(
                    "Save",
                    style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                )),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mood Selector
                  _buildMoodSelector(),
                  const SizedBox(height: 20),

                  // Title Field
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Title...",
                      hintStyle: TextStyle(color: Colors.grey.shade700),
                      border: InputBorder.none,
                    ),
                  ),

                  // Date Indicator (Auto)
                  Text(
                    "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} • ${TimeOfDay.now().format(context)}",
                    style: TextStyle(
                        color: Colors.greenAccent.withValues(alpha: 0.8),
                        fontSize: 12),
                  ),
                  const SizedBox(height: 20),

                  // Content Field
                  TextField(
                    controller: _contentController,
                    maxLines: null, // Grows dynamically
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.white70, height: 1.6),
                    decoration: InputDecoration(
                      hintText: "Start writing your memory...",
                      hintStyle: TextStyle(color: Colors.grey.shade700),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Image Preview Section
                  Obx(() {
                    if (controller.tempMediaPaths.isEmpty)
                      return const SizedBox.shrink();
                    return _buildImagePreview();
                  }),
                ],
              ),
            ),
          ),

          // Bottom Toolbar (Media & Location)
          _buildBottomToolbar(),
        ],
      ),
    );
  }

  // ==========================================
  // UI Components
  // ==========================================

  Widget _buildMoodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: Mood.values.map((mood) {
          bool isSelected = _selectedMood == mood;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMood = mood;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.greenAccent.withValues(alpha: 0.2)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Colors.greenAccent
                      : Colors.grey.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                mood.name.capitalizeFirst!,
                style: TextStyle(
                  color: isSelected ? Colors.greenAccent : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImagePreview() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.tempMediaPaths.length,
        itemBuilder: (context, index) {
          final path = controller.tempMediaPaths[index];
          return Stack(
            children: [
              Container(
                width: 120,
                margin: const EdgeInsets.only(right: 15, top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(File(path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 5,
                child: GestureDetector(
                  onTap: () => controller.removeTempImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        border:
            Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image_outlined, color: Colors.grey),
            onPressed: () => controller.pickImage(),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
          const SizedBox(width: 5),
          const Text("Auto-tagged",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
