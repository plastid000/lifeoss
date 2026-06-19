import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../journal/controllers/journal_controller.dart';
import '../../search/views/widgets/search_result_card.dart';

class MemoriesScreen extends GetView<JournalController> {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            "Memory Archive",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.greenAccent,
            labelColor: Colors.greenAccent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "On This Day"),
              Tab(text: "This Week"),
              Tab(text: "This Month"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOnThisDayTab(),
            _buildFilteredTab(isThisWeek: true),
            _buildFilteredTab(isThisWeek: false),
          ],
        ),
      ),
    );
  }

  // Tab 1: On This Day (Using the pre-calculated throwback entries)
  Widget _buildOnThisDayTab() {
    return Obx(() {
      // Reading throwbackEntries.obs makes this block reactive!
      final throwbacks = controller.throwbackEntries;

      if (throwbacks.isEmpty) {
        return _buildEmptyState("No memories from this day in the past.");
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: throwbacks.length,
        itemBuilder: (context, index) {
          return SearchResultCard(entry: throwbacks[index]);
        },
      );
    });
  }

  // Tab 2 & 3: This Week and This Month
  Widget _buildFilteredTab({required bool isThisWeek}) {
    return Obx(() {
      final now = DateTime.now();

      // Reading controller.entries.obs directly inside Obx fixes the error!
      final filteredList = controller.entries.where((entry) {
        final difference = now.difference(entry.date).inDays;
        if (isThisWeek) {
          // Last 7 days, excluding today
          return difference > 0 && difference <= 7;
        } else {
          // Same month & year, but not today or this week
          return entry.date.month == now.month &&
              entry.date.year == now.year &&
              difference > 7;
        }
      }).toList();

      if (filteredList.isEmpty) {
        return _buildEmptyState(
          isThisWeek
              ? "No other memories recorded this week."
              : "No other memories recorded this month.",
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          return SearchResultCard(entry: filteredList[index]);
        },
      );
    });
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 60,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 15),
          Text(message, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
