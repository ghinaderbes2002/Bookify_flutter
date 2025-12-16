import 'dart:io';
import 'package:bookify/controller/users/uploads_controller.dart';
import 'package:bookify/core/classes/staterequest.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:bookify/view/widget/speech_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UploadsScreen extends StatelessWidget {
  const UploadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(UploadsControllerImp());
    final serverConfig = ServerConfig();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ملفاتي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GetBuilder<UploadsControllerImp>(
        builder: (controller) {
          if (controller.staterequest == Staterequest.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            );
          }

          if (controller.staterequest == Staterequest.failure) {
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
                  const Text(
                    'فشل تحميل الملفات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => controller.getUserUploads(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (controller.staterequest == Staterequest.empty ||
              controller.uploads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: Colors.grey.shade400,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد ملفات مرفوعة حالياً',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يمكنك رفع ملفاتك من خلال الزر في الأسفل',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.refreshUploads();
            },
            color: Colors.teal,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.uploads.length,
              itemBuilder: (context, index) {
                final upload = controller.uploads[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // صورة الغلاف أو أيقونة الملف
                            Container(
                              width: 60,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                image: upload.coverUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          '${serverConfig.serverLink}${upload.coverUrl}',
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: upload.coverUrl == null
                                  ? Center(
                                      child: Text(
                                        upload.getFileIcon(),
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    upload.title ?? upload.fileName ?? 'ملف غير معروف',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (upload.author != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            upload.author!,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: upload.getStatusColor().withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: upload.getStatusColor(),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          upload.getStatusLabel(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: upload.getStatusColor(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        upload.getTimeSinceUpload(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (upload.description != null && upload.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Text(
                            upload.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: const Text('تأكيد الحذف'),
                                    content: const Text(
                                      'هل أنت متأكد من حذف هذا الملف؟',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('إلغاء'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Get.back();
                                          await controller
                                              .deleteUpload(upload.uploadId);
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('حذف'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('حذف'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadDialog(context),
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.cloud_upload, color: Colors.white),
        label: const Text(
          'رفع ملف جديد',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        File? selectedFile;
        File? selectedCover;
        String? selectedFileName;
        String? selectedCoverName;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'رفع ملف جديد',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // اختيار الملف الرئيسي
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf', 'doc', 'docx', 'epub', 'txt'],
                            );
                            if (result != null && result.files.single.path != null) {
                              setState(() {
                                selectedFile = File(result.files.single.path!);
                                selectedFileName = result.files.single.name;
                              });
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            side: BorderSide(
                              color: selectedFile != null ? Colors.teal : Colors.grey,
                              width: 2,
                            ),
                          ),
                          icon: Icon(
                            selectedFile != null ? Icons.check_circle : Icons.attach_file,
                            color: selectedFile != null ? Colors.teal : Colors.grey,
                          ),
                          label: Text(
                            selectedFileName ?? 'اختر الملف (PDF, DOC, EPUB, TXT)',
                            style: TextStyle(
                              color: selectedFile != null ? Colors.teal : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // اختيار صورة الغلاف (اختياري)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                            );
                            if (result != null && result.files.single.path != null) {
                              setState(() {
                                selectedCover = File(result.files.single.path!);
                                selectedCoverName = result.files.single.name;
                              });
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            side: BorderSide(
                              color: selectedCover != null ? Colors.teal : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          icon: Icon(
                            selectedCover != null ? Icons.check_circle : Icons.image,
                            color: selectedCover != null ? Colors.teal : Colors.grey,
                          ),
                          label: Text(
                            selectedCoverName ?? 'اختر صورة الغلاف (اختياري)',
                            style: TextStyle(
                              color: selectedCover != null ? Colors.teal : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                    // عنوان الملف
                    SpeechTextField(
                        controller: titleController,
                        label: 'عنوان الملف',
                        hint: 'أدخل عنوان الكتاب أو المحتوى',
                        requiredField: true,
                      ),

                    const SizedBox(height: 16),

                    // اسم المؤلف
                SpeechTextField(
                        controller: authorController,
                        label: 'اسم المؤلف',
                        hint: 'أدخل اسم المؤلف',
                        requiredField: true,
                      ),

                    const SizedBox(height: 16),

                    // الوصف
                SpeechTextField(
                        controller: descriptionController,
                        label: 'الوصف',
                        hint: 'أدخل وصفاً مختصراً عن المحتوى',
                        maxLines: 3,
                      ),

                    const SizedBox(height: 24),

                    // زر الرفع
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedFile == null) {
                            Get.snackbar(
                              'خطأ',
                              'الرجاء اختيار ملف للرفع',
                              backgroundColor: Colors.red.withValues(alpha: 0.8),
                              colorText: Colors.white,
                            );
                            return;
                          }

                          if (titleController.text.trim().isEmpty) {
                            Get.snackbar(
                              'خطأ',
                              'الرجاء إدخال عنوان الملف',
                              backgroundColor: Colors.red.withValues(alpha: 0.8),
                              colorText: Colors.white,
                            );
                            return;
                          }

                          if (authorController.text.trim().isEmpty) {
                            Get.snackbar(
                              'خطأ',
                              'الرجاء إدخال اسم المؤلف',
                              backgroundColor: Colors.red.withValues(alpha: 0.8),
                              colorText: Colors.white,
                            );
                            return;
                          }

                          Navigator.pop(dialogContext);

                          final controller = Get.find<UploadsControllerImp>();
                          await controller.createUpload(
                            file: selectedFile!,
                            coverImage: selectedCover,
                            title: titleController.text.trim(),
                            author: authorController.text.trim(),
                            description: descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'رفع الملف',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
  }
}
