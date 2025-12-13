import 'package:bookify/core/classes/api_client.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/model/categories_model.dart';
import 'package:get/get.dart';

abstract class CategoriesController extends GetxController {
  getAllCategories();
  getCategoryById(int categoryId);
}

class CategoriesControllerImp extends CategoriesController {
  Staterequest staterequest = Staterequest.none;

  List<CategoriesModel> categories = [];
  CategoriesModel? selectedCategory;

  ApiClient api = ApiClient();

  @override
  void onInit() {
    getAllCategories();
    super.onInit();
  }

  @override
  getAllCategories() async {
    staterequest = Staterequest.loading;
    update();

    try {
      ApiResponse response = await api.getData(
        url: "${ServerConfig().serverLink}/api/user/categories",
      );

      print("Response: ${response.data}");
      print("Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data is List) {
          categories = data.map((item) => CategoriesModel.fromJson(item)).toList();
          staterequest = Staterequest.success;
          print("Categories loaded: ${categories.length}");
        } else {
          staterequest = Staterequest.failure;
          Get.snackbar("خطأ", "صيغة البيانات غير صحيحة");
        }
      } else {
        staterequest = Staterequest.failure;
        Get.snackbar("خطأ", "فشل تحميل التصنيفات: ${response.statusCode}");
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
  getCategoryById(int categoryId) async {
    staterequest = Staterequest.loading;
    update();

    try {
      ApiResponse response = await api.getData(
        url: "${ServerConfig().serverLink}/api/user/categories/$categoryId",
      );

      print("Response: ${response.data}");
      print("Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        selectedCategory = CategoriesModel.fromJson(data);
        staterequest = Staterequest.success;
        print("Category loaded: ${selectedCategory!.name}");
      } else {
        staterequest = Staterequest.failure;
        Get.snackbar("خطأ", "فشل تحميل التصنيف: ${response.statusCode}");
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
