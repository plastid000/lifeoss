import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullScreenMediaView extends StatefulWidget {
  const FullScreenMediaView({super.key});

  @override
  State<FullScreenMediaView> createState() => _FullScreenMediaViewState();
}

class _FullScreenMediaViewState extends State<FullScreenMediaView> {
  late final List<String> images;
  late final PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    // Safely parse arguments
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    images = args['images'] as List<String>? ?? [];
    currentIndex = args['initialIndex'] as int? ?? 0;

    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Pure black for better photo viewing
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "${currentIndex + 1} / ${images.length}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar:
          true, // Let the image slide under the transparent app bar
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Hero(
            tag: 'media_$index',
            // InteractiveViewer allows pinch-to-zoom on the images!
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Center(
                child: Image.file(
                  File(images[index]),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
