import 'package:bookify/controller/users/pdf_viewer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PdfViewerControllerImp());
    controller.downloadAndOpenPdf(pdfUrl);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          GetBuilder<PdfViewerControllerImp>(
            builder: (controller) {
              if (controller.totalPages > 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'صفحة ${controller.currentPage + 1} من ${controller.totalPages}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: GetBuilder<PdfViewerControllerImp>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.teal),
                  SizedBox(height: 16),
                  Text('جاري تحميل الملف...'),
                ],
              ),
            );
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.downloadAndOpenPdf(pdfUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (controller.localPath == null) {
            return const Center(
              child: Text('لا يوجد ملف للعرض'),
            );
          }

          return PDFView(
            filePath: controller.localPath!,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            onRender: (pages) {
              controller.onRenderComplete(pages);
            },
            onPageChanged: (page, total) {
              controller.onPageChanged(page, total);
            },
            onError: (error) {
              controller.onError(error);
            },
          );
        },
      ),
    );
  }
}
