import 'package:bookify/core/classes/api_client.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/model/user_library_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class LibraryController extends GetxController {
  getLibrary();
  addToLibrary(int contentId);
  removeFromLibrary(int itemId);
  updateLastAccess(int itemId);
  filterByType(String? type);
}

class LibraryControllerImp extends LibraryController {
  Staterequest staterequest = Staterequest.none;
  List<UserLibraryModel> libraryItems = [];
  List<UserLibraryModel> filteredItems = [];
  String? selectedFilter; // null = all, 'book', 'magazine', 'podcast'
  ApiClient api = ApiClient();
  final serverConfig = ServerConfig();

  @override
  void onInit() {
    super.onInit();
    getLibrary();
  }

  @override
  getLibrary() async {
    staterequest = Staterequest.loading;
    update();

    try {
      final response = await api.getData(
        url: '${serverConfig.serverLink}/api/user/library',
      );

      print('Library Response: ${response.data}');
      print('Library Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        List data;

        // التحقق من نوع الـ response
        if (response.data is List) {
          // إذا كان الـ response مباشرة array
          data = response.data;
        } else if (response.data is Map && response.data['success'] == true) {
          // إذا كان الـ response object فيه success و data
          data = response.data['data'] ?? [];
        } else if (response.data is Map && response.data['data'] != null) {
          // إذا كان الـ response object فيه data بس
          data = response.data['data'];
        } else {
          data = [];
        }

        libraryItems = data.map((item) => UserLibraryModel.fromJson(item)).toList();

        // ترتيب حسب آخر دخول أو تاريخ الإضافة
        libraryItems.sort((a, b) {
          if (a.lastAccessedAt != null && b.lastAccessedAt != null) {
            return b.lastAccessedAt!.compareTo(a.lastAccessedAt!);
          } else if (a.lastAccessedAt != null) {
            return -1;
          } else if (b.lastAccessedAt != null) {
            return 1;
          } else {
            return b.addedAt.compareTo(a.addedAt);
          }
        });

        filteredItems = List.from(libraryItems);
        staterequest = Staterequest.success;
        print('Library loaded: ${libraryItems.length} items');
      } else {
        staterequest = Staterequest.failure;
        print('Library API failed with status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      staterequest = Staterequest.serverfailure;
      print('Library Error: $e');
      print('Stack Trace: $stackTrace');
    }

    update();
  }

  @override
  addToLibrary(int contentId) async {
    try {
      final response = await api.postData(
        url: '${serverConfig.serverLink}/api/user/library',
        data: {'content_id': contentId},
      );

      print('Add to Library Response: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar(
          'نجح',
          'تمت الإضافة إلى المكتبة',
          backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // إعادة تحميل المكتبة
        await getLibrary();
        return true;
      } else if (response.statusCode == 400) {
        // المحتوى موجود مسبقاً
        final message = response.data['message'] ?? 'المحتوى موجود في المكتبة مسبقاً';
        Get.snackbar(
          'تنبيه',
          message == 'Content already in library'
              ? 'المحتوى موجود في المكتبة مسبقاً'
              : message,
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.info_outline, color: Colors.white),
        );
        return false;
      }

      Get.snackbar(
        'خطأ',
        'فشلت إضافة المحتوى إلى المكتبة',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    } catch (e) {
      print('Add to Library Error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء الإضافة',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }
  }

  @override
  removeFromLibrary(int itemId) async {
    try {
      final response = await api.deleteData(
        url: '${serverConfig.serverLink}/api/user/library/$itemId',
      );

      print('Remove from Library Response: ${response.data}');
      print('Remove from Library Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        Get.snackbar(
          'نجح',
          'تمت الإزالة من المكتبة',
          backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // إزالة العنصر محلياً
        libraryItems.removeWhere((item) => item.userLibraryId == itemId);
        filterByType(selectedFilter);
        return true;
      } else if (response.statusCode == 404) {
        Get.snackbar(
          'تنبيه',
          'المحتوى غير موجود في المكتبة',
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.info_outline, color: Colors.white),
        );
        // إزالة محلياً على أي حال
        libraryItems.removeWhere((item) => item.userLibraryId == itemId);
        filterByType(selectedFilter);
        return false;
      }

      Get.snackbar(
        'خطأ',
        'فشلت إزالة المحتوى من المكتبة',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    } catch (e) {
      print('Remove from Library Error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء الإزالة',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }
  }

  @override
  updateLastAccess(int itemId) async {
    try {
      final response = await api.patchData(
        url: '${serverConfig.serverLink}/api/user/library/$itemId/access',
        data: {},
      );

      if (response.statusCode == 200) {
        print('Last access updated for item: $itemId');
      }
    } catch (e) {
      print('Update Last Access Error: $e');
    }
  }

  @override
  filterByType(String? type) {
    selectedFilter = type;

    if (type == null) {
      filteredItems = List.from(libraryItems);
    } else {
      filteredItems = libraryItems.where((item) {
        final itemType = item.contentType.toLowerCase();
        final filterType = type.toLowerCase();

        // المطابقة المباشرة
        if (itemType == filterType) return true;

        // المطابقة بين العربي والإنجليزي
        if (filterType == 'book' && itemType == 'كتاب') return true;
        if (filterType == 'كتاب' && itemType == 'book') return true;

        if (filterType == 'magazine' && itemType == 'مجلة') return true;
        if (filterType == 'مجلة' && itemType == 'magazine') return true;

        if (filterType == 'podcast' && itemType == 'بودكاست') return true;
        if (filterType == 'بودكاست' && itemType == 'podcast') return true;

        if (filterType == 'audiobook' && (itemType == 'كتاب صوتي' || itemType == 'صوتي')) return true;
        if ((filterType == 'كتاب صوتي' || filterType == 'صوتي') && itemType == 'audiobook') return true;

        if (filterType == 'video' && itemType == 'فيديو') return true;
        if (filterType == 'فيديو' && itemType == 'video') return true;

        if (filterType == 'article' && itemType == 'مقالة') return true;
        if (filterType == 'مقالة' && itemType == 'article') return true;

        return false;
      }).toList();
    }

    update();
  }

  // Helper method للحصول على آخر المحتوى الذي تم الوصول إليه
  List<UserLibraryModel> getRecentlyAccessed({int limit = 5}) {
    return libraryItems
        .where((item) => item.lastAccessedAt != null)
        .take(limit)
        .toList();
  }
}
