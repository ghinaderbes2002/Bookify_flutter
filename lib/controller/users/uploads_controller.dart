import 'dart:io';
import 'package:bookify/core/classes/api_client.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/model/upload_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class UploadsController extends GetxController {
  getUserUploads();
  createUpload({
    required File file,
    File? coverImage,
    required String title,
    required String author,
    String? description,
  });
  deleteUpload(int uploadId);
}

class UploadsControllerImp extends UploadsController {
  Staterequest staterequest = Staterequest.none;
  List<UploadModel> uploads = [];
  ApiClient api = ApiClient();
  final serverConfig = ServerConfig();

  @override
  void onInit() {
    super.onInit();
    getUserUploads();
  }

  @override
  Future<void> getUserUploads() async {
    staterequest = Staterequest.loading;
    update();

    try {
      final response = await api.getData(
        url: '${serverConfig.serverLink}/api/user/uploads',
      );

      print('Get User Uploads Response: ${response.data}');
      print('Get User Uploads Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // التحقق من نوع البيانات
        if (response.data is Map) {
          final List<dynamic> data = response.data['uploads'] ?? [];
          uploads = data.map((json) => UploadModel.fromJson(json)).toList();
        } else if (response.data is List) {
          uploads = (response.data as List)
              .map((json) => UploadModel.fromJson(json))
              .toList();
        } else {
          uploads = [];
        }

        print('Total uploads loaded: ${uploads.length}');
        for (var upload in uploads) {
          print('Upload ID: ${upload.uploadId}, Title: ${upload.title}, Status: ${upload.status}');
        }

        if (uploads.isEmpty) {
          staterequest = Staterequest.empty;
        } else {
          staterequest = Staterequest.success;
        }
      } else {
        staterequest = Staterequest.failure;
      }
    } catch (e, stackTrace) {
      print('Error getting uploads: $e');
      print('Stack trace: $stackTrace');
      staterequest = Staterequest.failure;
    }

    update();
  }

  @override
  Future<bool> createUpload({
    required File file,
    File? coverImage,
    required String title,
    required String author,
    String? description,
  }) async {
    try {
      final uri = Uri.parse('${serverConfig.serverLink}/api/user/uploads');
      final request = http.MultipartRequest('POST', uri);

      // إضافة الملف الرئيسي
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      // إضافة صورة الغلاف إن وجدت
      if (coverImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('cover', coverImage.path),
        );
      }

      // إضافة البيانات
      request.fields['title'] = title;
      request.fields['author'] = author;
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }

      // إضافة التوكن
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      print('Uploading file to: $uri');
      print('Title: $title');
      print('Author: $author');
      print('File path: ${file.path}');
      if (coverImage != null) {
        print('Cover path: ${coverImage.path}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Create Upload Response: ${response.body}');
      print('Create Upload Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'نجح',
          'تم رفع الملف بنجاح، سيتم مراجعته قريباً',
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        // تحديث القائمة
        await getUserUploads();
        return true;
      } else {
        Get.snackbar(
          'خطأ',
          'فشل رفع الملف',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('Error uploading file: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء رفع الملف',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return false;
    }
  }

  @override
  Future<bool> deleteUpload(int uploadId) async {
    try {
      final response = await api.deleteData(
        url: '${serverConfig.serverLink}/api/user/uploads/$uploadId',
      );

      print('Delete Upload Response: ${response.data}');
      print('Delete Upload Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        Get.snackbar(
          'نجح',
          'تم حذف الملف بنجاح',
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        // تحديث القائمة
        await getUserUploads();
        return true;
      } else if (response.statusCode == 404) {
        Get.snackbar(
          'خطأ',
          'الملف غير موجود',
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return false;
      } else {
        Get.snackbar(
          'خطأ',
          'فشل حذف الملف',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('Error deleting upload: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حذف الملف',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<void> refreshUploads() async {
    await getUserUploads();
  }
}
