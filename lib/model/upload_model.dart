import 'package:flutter/material.dart';

class UploadModel {
  final int uploadId;
  final int userId;
  final String? fileName;
  final String? filePath;
  final DateTime uploadedAt;
  final String? author;
  final String? coverUrl;
  final String? description;
  final String status; // PENDING, APPROVED, REJECTED
  final String? title;

  UploadModel({
    required this.uploadId,
    required this.userId,
    this.fileName,
    this.filePath,
    required this.uploadedAt,
    this.author,
    this.coverUrl,
    this.description,
    this.status = 'PENDING',
    this.title,
  });

  factory UploadModel.fromJson(Map<String, dynamic> json) {
    // دالة مساعدة لتحويل القيم إلى int
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return UploadModel(
      uploadId: toInt(json['upload_id']),
      userId: toInt(json['user_id']),
      fileName: json['file_name']?.toString(),
      filePath: json['file_path']?.toString(),
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'].toString())
          : DateTime.now(),
      author: json['author']?.toString(),
      coverUrl: json['cover_url']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      title: json['title']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upload_id': uploadId,
      'user_id': userId,
      'file_name': fileName,
      'file_path': filePath,
      'uploaded_at': uploadedAt.toIso8601String(),
      'author': author,
      'cover_url': coverUrl,
      'description': description,
      'status': status,
      'title': title,
    };
  }

  String getStatusLabel() {
    switch (status) {
      case 'PENDING':
        return 'قيد المراجعة';
      case 'APPROVED':
        return 'تمت الموافقة';
      case 'REJECTED':
        return 'مرفوض';
      default:
        return 'غير معروف';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFFFA726); // Orange
      case 'APPROVED':
        return const Color(0xFF66BB6A); // Green
      case 'REJECTED':
        return const Color(0xFFEF5350); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String getFileExtension() {
    if (fileName == null) return '';
    final parts = fileName!.split('.');
    if (parts.length > 1) {
      return parts.last.toUpperCase();
    }
    return '';
  }

  String getFileIcon() {
    final ext = getFileExtension().toLowerCase();
    switch (ext) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return '🖼️';
      case 'mp3':
      case 'wav':
        return '🎵';
      case 'mp4':
      case 'avi':
        return '🎬';
      case 'zip':
      case 'rar':
        return '📦';
      default:
        return '📎';
    }
  }

  String getTimeSinceUpload() {
    final now = DateTime.now();
    final difference = now.difference(uploadedAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'منذ $years ${years == 1 ? 'سنة' : 'سنوات'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months ${months == 1 ? 'شهر' : 'أشهر'}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  String getFileSizeLabel(int bytes) {
    if (bytes < 1024) {
      return '$bytes بايت';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} كيلوبايت';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} جيجابايت';
    }
  }
}
