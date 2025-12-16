import 'dart:convert';
import 'package:bookify/controller/users/library_controller.dart';
import 'package:bookify/controller/users/wishlist_controller.dart';
import 'package:bookify/core/classes/api_client.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/model/content_model.dart';
import 'package:bookify/model/event_model.dart';
import 'package:bookify/model/user_library_model.dart';
import 'package:bookify/model/UserModel.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class HomeController extends GetxController {
  getHomeData();
  getRecentContent();
  getUpcomingEvents();
  refreshHome();
}

class HomeControllerImp extends HomeController {
  // State Management
  Staterequest staterequest = Staterequest.none;
  Staterequest recentContentState = Staterequest.none;
  Staterequest eventsState = Staterequest.none;

  // Data
  String userName = '';
  int libraryCount = 0;
  int wishlistCount = 0;
  List<ContentModel> recentContent = [];
  List<UserLibraryModel> recentLibraryItems = [];
  List<EventModel> upcomingEvents = [];

  // API
  ApiClient api = ApiClient();
  final serverConfig = ServerConfig();

  @override
  void onInit() {
    super.onInit();
    getHomeData();
  }

  @override
  Future<void> getHomeData() async {
    staterequest = Staterequest.loading;
    update();

    try {
      // تحميل اسم المستخدم من SharedPreferences
      await _loadUserName();

      // تحميل البيانات بشكل متوازي
      await Future.wait([
        _getLibraryStats(),
        _getWishlistStats(),
        getRecentContent(),
        getUpcomingEvents(),
      ]);

      staterequest = Staterequest.success;
    } catch (e) {
      print('Home Data Error: $e');
      staterequest = Staterequest.failure;
    }

    update();
  }

  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null && userJson.isNotEmpty) {
        final userData = jsonDecode(userJson);
        final user = UserModel.fromJson(userData);
        userName = user.fullName;
        print('User loaded: ${user.fullName}');
      } else {
        userName = 'مستخدم';
        print('No user data found in SharedPreferences');
      }
    } catch (e) {
      print('Error loading username: $e');
      userName = 'مستخدم';
    }
  }

  Future<void> _getLibraryStats() async {
    try {
      // الحصول على عدد العناصر في المكتبة
      LibraryControllerImp libraryController;
      if (Get.isRegistered<LibraryControllerImp>()) {
        libraryController = Get.find<LibraryControllerImp>();
      } else {
        libraryController = Get.put(LibraryControllerImp());
      }

      await libraryController.getLibrary();
      libraryCount = libraryController.libraryItems.length;

      // الحصول على آخر العناصر المضافة/المفتوحة
      recentLibraryItems = libraryController.getRecentlyAccessed(limit: 5);

      print('Library Count: $libraryCount');
    } catch (e) {
      print('Error getting library stats: $e');
      libraryCount = 0;
    }
  }

  Future<void> _getWishlistStats() async {
    try {
      // الحصول على عدد العناصر في قائمة الأمنيات
      WishlistControllerImp wishlistController;
      if (Get.isRegistered<WishlistControllerImp>()) {
        wishlistController = Get.find<WishlistControllerImp>();
      } else {
        wishlistController = Get.put(WishlistControllerImp());
      }

      await wishlistController.getWishlist();
      wishlistCount = wishlistController.wishlistItems.length;

      print('Wishlist Count: $wishlistCount');
    } catch (e) {
      print('Error getting wishlist stats: $e');
      wishlistCount = 0;
    }
  }

  @override
  Future<void> getRecentContent() async {
    recentContentState = Staterequest.loading;
    update();

    try {
      final response = await api.getData(
        url: '${serverConfig.serverLink}/api/user/content',
      );

      print('Recent Content Response: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final allContent = (response.data as List)
              .map((item) => ContentModel.fromJson(item))
              .toList();

          // ترتيب حسب الأحدث وأخذ أول 6 عناصر
          allContent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          recentContent = allContent.take(6).toList();

          recentContentState = recentContent.isEmpty
              ? Staterequest.empty
              : Staterequest.success;

          print('Recent Content Loaded: ${recentContent.length}');
        } else {
          recentContentState = Staterequest.empty;
        }
      } else {
        recentContentState = Staterequest.failure;
      }
    } catch (e) {
      print('Recent Content Error: $e');
      recentContentState = Staterequest.failure;
    }

    update();
  }

  @override
  Future<void> getUpcomingEvents() async {
    eventsState = Staterequest.loading;
    update();

    try {
      final response = await api.getData(
        url: '${serverConfig.serverLink}/api/user/events',
      );

      print('Upcoming Events Response: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final allEvents = (response.data as List)
              .map((item) => EventModel.fromJson(item))
              .toList();

          print('Total Events from API: ${allEvents.length}');

          // فلترة الفعاليات القادمة فقط وترتيبها حسب التاريخ
          final now = DateTime.now();
          print('Current Time: $now');

          upcomingEvents = allEvents
              .where((event) {
                print('Event: ${event.title}, Start: ${event.startDatetime}, Is Future: ${event.startDatetime.isAfter(now)}');
                return event.startDatetime.isAfter(now);
              })
              .toList();

          print('Upcoming Events after filter: ${upcomingEvents.length}');

          upcomingEvents.sort((a, b) => a.startDatetime.compareTo(b.startDatetime));

          // أخذ أول 3 فعاليات قادمة
          upcomingEvents = upcomingEvents.take(3).toList();

          eventsState = upcomingEvents.isEmpty
              ? Staterequest.empty
              : Staterequest.success;

          print('Final Upcoming Events Count: ${upcomingEvents.length}');
        } else {
          print('Events response is not a List');
          eventsState = Staterequest.empty;
        }
      } else {
        eventsState = Staterequest.failure;
      }
    } catch (e) {
      print('Upcoming Events Error: $e');
      eventsState = Staterequest.failure;
    }

    update();
  }

  @override
  Future<void> refreshHome() async {
    await getHomeData();
  }

  // Helper method للحصول على تحية مناسبة حسب الوقت
  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'صباح الخير';
    } else if (hour < 17) {
      return 'مساء الخير';
    } else {
      return 'مساء الخير';
    }
  }
}
