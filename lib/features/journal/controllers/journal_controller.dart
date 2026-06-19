import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/journal_entry.dart';
import '../repositories/journal_repository.dart';
import '../../../core/services/media_service.dart';

class JournalController extends GetxController {
  final JournalRepository repository;

  JournalController(this.repository);

  // Core Observables
  var entries = <JournalEntry>[].obs;
  var isLoading = false.obs;
  var tempMediaPaths = <String>[].obs;

  // Throwback Observables
  var throwbackEntries = <JournalEntry>[].obs;

  // Search Observables
  var searchResults = <JournalEntry>[].obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadJournals();
  }

  Future<void> loadJournals() async {
    isLoading.value = true;
    entries.value = await repository.getAllEntries();
    _calculateThrowbacks();
    isLoading.value = false;
  }

  // ==========================================
  // Throwback Logic (Phase 5)
  // ==========================================
  void _calculateThrowbacks() {
    final today = DateTime.now();
    throwbackEntries.value = entries.where((entry) {
      return entry.date.month == today.month &&
          entry.date.day == today.day &&
          entry.date.year < today.year;
    }).toList();
  }

  String getYearsAgo(DateTime entryDate) {
    int diff = DateTime.now().year - entryDate.year;
    if (diff == 1) return "1 Year Ago Today";
    return "$diff Years Ago Today";
  }

  // ==========================================
  // Calendar Logic (Phase 4)
  // ==========================================
  List<JournalEntry> getEntriesForDay(DateTime day) {
    return entries.where((entry) {
      return entry.date.year == day.year &&
          entry.date.month == day.month &&
          entry.date.day == day.day;
    }).toList();
  }

  // ==========================================
  // Map Logic (Phase 6)
  // ==========================================
  List<JournalEntry> getEntriesWithLocation() {
    return entries
        .where((entry) => entry.latitude != null && entry.longitude != null)
        .toList();
  }

  // ==========================================
  // Search Logic (Phase 7)
  // ==========================================
  void searchMemories(String query) {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }
    final lowerQuery = query.toLowerCase();
    searchResults.value = entries.where((entry) {
      return entry.title.toLowerCase().contains(lowerQuery) ||
          entry.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ==========================================
  // Media Logic (Phase 3)
  // ==========================================
  Future<void> pickImage() async {
    final path = await MediaService.pickAndSaveImage();
    if (path != null) {
      tempMediaPaths.add(path);
    }
  }

  void removeTempImage(int index) {
    tempMediaPaths.removeAt(index);
  }

  // ==========================================
  // Location Service
  // ==========================================
  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Location Disabled', 'Please enable GPS to tag location.',
          backgroundColor: Colors.orangeAccent.withValues(alpha: 0.2),
          colorText: Colors.white);
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // CRUD Operations (Phase 1)
  // ==========================================
  Future<void> addJournal({
    required String title,
    required String content,
    required Mood mood,
  }) async {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      Get.snackbar('Hold on!', 'Title and content cannot be empty.',
          backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
          colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    // Get location seamlessly in the background
    final position = await _getCurrentLocation();

    final newEntry = JournalEntry()
      ..title = title.trim()
      ..content = content.trim()
      ..mood = mood
      ..mediaPaths = tempMediaPaths.toList()
      ..latitude = position?.latitude
      ..longitude = position?.longitude
      ..date = DateTime.now();

    await repository.saveEntry(newEntry);

    // Reset temp data and reload list
    tempMediaPaths.clear();
    await loadJournals();

    isLoading.value = false;
    Get.back(); // Go back to Home Screen
    Get.snackbar('Saved!', 'Your memory has been locked in.',
        backgroundColor: Colors.greenAccent.withValues(alpha: 0.2),
        colorText: Colors.white);
  }

  Future<void> deleteJournal(int id) async {
    await repository.deleteEntry(id);
    await loadJournals(); // Refreshes main list and throwbacks instantly
    Get.snackbar('Deleted', 'Memory removed.',
        backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
        colorText: Colors.white);
  }
}
