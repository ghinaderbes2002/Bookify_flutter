import 'package:bookify/core/classes/api_client.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/model/content_model.dart';
import 'package:get/get.dart';

abstract class ContentController extends GetxController {
  getAllContent();
  getContentById(int contentId);
  getContentByCategory(int categoryId);
}

class ContentControllerImp extends ContentController {
  Staterequest staterequest = Staterequest.none;

  List<ContentModel> contents = [];
  ContentModel? selectedContent;

  ApiClient api = ApiClient();

  @override
  getAllContent() async {
    staterequest = Staterequest.loading;
    update();

    try {
      ApiResponse response = await api.getData(
        url: "${ServerConfig().serverLink}/api/user/content",
      );

      print("Response: ${response.data}");
      print("Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data is List) {
          contents = data.map((item) => ContentModel.fromJson(item)).toList();
          staterequest = contents.isEmpty ? Staterequest.empty : Staterequest.success;
          print("Contents loaded: ${contents.length}");
        } else {
          staterequest = Staterequest.failure;
          Get.snackbar("خطأ", "صيغة البيانات غير صحيحة");
        }
      } else {
        staterequest = Staterequest.failure;
        Get.snackbar("خطأ", "فشل تحميل المحتوى: ${response.statusCode}");
      }
    } catch (e) {
      staterequest = Staterequest.failure;
      Get.snackbar("خطأ", "حدث خطأ غير متوقع: $e");
      print("Error: $e");
    } finally {
      update();
    }
  }

  @override
  getContentById(int contentId) async {
    staterequest = Staterequest.loading;
    update();

    try {
      ApiResponse response = await api.getData(
        url: "${ServerConfig().serverLink}/api/user/content/$contentId",
      );

      print("Response: ${response.data}");
      print("Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        selectedContent = ContentModel.fromJson(data);
        staterequest = Staterequest.success;
        print("Content loaded: ${selectedContent!.title}");
      } else {
        staterequest = Staterequest.failure;
        Get.snackbar("خطأ", "فشل تحميل المحتوى: ${response.statusCode}");
      }
    } catch (e) {
      staterequest = Staterequest.failure;
      Get.snackbar("خطأ", "حدث خطأ غير متوقع: $e");
      print("Error: $e");
    } finally {
      update();
    }
  }

  @override
  getContentByCategory(int categoryId) async {
    staterequest = Staterequest.loading;
    contents = [];
    update();

    try {
      ApiResponse response = await api.getData(
        url: "${ServerConfig().serverLink}/api/user/content",
      );

      print("Response: ${response.data}");
      print("Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data is List) {
          final allContents = data.map((item) => ContentModel.fromJson(item)).toList();

          // يمكن تصفية المحتوى حسب التصنيف إذا كان Backend يرجع categories مع المحتوى
          // أو يمكن عمل endpoint خاص بجلب محتوى حسب التصنيف
          contents = allContents;

          staterequest = contents.isEmpty ? Staterequest.empty : Staterequest.success;
          print("Contents for category $categoryId loaded: ${contents.length}");
        } else {
          staterequest = Staterequest.failure;
          Get.snackbar("خطأ", "صيغة البيانات غير صحيحة");
        }
      } else {
        staterequest = Staterequest.failure;
        Get.snackbar("خطأ", "فشل تحميل المحتوى: ${response.statusCode}");
      }
    } catch (e) {
      staterequest = Staterequest.failure;
      Get.snackbar("خطأ", "حدث خطأ غير متوقع: $e");
      print("Error: $e");
    } finally {
      update();
    }
  }
}
