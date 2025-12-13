import 'dart:io';
import 'package:bookify/core/constant/App_link.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

abstract class PdfViewerController extends GetxController {
  downloadAndOpenPdf(String url);
}

class PdfViewerControllerImp extends PdfViewerController {
  String? localPath;
  bool isLoading = true;
  String? errorMessage;
  int currentPage = 0;
  int totalPages = 0;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  downloadAndOpenPdf(String url) async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      // Build full URL if it's a relative path
      String fullUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        final serverConfig = ServerConfig();
        fullUrl = '${serverConfig.serverLink}$url';
      }

      print('Downloading PDF from: $fullUrl');

      // Use a simple cache directory path without path_provider
      final cacheDir = Directory('/data/user/0/com.example.bookify/cache/pdfs');

      // Create directory if it doesn't exist
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final fileName = url.split('/').last;
      final filePath = '${cacheDir.path}/$fileName';
      final file = File(filePath);

      // Check if file already exists
      if (await file.exists()) {
        localPath = file.path;
        isLoading = false;
        update();
        return;
      }

      // Download the file
      final dio = Dio();
      await dio.download(
        fullUrl,
        file.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('تحميل: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      localPath = file.path;
      isLoading = false;
      update();
    } catch (e) {
      errorMessage = 'فشل تحميل الملف: $e';
      isLoading = false;
      update();
      print('PDF Download Error: $e');
    }
  }

  void onRenderComplete(int? pages) {
    totalPages = pages ?? 0;
    update();
  }

  void onPageChanged(int? page, int? total) {
    currentPage = page ?? 0;
    update();
  }

  void onError(dynamic error) {
    errorMessage = 'خطأ في عرض الملف: $error';
    update();
  }
}
