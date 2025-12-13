import 'package:bookify/core/classes/api_client.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/model/wishlist_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class WishlistController extends GetxController {
  getWishlist();
  addToWishlist(int contentId);
  removeFromWishlist(int itemId);
  filterByType(String? type);
}

class WishlistControllerImp extends WishlistController {
  Staterequest staterequest = Staterequest.none;
  List<WishlistItemModel> wishlistItems = [];
  List<WishlistItemModel> filteredItems = [];
  String? selectedFilter; // null = all, 'book', 'magazine', etc.
  ApiClient api = ApiClient();
  final serverConfig = ServerConfig();

  @override
  void onInit() {
    super.onInit();
    getWishlist();
  }

  @override
  getWishlist() async {
    staterequest = Staterequest.loading;
    update();

    try {
      final response = await api.getData(
        url: '${serverConfig.serverLink}/api/user/wishlists',
      );

      print('Wishlist Response: ${response.data}');
      print('Wishlist Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        List data;

        // التحقق من نوع الـ response
        if (response.data is List) {
          // إذا كان الـ response array من wishlists
          if (response.data.isNotEmpty && response.data[0]['items'] != null) {
            // أخذ items من أول wishlist
            data = response.data[0]['items'];
          } else {
            data = response.data;
          }
        } else if (response.data is Map && response.data['success'] == true) {
          // إذا كان الـ response object فيه success و data
          data = response.data['data'] ?? [];
        } else if (response.data is Map && response.data['items'] != null) {
          // إذا كان wishlist object مباشر مع items
          data = response.data['items'];
        } else if (response.data is Map && response.data['data'] != null) {
          // إذا كان الـ response object فيه data
          final dataContent = response.data['data'];
          if (dataContent is List && dataContent.isNotEmpty && dataContent[0]['items'] != null) {
            data = dataContent[0]['items'];
          } else {
            data = dataContent is List ? dataContent : [];
          }
        } else {
          data = [];
        }

        wishlistItems = data.map((item) => WishlistItemModel.fromJson(item)).toList();

        // ترتيب حسب آخر إضافة (الأحدث أولاً)
        wishlistItems.sort((a, b) => b.addedAt.compareTo(a.addedAt));

        filteredItems = List.from(wishlistItems);
        staterequest = Staterequest.success;
        print('Wishlist loaded: ${wishlistItems.length} items');
      } else {
        staterequest = Staterequest.failure;
        print('Wishlist API failed with status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      staterequest = Staterequest.serverfailure;
      print('Wishlist Error: $e');
      print('Stack Trace: $stackTrace');
    }

    update();
  }

  @override
  addToWishlist(int contentId) async {
    try {
      final response = await api.postData(
        url: '${serverConfig.serverLink}/api/user/wishlists',
        data: {'content_id': contentId},
      );

      print('Add to Wishlist Response: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar(
          'نجح',
          'تمت إضافة المحتوى لقائمة الأمنيات',
          backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // إعادة تحميل القائمة
        await getWishlist();
        return true;
      } else if (response.statusCode == 400) {
        // المحتوى موجود مسبقاً
        final message = response.data['message'] ?? 'المحتوى موجود في القائمة';
        String arabicMessage = message;

        if (message == 'Content already in wishlist') {
          arabicMessage = 'المحتوى موجود في قائمة الأمنيات مسبقاً';
        }

        Get.snackbar(
          'تنبيه',
          arabicMessage,
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.info_outline, color: Colors.white),
        );
        return false;
      }

      Get.snackbar(
        'خطأ',
        'فشلت إضافة المحتوى لقائمة الأمنيات',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    } catch (e) {
      print('Add to Wishlist Error: $e');
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
  removeFromWishlist(int itemId) async {
    try {
      final response = await api.deleteData(
        url: '${serverConfig.serverLink}/api/user/wishlists/$itemId',
      );

      print('Remove from Wishlist Response: ${response.data}');
      print('Remove from Wishlist Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        Get.snackbar(
          'نجح',
          'تمت إزالة المحتوى من قائمة الأمنيات',
          backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // إزالة العنصر محلياً وإعادة التحميل
        wishlistItems.removeWhere((item) => item.wishlistItemId == itemId);
        filteredItems.removeWhere((item) => item.wishlistItemId == itemId);
        update();

        return true;
      } else if (response.statusCode == 404) {
        Get.snackbar(
          'تنبيه',
          'المحتوى غير موجود في القائمة',
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.info_outline, color: Colors.white),
        );

        // إزالة محلياً للتزامن
        wishlistItems.removeWhere((item) => item.wishlistItemId == itemId);
        filteredItems.removeWhere((item) => item.wishlistItemId == itemId);
        update();

        return false;
      }

      Get.snackbar(
        'خطأ',
        'فشلت إزالة المحتوى من القائمة',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    } catch (e) {
      print('Remove from Wishlist Error: $e');
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
  filterByType(String? type) {
    selectedFilter = type;

    if (type == null) {
      filteredItems = List.from(wishlistItems);
    } else {
      filteredItems = wishlistItems.where((item) {
        final itemType = item.contentType.toLowerCase();
        final filterType = type.toLowerCase();

        if (itemType == filterType) return true;

        // دعم العربية والإنجليزية
        if (filterType == 'book' && itemType == 'كتاب') return true;
        if (filterType == 'كتاب' && itemType == 'book') return true;

        if (filterType == 'magazine' && itemType == 'مجلة') return true;
        if (filterType == 'مجلة' && itemType == 'magazine') return true;

        if (filterType == 'podcast' && itemType == 'بودكاست') return true;
        if (filterType == 'بودكاست' && itemType == 'podcast') return true;

        if (filterType == 'audiobook' && itemType == 'كتاب صوتي') return true;
        if (filterType == 'كتاب صوتي' && itemType == 'audiobook') return true;

        if (filterType == 'video' && itemType == 'فيديو') return true;
        if (filterType == 'فيديو' && itemType == 'video') return true;

        return false;
      }).toList();
    }

    update();
  }

  // Helper method للحصول على العناصر المضافة مؤخراً
  List<WishlistItemModel> getRecentlyAdded({int limit = 5}) {
    return wishlistItems.take(limit).toList();
  }
}
