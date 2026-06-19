import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../journal/controllers/journal_controller.dart';
import 'widgets/search_result_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final JournalController controller = Get.find<JournalController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Clear previous search when opening the screen
    controller.searchMemories('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            hintText: "Search memories...",
            hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
            border: InputBorder.none,
          ),
          onChanged: (value) => controller.searchMemories(value),
        ),
        actions: [
          Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    controller.searchMemories('');
                  },
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        final query = controller.searchQuery.value;
        final results = controller.searchResults;

        // Default empty state before typing
        if (query.trim().isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search,
                    size: 80, color: Colors.grey.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                const Text(
                  "Type keywords, title, or thoughts.",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          );
        }

        // No results found
        if (results.isEmpty) {
          return Center(
            child: Text(
              "No memories found for '$query'.",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          );
        }

        // Show results
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            return SearchResultCard(entry: results[index]);
          },
        );
      }),
    );
  }
}
