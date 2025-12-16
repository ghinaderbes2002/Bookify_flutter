import 'package:bookify/core/classes/api_client.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/core/services/SharedPreferences.dart';
import 'package:bookify/model/review_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class ReviewsController extends GetxController {
  getUserReviews();
  filterByRating(int? rating);
  Future<List<ReviewModel>> getAllReviews(int contentId);
  Future<ReviewModel?> getReviewById(int reviewId);
  createReview(int contentId, int rating, String? reviewText);
  updateReview(int reviewId, int rating, String? reviewText);
  deleteReview(int reviewId);
}

class ReviewsControllerImp extends ReviewsController {
  Staterequest staterequest = Staterequest.none;
  List<ReviewModel> allReviews = [];
  List<ReviewModel> filteredReviews = [];
  int? selectedRating; // null = all, 1-5 = specific ratin
  ApiClient api = ApiClient();
  final serverConfig = ServerConfig();
  final myServices = Get.find<MyServices>();

  int _getCurrentUserId() {
    return myServices.sharedPref.getInt('userId') ?? 0;
  }

  @override
  void onInit() {
    super.onInit();
    getUserReviews();
  }

  @override
  getUserReviews() async {
    staterequest = Staterequest.loading;
    update();

    try {
      final response = await api.getData(
        url: '${serverConfig.serverLink}/api/user/reviews',
      );

      print('Reviews Response: ${response.data}');
      print('Reviews Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        List data;

        // التحقق من نوع الـ response
        if (response.data is List) {
          data = response.data;
        } else if (response.data is Map && response.data['success'] == true) {
          data = response.data['data'] ?? [];
        } else if (response.data is Map && response.data['data'] != null) {
          data = response.data['data'];
        } else if (response.data is Map && response.data['reviews'] != null) {
          data = response.data['reviews'];
        } else {
          data = [];
        }

        allReviews = data.map((item) => ReviewModel.fromJson(item)).toList();

        // ترتيب حسب الأحدث أولاً
        allReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        filteredReviews = List.from(allReviews);
        staterequest = Staterequest.success;
        print('Reviews loaded: ${allReviews.length} reviews');
      } else {
        staterequest = Staterequest.failure;
        print('Reviews API failed with status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      staterequest = Staterequest.serverfailure;
      print('Reviews Error: $e');
      print('Stack Trace: $stackTrace');
    }

    update();
  }

  @override
  filterByRating(int? rating) {
    selectedRating = rating;

    if (rating == null) {
      filteredReviews = List.from(allReviews);
    } else {
      filteredReviews = allReviews.where((review) {
        return review.rating == rating;
      }).toList();
    }

    update();
  }

  // Helper methods
  double getAverageRating() {
    if (allReviews.isEmpty) return 0.0;
    final sum = allReviews.fold<int>(0, (prev, review) => prev + review.rating);
    return sum / allReviews.length;
  }

  Map<int, int> getRatingDistribution() {
    Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in allReviews) {
      if (review.rating >= 1 && review.rating <= 5) {
        distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
      }
    }
    return distribution;
  }

  List<ReviewModel> getRecentReviews({int limit = 5}) {
    return allReviews.take(limit).toList();
  }

  @override
  Future<List<ReviewModel>> getAllReviews(int contentId) async {
    staterequest = Staterequest.loading;
    update();

    try {
      final response = await api.getData(
        url: '${serverConfig.serverLink}/api/admin/reviews',
      );

      print('All Reviews Response: ${response.data}');
      print('All Reviews Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        List data;

        // التحقق من نوع الـ response
        if (response.data is List) {
          data = response.data;
        } else if (response.data is Map && response.data['success'] == true) {
          data = response.data['data'] ?? [];
        } else if (response.data is Map && response.data['data'] != null) {
          data = response.data['data'];
        } else if (response.data is Map && response.data['reviews'] != null) {
          data = response.data['reviews'];
        } else {
          data = [];
        }

        // تحويل البيانات لـ ReviewModel
        List<ReviewModel> contentReviews =
            data.map((item) => ReviewModel.fromJson(item)).toList();

        // فلترة حسب contentId
        contentReviews = contentReviews
            .where((review) => review.contentId == contentId)
            .toList();

        // ترتيب حسب الأحدث أولاً
        contentReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        staterequest = Staterequest.success;
        print('Content Reviews loaded: ${contentReviews.length} reviews');

        update();
        return contentReviews;
      } else {
        staterequest = Staterequest.failure;
        print('All Reviews API failed with status: ${response.statusCode}');
        update();
        return [];
      }
    } catch (e, stackTrace) {
      staterequest = Staterequest.serverfailure;
      print('All Reviews Error: $e');
      print('Stack Trace: $stackTrace');
      update();
      return [];
    }
  }

  @override
  Future<ReviewModel?> getReviewById(int reviewId) async {
    staterequest = Staterequest.loading;
    update();

    try {
      final response = await api.getData(
        url: '${serverConfig.serverLink}/api/admin/reviews/$reviewId',
      );

      print('Review By ID Response: ${response.data}');
      print('Review By ID Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        Map<String, dynamic> data;

        // التحقق من نوع الـ response
        if (response.data is Map) {
          if (response.data['success'] == true && response.data['data'] != null) {
            data = response.data['data'];
          } else if (response.data['review'] != null) {
            data = response.data['review'];
          } else {
            data = response.data;
          }
        } else {
          staterequest = Staterequest.failure;
          update();
          return null;
        }

        ReviewModel review = ReviewModel.fromJson(data);
        staterequest = Staterequest.success;
        print('Review loaded: ID ${review.reviewId}');

        update();
        return review;
      } else if (response.statusCode == 404) {
        staterequest = Staterequest.failure;
        Get.snackbar(
          'غير موجود',
          'التقييم غير موجود',
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        update();
        return null;
      } else {
        staterequest = Staterequest.failure;
        print('Review By ID API failed with status: ${response.statusCode}');
        update();
        return null;
      }
    } catch (e, stackTrace) {
      staterequest = Staterequest.serverfailure;
      print('Review By ID Error: $e');
      print('Stack Trace: $stackTrace');
      update();
      return null;
    }
  }

  @override
  createReview(int contentId, int?  rating, String? reviewText) async {
    staterequest = Staterequest.loading;
    update();

    try {
      final response = await api.postData(
        url: '${serverConfig.serverLink}/api/admin/reviews',
        data: {
          'user_id': _getCurrentUserId(),
          'content_id': contentId,
          'rating': rating,
          'review_text': reviewText,
        },
      );

      print('Create Review Response: ${response.data}');
      print('Create Review Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        staterequest = Staterequest.success;
        Get.snackbar(
          'نجح',
          'تم إضافة التقييم بنجاح',
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        // تحديث قائمة التقييمات بعد الإضافة
        await getUserReviews();
        update();
        return true;
      } else if (response.statusCode == 400) {
        staterequest = Staterequest.failure;
        Get.snackbar(
          'تنبيه',
          'لقد قمت بتقييم هذا المحتوى مسبقاً. يمكنك تعديل تقييمك الحالي فقط',
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        update();
        return false;
      } else {
        staterequest = Staterequest.failure;
        Get.snackbar(
          'خطأ',
          'فشل إضافة التقييم',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        update();
        return false;
      }
    } catch (e, stackTrace) {
      staterequest = Staterequest.serverfailure;
      print('Create Review Error: $e');
      print('Stack Trace: $stackTrace');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في الاتصال',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      update();
      return false;
    }
  }

  @override
  updateReview(int reviewId, int?  rating, String? reviewText) async {
    staterequest = Staterequest.loading;
    update();

    try {
      final response = await api.putData(
        url: '${serverConfig.serverLink}/api/admin/reviews/$reviewId',
        data: {
          'rating': rating,
          'review_text': reviewText,
        },
      );

      print('Update Review Response: ${response.data}');
      print('Update Review Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        staterequest = Staterequest.success;
        Get.snackbar(
          'نجح',
          'تم تحديث التقييم بنجاح',
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        // تحديث قائمة التقييمات بعد التعديل
        await getUserReviews();
        update();
        return true;
      } else if (response.statusCode == 404) {
        staterequest = Staterequest.failure;
        Get.snackbar(
          'خطأ',
          'التقييم غير موجود',
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        update();
        return false;
      } else if (response.statusCode == 403) {
        staterequest = Staterequest.failure;
        Get.snackbar(
          'خطأ',
          'غير مصرح لك بتعديل هذا التقييم',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        update();
        return false;
      } else {
        staterequest = Staterequest.failure;
        Get.snackbar(
          'خطأ',
          'فشل تحديث التقييم',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        update();
        return false;
      }
    } catch (e, stackTrace) {
      staterequest = Staterequest.serverfailure;
      print('Update Review Error: $e');
      print('Stack Trace: $stackTrace');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في الاتصال',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      update();
      return false;
    }
  }

  @override
  deleteReview(int reviewId) async {
    staterequest = Staterequest.loading;
    update();

    try {
      final response = await api.deleteData(
        url: '${serverConfig.serverLink}/api/admin/reviews/$reviewId',
      );

      print('Delete Review Response: ${response.data}');
      print('Delete Review Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        staterequest = Staterequest.success;
        Get.snackbar(
          'نجح',
          'تم حذف التقييم بنجاح',
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        // تحديث قائمة التقييمات بعد الحذف
        await getUserReviews();
        update();
        return true;
      } else if (response.statusCode == 404) {
        staterequest = Staterequest.failure;
        Get.snackbar(
          'خطأ',
          'التقييم غير موجود',
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        update();
        return false;
      } else if (response.statusCode == 403) {
        staterequest = Staterequest.failure;
        Get.snackbar(
          'خطأ',
          'غير مصرح لك بحذف هذا التقييم',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        update();
        return false;
      } else {
        staterequest = Staterequest.failure;
        Get.snackbar(
          'خطأ',
          'فشل حذف التقييم',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        update();
        return false;
      }
    } catch (e, stackTrace) {
      staterequest = Staterequest.serverfailure;
      print('Delete Review Error: $e');
      print('Stack Trace: $stackTrace');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في الاتصال',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      update();
      return false;
    }
  }
}
