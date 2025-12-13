class UserLibraryModel {
  final int userLibraryId;
  final int userId;
  final int contentId;
  final DateTime addedAt;
  final DateTime? lastAccessedAt;

  // معلومات المحتوى المرتبط
  final String title;
  final String? description;
  final String contentType;
  final String? author;
  final String? coverImageUrl;
  final String? fileUrl;
  final String? audioUrl;

  UserLibraryModel({
    required this.userLibraryId,
    required this.userId,
    required this.contentId,
    required this.addedAt,
    this.lastAccessedAt,
    required this.title,
    this.description,
    required this.contentType,
    this.author,
    this.coverImageUrl,
    this.fileUrl,
    this.audioUrl,
  });

  factory UserLibraryModel.fromJson(Map<String, dynamic> json) {
    return UserLibraryModel(
      userLibraryId: int.parse(json['user_library_id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      contentId: int.parse(json['content_id'].toString()),
      addedAt: DateTime.parse(json['added_at']),
      lastAccessedAt: json['last_accessed_at'] != null
          ? DateTime.parse(json['last_accessed_at'])
          : null,
      title: json['content']?['title'] ?? json['title'] ?? '',
      description: json['content']?['description'] ?? json['description'],
      contentType: json['content']?['content_type'] ?? json['content_type'] ?? '',
      author: json['content']?['author'] ?? json['author'],
      coverImageUrl: json['content']?['cover_url'] ??
                     json['content']?['cover_image_url'] ??
                     json['cover_url'] ??
                     json['cover_image_url'],
      fileUrl: json['content']?['file_url'] ?? json['file_url'],
      audioUrl: json['content']?['audio_url'] ?? json['audio_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_library_id': userLibraryId,
      'user_id': userId,
      'content_id': contentId,
      'added_at': addedAt.toIso8601String(),
      'last_accessed_at': lastAccessedAt?.toIso8601String(),
      'title': title,
      'description': description,
      'content_type': contentType,
      'author': author,
      'cover_image_url': coverImageUrl,
      'file_url': fileUrl,
      'audio_url': audioUrl,
    };
  }

  // Helper method للحصول على أيقونة نوع المحتوى

  String getContentTypeIcon() {
    final type = contentType.toLowerCase();
    switch (type) {
      case 'book':
      case 'كتاب':
        return '📚';
      case 'article':
      case 'مقالة':
        return '📰';
      case 'audio':
      case 'صوتي':
      case 'audiobook':
      case 'كتاب صوتي':
        return '🎵';
      case 'video':
      case 'فيديو':
        return '🎥';
      case 'magazine':
      case 'مجلة':
        return '📖';
      case 'podcast':
      case 'بودكاست':
        return '🎙️';
      default:
        return '📄';
    }
  }

  String getContentTypeLabel() {
    final type = contentType.toLowerCase();
    switch (type) {
      case 'book':
      case 'كتاب':
        return 'كتاب';
      case 'article':
      case 'مقالة':
        return 'مقالة';
      case 'audio':
      case 'صوتي':
        return 'صوتي';
      case 'audiobook':
      case 'كتاب صوتي':
        return 'كتاب صوتي';
      case 'video':
      case 'فيديو':
        return 'فيديو';
      case 'magazine':
      case 'مجلة':
        return 'مجلة';
      case 'podcast':
      case 'بودكاست':
        return 'بودكاست';
      default:
        return contentType; // إرجاع النص الأصلي إذا لم يطابق أي حالة
    }
  }
}
