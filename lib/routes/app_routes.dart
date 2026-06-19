import 'package:get/get.dart';
import '../features/calendar/views/calendar_screen.dart';
import '../features/home/views/home_screen.dart';
import '../features/journal/views/create_journal_screen.dart';
import '../features/map/views/map_screen.dart';
import '../features/search/views/search_screen.dart';
import '../features/auth/views/lock_screen.dart';
import '../features/memories/views/memories_screen.dart';
import '../features/media/views/media_library_screen.dart';
import '../features/media/views/full_screen_media_view.dart';
import '../features/journal/views/view_journal_screen.dart'; // Import this

class AppRoutes {
  static const home = '/home';
  static const createJournal = '/create-journal';
  static const calendar = '/calendar';
  static const map = '/map';
  static const search = '/search';
  static const lock = '/lock';
  static const memories = '/memories';
  static const mediaLibrary = '/media-library';
  static const fullScreenMedia = '/full-screen-media';
  static const viewJournal = '/view-journal';

  static final routes = [
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: createJournal,
      page: () => CreateJournalScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: calendar,
      page: () => const CalendarScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: map,
      page: () => const MapScreen(),
      transition: Transition.zoom,
    ),
    GetPage(
      name: search,
      page: () => const SearchScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: lock,
      page: () => const LockScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: memories,
      page: () => const MemoriesScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: mediaLibrary,
      page: () => const MediaLibraryScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: fullScreenMedia,
      page: () => const FullScreenMediaView(),
      transition: Transition.zoom,
    ),
    GetPage(
      name: viewJournal,
      page: () => const ViewJournalScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
