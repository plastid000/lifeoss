import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../routes/app_routes.dart';
import '../../journal/controllers/journal_controller.dart';
import '../../journal/models/journal_entry.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final JournalController controller = Get.find<JournalController>();
    final List<JournalEntry> localizedEntries =
        controller.getEntriesWithLocation();

    // Default center to Dhaka or the latest entry's location to optimize first view
    final LatLng initialCenter = localizedEntries.isNotEmpty
        ? LatLng(
            localizedEntries.first.latitude!, localizedEntries.first.longitude!)
        : const LatLng(23.8103, 90.4125);

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text("Memory Map",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: localizedEntries.isNotEmpty ? 12.0 : 6.0,
        ),
        children: [
          // Pre-configured premium dark tiles for MemoirOS theme consistency
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.mrtechbd.lifeos',
          ),

          // Render markers reactively
          MarkerLayer(
            markers: localizedEntries.map((entry) {
              return Marker(
                point: LatLng(entry.latitude!, entry.longitude!),
                width: 45,
                height: 45,
                child: GestureDetector(
                  onTap: () => _showMemoryPopup(context, entry),
                  child: const Icon(
                    Icons.location_on,
                    size: 40,
                    color: Colors.greenAccent,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Beautiful minimalist custom bottom sheet to jump into details
  void _showMemoryPopup(BuildContext context, JournalEntry entry) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: Colors.greenAccent.withOpacity(0.2),
              width: 1.5,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${entry.date.day}/${entry.date.month}/${entry.date.year}",
                  style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  entry.mood.name.capitalizeFirst!,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              entry.title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              entry.content,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Get.back(); // Close bottom sheet
                  Get.toNamed(AppRoutes.viewJournal, arguments: entry);
                },
                child: const Text(
                  "Open Memory",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
